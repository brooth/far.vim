" File: autoload/far/tools.vim
" Description: far.vim utils
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

"logging {{{
let s:debug = exists('g:far#debug')? g:far#debug : 0
let s:logfile = $HOME.'/far.vim.log'

if s:debug
    call writefile(['debug enabled!'], s:logfile)
endif

function! far#tools#isdebug()
    return s:debug
endfunction

function! far#tools#log(msg)
    if s:debug
        call writefile(['[' . strftime("%T") . '] ' .a:msg], s:logfile, "a")
    endif
endfunction
"}}}

function! far#tools#setdefault(var, val) abort "{{{
    if !exists(a:var)
        exec 'let '.a:var.' = '.string(a:val)
    endif
endfunction "}}}

function! far#tools#split_layout(smode, bname, width, height) abort "{{{
    if a:smode == 'top'
        return 'aboveleft '.a:height.'split '.a:bname
    elseif a:smode == 'left'
        return 'leftabove '.a:width.'vsplit '.a:bname
    elseif a:smode == 'right'
        return 'rightbelow '.a:width.'vsplit '.a:bname
    elseif a:smode == 'bottom'
        return 'belowright '.a:height.'split '.a:bname
    else
        echoerr 'invalid window layout '.a:smode
        return 'aboveleft '.a:height.'split '.a:bname
    endif
endfunction "}}}

function! far#tools#win_layout(win_params, param_prefix, fname) abort "{{{
    let fname = escape(a:fname, ' ')
    if get(a:win_params, a:param_prefix.'layout') == 'current'
        let bufnr = bufnr(fname)
        return bufnr != -1 ? 'buffer '.bufnr : 'edit '.fname
    elseif get(a:win_params, a:param_prefix.'layout') == 'tab'
        return 'tabedit '.fname
    elseif get(a:win_params, a:param_prefix.'layout') == 'top'
        let layout = 'topleft '.get(a:win_params, a:param_prefix.'height')
    elseif get(a:win_params, a:param_prefix.'layout') == 'left'
        let layout = 'topleft vertical '.get(a:win_params, a:param_prefix.'width')
    elseif get(a:win_params, a:param_prefix.'layout') == 'right'
        let layout = 'botright vertical '.get(a:win_params, a:param_prefix.'width')
    elseif get(a:win_params, a:param_prefix.'layout') == 'bottom'
        let layout = 'botright '.get(a:win_params, a:param_prefix.'height')
    else
        echoerr 'invalid window layout '.get(a:win_params, a:param_prefix.'layout')
        let layout = 'botright vertical '.a:width
    endif
    return layout.' new '.fname
endfunction "}}}

function! far#tools#undo_nextnr() "{{{
    " the undo sequence number of current status
    let undonum = changenr()

    " " if current status is just after an `undo` command,
    " " get the undo sequence number of current status
    " let curhead = 0
    " for undoentry in reverse(undotree().entries)
    "     if curhead
    "         call far#tools#log('undo seq:'.undoentry.seq)
    "         let undonum = undoentry.seq
    "         break
    "     endif
    "     let curhead = get(undoentry, 'curhead', 0)
    " endfor

    return undonum
endfunction "}}}

function! far#tools#splitcmdshell(cmdline)
    " Split command line into arguments using bash-like semantics
    " States:
    " 0 - Scanning spaces between arguments
    " 1 - Scanning in single-quotes
    " 2 - Scanning in double-quotes
    " 3 - Scanning outside of quotes
    " 4 - Scanning char after backslash in double quotes
    " 5 - Scanning char after backslash outside quotes
    let retargs = []
    let state = 0
    let carg = ''
    for c in split(a:cmdline . ' ', '\zs')
        if state == 0
            if c == ' '
                continue
            elseif c == "'"
                let state = 1
                let carg = ''
            elseif c == '"'
                let state = 2
                let carg = ''
            else
                let state = 3
                let carg = c
            endif
        elseif state == 1
            if c == "'"
                let state = 3
            else
                let carg = carg . c
            endif
        elseif state == 2
            if c == '"'
                let state = 3
            elseif c == '\'
                let state = 4
            else
                let carg = carg . c
            endif
        elseif state == 3
            if c == ' '
                call add(retargs, carg)
                let state = 0
            elseif c == '\'
                let state = 5
            elseif c == "'"
                let state = 1
            elseif c == '"'
                let state = 2
            else
                let carg = carg . c
            endif
        elseif state == 4
            if c == '"'
                let carg = carg . c
            elseif c == '\'
                let carg = carg . c
            else
                let carg = carg . '\' . c
            endif
            let state = 2
        elseif state == 5
            let carg = carg . c
            let state = 3
        endif
    endfor
    if state != 0 && carg != ''
        call add(retargs, carg)
    endif
    return retargs
endfunction

function! far#tools#splitcmd(cmdline) "{{{
    if g:far#cmdparse_mode == 'shell'
        return far#tools#splitcmdshell(a:cmdline)
    endif
    let cmdline = substitute(a:cmdline, '^\s*\(.\{-}\)\s*$', '\1', '')
    let slashes = split(cmdline, '\\\\')
    let cmds = []
    let slash_weight = 0
    let p1 = 0
    for idx in range(0, len(slashes)-1)
        let slash = slashes[idx]
        let pos = -1
        while 1
            let pos = match(slash, '\(.*\\\)\@<!\s', pos+1)
            if pos != -1
                let p2 = pos + idx*2 + slash_weight
                if !empty(cmdline[p1:p2-1])
                    call add(cmds, cmdline[p1:p2-1])
                endif
                let p1 = p2+1
            else
                break
            endif
        endwhile
        let slash_weight += len(slash)
        let idx += 1
    endfor
    call add(cmds, cmdline[p1:])
    return cmds
endfunction "}}}

function! far#tools#centrify_text(text, width, val_col) abort "{{{
    " a:text: text to cut
    " a:width: the width of displayed text
    " a:val_col: byte id (begin with 1) the matched substring start from

    let text = copy(a:text)
    " pretext: text before the matched substring
    let pretext = a:val_col == 1 ? '' : text[0: a:val_col - 2]
    " val_col: char id (begin with 1) the matched substring start from
    let val_col = strchars(pretext) + 1
    " val_idx: byte id (begin with 1) the matched substring start from
    let val_idx = a:val_col

    if strdisplaywidth(text) > a:width && strdisplaywidth(pretext) > a:width/2 - 7
        " left_start_col: char id (begin with 1) the displayed substring start from
        let left_start_col = val_col
        " cut_text_to_val: the displayed text cut on the left, until the matched substring
        let cut_text_to_val = g:far#cut_text_sign. strcharpart(text, left_start_col - 1, val_col - left_start_col)
        while strdisplaywidth(cut_text_to_val) < a:width/2 - 7
            let left_start_col -= 1
            let cut_text_to_val = g:far#cut_text_sign. strcharpart(text, left_start_col - 1, val_col - left_start_col)
        endwhile
        " text_beyond_left: the left-side undisplayed text
        let text_beyond_left = left_start_col == 1 ? '' : strcharpart(text, 0, left_start_col - 2)
        " left_start_idx: byte id (begin with 1) the displayed substring start from
        let left_start_idx = len(text_beyond_left) + 1

        " val_col: the matched substring start from the val_col'th char (begin with 1)
        let val_col = val_col - left_start_col + 2 + strchars(g:far#cut_text_sign)
        " val_idx: the matched substring start from the val_idx'th byte (begin with 1)
        let val_idx = val_idx - left_start_idx + 1 + len(g:far#cut_text_sign)
        " text: the displayed text cut on the left
        let text = g:far#cut_text_sign. text[left_start_idx-1:]
    endif
    if strdisplaywidth(text) > a:width
        " char_num: the number of chars in the displayed text
        let char_num = strchars(text)
        " text_cut: the displayed text cut on the right
        let text_cut = strcharpart(text,0,char_num).g:far#cut_text_sign
        while strdisplaywidth(text_cut)  > a:width
            let char_num -= 1
            let text_cut = strcharpart(text,0,char_num).g:far#cut_text_sign
        endwhile
        let text = text_cut
    endif
    if strdisplaywidth(text) < a:width
        let text = text.repeat(' ', a:width - strdisplaywidth(text))
    endif

    " text: cut text
    " val_col: char id (begin with 1) the matched substring start from
    " val_idx: byte id (begin with 1) the matched substring start from
    return {'text': text, 'val_col': val_col, 'val_idx': val_idx}
endfunction "}}}

function! far#tools#cut_text_middle(text, width) abort "{{{
    if strchars(a:text) <= a:width
        return a:text
    endif

    let text_size = len(a:text)
    let sign_len = strchars(g:far#cut_text_sign)
    let centr = (a:width - sign_len) / 2
    return a:text[:centr-1].g:far#cut_text_sign.a:text[-centr - (a:width % 2? 0 : 1):]
endfunction "}}}

function! far#tools#echo_err(msg) abort "{{{
    execute 'normal! \<Esc>'
    echohl ErrorMsg
    echomsg a:msg
    " echomsg 'Press any key to continue'
    echohl None
    " call getchar()
endfunction "}}}

function! far#tools#echo_warn(msg) abort "{{{
    execute 'normal! \<Esc>'
    echohl ErrorMsg
    echomsg 'Warning: ' . a:msg .' | Press any key to continue'
    echohl None
    call getchar()
endfunction "}}}

function! far#tools#echo_msg(msg) abort "{{{
    execute 'normal! \<Esc>'
    echomsg a:msg
endfunction "}}}

function! far#tools#ftlookup(ext) abort "{{{
    if empty(a:ext)
        return 'none'
    endif
    if !exists('s:knownfiletypes')
        let s:knownfiletypes = {}
    endif

    if has_key(s:knownfiletypes, a:ext)
        call far#tools#log('know ft ' . a:ext . '=' . s:knownfiletypes[a:ext])
        return s:knownfiletypes[a:ext]
    endif

    if !exists('s:filetypes')
        exec 'redir => s:filetypes'
        silent! exec 'autocmd filetypedetect'
        exec 'redir END'
        let s:filetypes = split(s:filetypes, '\n')
    endif

    let matching = filter(s:filetypes, 'v:val =~ "\*\.'.a:ext.' *setf"')
    let ft = len(matching) > 0 ? matchstr(matching[0], 'setf\s\+\zs\k\+') : a:ext
    let s:knownfiletypes[a:ext] = ft
    call far#tools#log('detected ft ' . a:ext . '=' . ft)
    return ft
endfunction "}}}

function! far#tools#matchcnt(pat, exp) abort "{{{
    let cnt = 0
    let idx = -1
    while 1
        let idx = stridx(a:pat, a:exp, idx+1)
        if idx == -1
            break
        endif
        let cnt += 1
    endwhile
    return cnt
endfunction "}}}

function! far#tools#visualtext(...) "{{{
  let sep = (a:0 == 0) ? "\\n" : a:1

  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let endid = col2 - (&selection == 'inclusive' ? 1 : 2)
  if lnum1 == lnum2 && col1 == 0 && col2 == 0
    return ''
  endif

  let charnum = 1 + strchars(lines[-1][: endid == 0 ? endid : endid -1])
  let lines[-1] = strcharpart(lines[-1],0,charnum)
  let lines[-1] = (strchars(lines[-1]) < charnum) ? lines[-1] . sep : lines[-1]
  let lines[0] = lines[0][col1 - 1:]
  let text=join(lines, sep)
  return text

endfunction "}}}

function! far#tools#replace(text, str, repl) "{{{
    let text = a:text
    let idx = stridx(text, a:str)
    if idx != -1
        let text = text[:idx-1].a:repl.text[idx+len(a:str):]
    endif
    return text
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
