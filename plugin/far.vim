"=================================================
" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far_vim')
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

    let g:far_vim_context = {
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

        let file_ctx = get(g:far_vim_context.items, ctx_key, {})
        if file_ctx == {}
            let file_ctx.bufnr = get(item, 'bufnr')
            let file_ctx.filename = get(item, 'filename', '')
            let file_ctx.items = []
            let g:far_vim_context.items[ctx_key] = file_ctx
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

function! s:open_context()
    if !exists('g:far_vim_context')
        call s:log('no context')
        return
    endif
    if len(g:far_vim_context.items) == 0
        call s:log('empty context result')
        return
    endif

    let content = []
    for ctx_key in keys(g:far_vim_context.items)
        let ctx = g:far_vim_context.items[ctx_key]

        if ctx_key[0] == 'b'
            let out = '+ '.bufname(ctx.bufnr).' ['.ctx.bufnr.'] ('.len(ctx.items).' matches)'
            call s:log(out)
            call add(content, out)
        endif

        for item_ctx in ctx.items
            let out = '   ('.item_ctx.lnum.':'.item_ctx.col.') '
            let max_text_len = g:far#window_width / 2 - len(out)
            let max_repl_len = g:far#window_width / 2 - len(g:far#repl_devider)

            let form_text = copy(item_ctx.text)
            if len(form_text) > max_text_len
                if item_ctx.col > max_text_len/2
                    let left_start = item_ctx.col - max_text_len/2 + 5
                    let form_text = '..'.s:trim_front(item_ctx.text[left_start:9999])
                endif
            endif
            if len(form_text) > max_text_len
                let form_text = form_text[0:max_text_len-3].'..'
            else
                let form_text = form_text.repeat(' ', max_text_len - len(form_text))
            endif

            let repl_text = item_ctx.repl_text[0:max_repl_len]

            let out = out.form_text.g:far#repl_devider.repl_text
            call s:log(out)
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

    exec 'silent keepalt '.cmd
    let g:far#buffer_counter += 1
    let bufname = last_buffer_nr()
    let winnr = winnr()
    exec 'norm! '.winnr.'\<c-w>\<c-w>'
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

endfunction

function! s:trim_front(input_string)
    return substitute(a:input_string, '^[ \\t]*', '', '')
endfunction

function! s:trim(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" let g:loaded_far_vim = 0
