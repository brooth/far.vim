" File: autoload/far/executors/nvim.vim
" Description: Asynchronous python source executor
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT


let g:far#executors#nvim#contexts = {}
let g:far#executors#nvim#context_idx = 0

function! far#executors#nvim#execute(exec_ctx, callback) abort
    let ctx = a:exec_ctx
    let ctx['async_callback'] = a:callback
    let ctx_idx = g:far#executors#nvim#context_idx
    let g:far#executors#nvim#context_idx += 1
    let g:far#executors#nvim#contexts[ctx_idx] = ctx
    let source = ctx.source.fn
    let idx = strridx(source, '.')
    let sourcectx = json_encode(a:exec_ctx.far_ctx)
    let sourceargs = json_encode(a:exec_ctx.fn_args)
    let sourcecmdargs = json_encode(a:exec_ctx.cmdargs)
    let execlist = [
        \   'mod = importlib.import_module("'.source[:idx-1].'")',
        \   'res = mod.'.source[idx+1:]."(".sourcectx.", ".sourceargs.",".sourcecmdargs.")",
        \   'self.nvim.command("call far#executors#nvim#callback("+str(res)+", '.ctx_idx.')")',
        \   ]

    call far#rpc#nvim_invoke(execlist)
endfunction

function! far#executors#nvim#callback(result, ctx_idx) abort
    let ctx = remove(g:far#executors#nvim#contexts, a:ctx_idx)
    let error = get(a:result, 'error', '')
    if !empty(error)
        let ctx['error'] = 'source error: '.error
    elseif get(a:result, 'items_file', '') != ''
        let ctx.far_ctx.items = []
        try
            for line in readfile(a:result.items_file, '')
                call far#tools#log('json:'.string(json_decode(line)))
                call add(ctx.far_ctx.items, json_decode(line))
            endfor
        catch
            call far#tools#log('read items_file error:'.string(v:exception))
            let ctx['error'] = 'read items_file error'.string(v:exception)
        endtry
    else
        let ctx.far_ctx['items'] = a:result['items']

        "https://github.com/brooth/far.vim/issues/31
        for file_ctx in ctx.far_ctx['items']
            for item_ctx in file_ctx.items
                let item_ctx.text = substitute(item_ctx.text, '\\\\', '\\', 'g')
            endfor
        endfor
    endif
    call call(ctx.async_callback, [ctx])
endfunction

" vim: set et fdm=marker sts=4 sw=4:
