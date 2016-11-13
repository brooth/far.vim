" File: autoload/far/executors/basic.vim
" Description: Synchronous vimscript executor
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! far#executors#basic#execute(exec_ctx, callback) abort
    let ctx = a:exec_ctx
    let result = call(function(a:exec_ctx.source.fn), [ctx.far_ctx, ctx.fn_args, ctx.cmdargs])
    let error = get(result, 'error', '')
    if !empty(error)
        let ctx['error'] = 'source error:'.error
    else
        let ctx.far_ctx['items'] = result['items']
    endif
    call call(a:callback, [ctx])
endfunction

" vim: set et fdm=marker sts=4 sw=4:
