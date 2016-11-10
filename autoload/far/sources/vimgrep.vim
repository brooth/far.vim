" File: vimgrep.vim
" Description: vimgrep source for far.vim
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT


function! far#sources#vimgrep#search(ctx) abort "{{{
    call a:ctx.logger('vimgrep_source('.a:ctx.pattern.','.a:ctx.file_mask.')')

    try
        let cmd = 'silent! vimgrep! /'.escape(a:ctx.pattern, '/').'/gj '.a:ctx.file_mask
        call a:ctx.logger('vimgrep cmd: '.cmd)
        exec cmd
    catch /.*/
        call a:ctx.logger('vimgrep error:'.v:exception)
    endtry

    let items = getqflist()
    if empty(items)
        return {}
    endif

    let result = {}
    for item in items
        if get(item, 'bufnr') == 0
            call a:ctx.logger('item '.item.text.' has no bufnr')
            continue
        endif

        let buf_ctx = get(result, item.bufnr, {})
        if empty(buf_ctx)
            let buf_ctx.bufnr = item.bufnr
            let buf_ctx.bufname = bufname(item.bufnr)
            let buf_ctx.items = []
            let result[item.bufnr] = buf_ctx
        endif

        let item_ctx = {}
        let item_ctx.lnum = item.lnum
        let item_ctx.cnum = item.col
        let item_ctx.text = item.text
        call add(buf_ctx.items, item_ctx)
    endfor
    return result
endfunction "}}}
