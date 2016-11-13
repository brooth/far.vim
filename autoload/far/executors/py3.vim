" File: autoload/far/executors/py.vim
" Description: Synchronous python executor
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! far#executors#py3#execute(exec_ctx, callback) abort
    let ctx = a:exec_ctx
    let source = ctx.source.fn
    let idx = strridx(source, '.')
    let sourcectx = json_encode(a:exec_ctx.far_ctx)
    let sourceargs = json_encode(a:exec_ctx.fn_args)
    let sourcecmdargs = json_encode(a:exec_ctx.cmdargs)
    let evalstr = source."(".sourcectx.",".sourceargs.",".sourcecmdargs.")"
    let result = far#rpc#invoke([source[:idx-1]], evalstr)
    let error = get(result, 'error', '')
    if !empty(error)
        let ctx['error'] = 'source error:'.error
    else
        let ctx.far_ctx['items'] = result['items']
    endif
    call call(a:callback, [ctx])
endfunction

" vim: set et fdm=marker sts=4 sw=4:
