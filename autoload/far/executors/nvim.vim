" File: autoload/far/executors/nvim.vim
" Description: Asynchronous python executor
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! far#executors#nvim#execute(exec_ctx, callback) abort "{{{
    let ctx = a:exec_ctx
    if empty(get(ctx.source, 'py', ''))
        let ctx['error'] = 'given source is not support async execution'
        call call(a:callback, [ctx])
        return
    endif

    call far#tools#log('>>>'.json_encode(a:exec_ctx.far_ctx))
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
