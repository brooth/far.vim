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
        let ctx['error'] = 'source error: '.error
    elseif get(result, 'items_file', '') != ''
        let ctx.far_ctx.items = []
        try
            for line in readfile(result.items_file, '')
                call far#tools#log('json:'.string(json_decode(line)))
                call add(ctx.far_ctx.items, json_decode(line))
            endfor
        catch
            call far#tools#log('read items_file error:'.string(v:exception))
            let ctx['error'] = 'read items_file error'.string(v:exception)
        endtry
    else
        let ctx.far_ctx['items'] = result['items']
    endif
    call call(a:callback, [ctx])
endfunction

" vim: set et fdm=marker sts=4 sw=4:
