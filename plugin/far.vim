"=================================================
" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far')
    finish
endif

let g:far#window_name = 'FAR'
let g:far#window_right = 1
let g:far#window_width = 100
let g:far#repl_devider = '  >  '

let g:far#buffer_counter = 1

let s:debug = 1
let s:debugfile = $HOME.'/far.vim.log'

if s:debug
    exec 'redir! > ' . s:debugfile
    redir END
endif

function! s:log(msg)
    if s:debug
        exec 'redir >> ' . s:debugfile
        silent echon a:msg."\n"
        redir END
    endif
endfunction

function! Far(pattern, path, replace_with)
    exec 'vimgrep/'.a:pattern.'/gj '.a:path
    let items = getqflist()
    if empty(items)
       return
    endif

    let g:far_context = {
        \ 'pattern': a:pattern,
        \ 'path': a:path,
        \ 'replace_with': a:replace_with,
        \ 'items': {}}

    for item in items
        let ctx_key = ''
        if get(item, 'bufnr') == 0
            let ctx_key = 'f:'.item.filename
        else
            let ctx_key = 'b:'.item.bufnr
        endif

        let file_ctx = get(g:far_context.items, ctx_key, {})
        if file_ctx == {}
            let file_ctx.bufnr = get(item, 'bufnr')
            let file_ctx.filename = get(item, 'filename', '')
            let file_ctx.items = []
            let g:far_context.items[ctx_key] = file_ctx
        endif

        let item_ctx = {}
        let item_ctx.lnum = item.lnum
        let item_ctx.col = item.col
        let item_ctx.text = item.text

        if item.col == 1
            let front = ''
        else
            let front = item.text[0:item.col-2]
        endif
        let matched = item.text[item.col-1:9999]
        let replaced = substitute(matched, a:pattern, a:replace_with, '')
        let item_ctx.repl_text = front.replaced
        call add(file_ctx.items, item_ctx)
    endfor

    call s:open_context()
endfunction

" function! s:apply_buffer_syntax()
"     let syntaxs = getbufvar(bufnr('%'), 'far_syntax')
"     call s:log('-> buf syntaxs: '.string(syntaxs))

"     if !exists('far_syntax')
"         return
"     endif

"     for buf_syn in syntaxs
"         call s:log('-> apply buf syntax: '.buf_syn)
"         exec buf_syn
"     endfor

"     unlet b:far_syntax

" endfunction
" autocmd! BufWinEnter * call s:apply_buffer_syntax()


function! s:open_context()
    if !exists('g:far_context')
        call s:log('no context')
        return
    endif
    if len(g:far_context.items) == 0
        call s:log('empty context result')
        return
    endif

    let content = []
    let syntaxs = []
    for ctx_key in keys(g:far_context.items)
        let ctx = g:far_context.items[ctx_key]

        if ctx_key[0] == 'b'
            let bname = bufname(ctx.bufnr)
            let out = '+ '.bname.' ['.ctx.bufnr.'] ('.len(ctx.items).' matches)'
            let deteils_syn = 'syn match FarFileStats "'.s:escape_regexp(out).'"hs=s+2'
            let file_syn = 'syn match FarFilePath "..'.s:escape_regexp(bname).'"hs=s+2'.
                \   ' containedin=FarFileStats'
            " call add(syntaxs, deteils_syn)
            " call add(syntaxs, file_syn)
            call add(content, out)
        endif

        for item_ctx in ctx.items
            let line_num = len(content)+1

            " Number Column
            let line_num_text = item_ctx.lnum.':'.item_ctx.col
            let line_num_col_text = '  '.line_num_text.repeat(' ', 8-len(line_num_text))
            "syn region FarLineColNmbr start="\%2l^"hs=s+2 end=".\{10\}"he=e-5
            let line_num_col_syn = 'syn region FarLineColNmbr start="\%'.line_num.
                \   'l^"hs=s+2 end=".\{'.(len(line_num_col_text)).'\}"he=e-'.
                \   (len(line_num_col_text)-len(line_num_text)-2)
            call add(syntaxs, line_num_col_syn)

            " Match Column
            let max_text_len = g:far#window_width / 2 - len(line_num_col_text) - 1
            let max_repl_len = g:far#window_width / 2 - len(g:far#repl_devider) - 4
            let match_text = s:limit_text(item_ctx.text, max_text_len, item_ctx.col, 5)

            "syn region FarSearchText start="\%3l^.\{17\}"hs=e+1 end=".\{3\}" contains=FarLineColNmbr keepend
            let match_col_syn = 'syn region FarSearchText start="\%'.line_num.
                \   'l^.\{'.(len(line_num_col_text)+match_text.centr-1).'\}"hs=e+1'.
                \   ' end=".\{3\}" contains=FarLineColNmbr keepend'
            call add(syntaxs, match_col_syn)

            " Replace Column
            let repl_text = s:limit_text(item_ctx.repl_text, max_repl_len, item_ctx.col, 5)
            let repl_col_syn = 'syn region FarReplaceText start="\%'.line_num.'l^.\{'.
                \   (len(line_num_col_text)+len(match_text.text)+len(g:far#repl_devider)+repl_text.centr-1).
                \   '\}"hs=e+1 end=".\{7\}" contains=FarSearchText keepend'
            call add(syntaxs, repl_col_syn)

            let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
            call add(content, out)
        endfor
    endfor

    if g:far#window_right
        let cmd = 'botright vertical '.g:far#window_width.
            \ "new '".g:far#window_name.' '.g:far#buffer_counter."'"
    else
        let cmd = 'topleft vertical '.g:far#window_width.
            \ "new '".g:far#window_name.' '.g:far#buffer_counter."'"
    endif

    let g:far#buffer_counter += 1
    exec 'silent keepalt '.cmd
    let bufnr = last_buffer_nr()
    " call setbufvar(bufnr, 'far_syntax', syntaxs)
    call append(0, content)

    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nobuflisted
    setlocal nospell
    setlocal norelativenumber
    setlocal cursorline
    setlocal nomodifiable
    " setlocal statusline=%!t:undotree.GetStatusLine()
    setfiletype far_vim

    syntax clear
    set syntax=far_vim
    syntax case ignore
    for buf_syn in syntaxs
        call s:log('-> appling '.buf_syn)
        exec buf_syn
    endfor
endfunction

function! s:limit_text(text, limit, centr, shift)
    let text = copy(a:text)
    let centr = a:centr
    if len(text) > a:limit
        if a:centr > a:limit/2
            let left_start = a:centr - a:limit/2 + a:shift
            let centr = a:centr - left_start + 2
            let text = '..'.a:text[left_start:9999]
        endif
    endif
    if len(text) > a:limit
        let text = text[0:a:limit-3].'..'
    else
        let text = text.repeat(' ', a:limit - len(text))
    endif

    return {'text': text, 'centr': centr}
endfunction

function! s:escape_regexp(str)
    let res = escape(a:str, './\[')
    let res = substitute(res, ' ', '\\s', 'g')
    return res
endfunction

function! s:trim_front(input_string)
    return substitute(a:input_string, '^[ \\t]*', '', '')
endfunction

function! s:trim(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" let g:loaded_far = 0
