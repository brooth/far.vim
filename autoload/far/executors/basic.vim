" File: autoload/far/executors/basic.vim
" Description: Synchronous vimscript executor
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! far#executors#basic#execute(exec_ctx, callback) abort
    let ctx = a:exec_ctx
    let ctx.far_ctx['items'] = call(function(a:exec_ctx.source.fn), [ctx.far_ctx, ctx.fn_args])
    call call(a:callback, [ctx])
endfunction

" vim: set et fdm=marker sts=4 sw=4:
