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
    let undonum = changenr()
    let curhead = 0
    for undoentry in reverse(undotree().entries)
        if curhead
            call far#tools#log('undo seq:'.undoentry.seq)
            let undonum = undoentry.seq
            break
        endif
        let curhead = get(undoentry, 'curhead', 0)
    endfor
    return undonum
endfunction "}}}

function! far#tools#splitcmd(cmdline) "{{{
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
    let text = copy(a:text)
    let val_col = a:val_col
    let val_idx = a:val_col
    if strchars(text) > a:width && a:val_col > a:width/2 - 7
        let left_start = a:val_col - a:width/2 + 7
        let val_col = a:val_col - left_start + strchars(g:far#cut_text_sign)
        let val_idx = a:val_col - left_start + len(g:far#cut_text_sign)
        let text = g:far#cut_text_sign.text[left_start:]
    endif
    if strchars(text) > a:width
        let wtf = -1-(len(text)-strchars(text))
        let text = text[0:a:width-len(g:far#cut_text_sign)-wtf].g:far#cut_text_sign
    endif
    if strchars(text) < a:width
        let text = text.repeat(' ', a:width - strchars(text))
    endif

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
    echohl None
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

function! far#tools#visualtext() "{{{
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\\n")
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
