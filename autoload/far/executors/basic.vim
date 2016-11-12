" File: autoload/far/executors/basic.vim
" Description: Synchronous vimscript executor
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! far#executors#basic#execute(exec_ctx, callback) abort "{{{
    let ctx = a:exec_ctx
    if empty(get(ctx.source, 'vim', ''))
        let ctx['error'] = 'given source is not support basic execution'
        call call(a:callback, [ctx])
        return
    endif

    let ctx.far_ctx['items'] = call(function(ctx.source.vim), [ctx.far_ctx])
    call call(a:callback, [ctx])
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
