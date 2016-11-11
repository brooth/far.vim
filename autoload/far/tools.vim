" File: autoload/far/tools.vim
" Description: far.vim utils
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

"logging {{{
let s:debug = exists('g:far#debug')? g:far#debug : 0
let s:debugfile = $HOME.'/far.vim.log'

if s:debug
    exec 'redir! > ' . s:debugfile
    silent echon "debug enabled!\n"
    redir END
endif

function! far#tools#isdebug()
    return s:debug
endfunction

function! far#tools#log(msg)
    if s:debug
        exec 'redir >> ' . s:debugfile
        silent echon a:msg."\n"
        redir END
    endif
endfunction
"}}}

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
    let slashes = split(a:cmdline, '\\\\')
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
                call add(cmds, a:cmdline[p1:p2-1])
                let p1 = p2+1
            else
                break
            endif
        endwhile
        let slash_weight += len(slash)
        let idx += 1
    endfor
    call add(cmds, a:cmdline[p1:])
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
    let matching = filter(split(execute('autocmd filetypedetect'), "\n"), 'v:val =~ "\*\.'.a:ext.'setf"')

    if len(matching) > 0
        return matchstr(matching[0], 'setf\s\+\zs\k\+')
    endif
    return 'txt'
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
