" File: qf.vim
" Description: quick fix source for far.vim
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT


function! far#sources#qf#search(ctx, fargs) abort "{{{
    call far#tools#log('qf.search('.a:ctx.pattern.','.a:ctx.file_mask.','.string(a:fargs).')')

    let cmd = get(a:fargs, 'cmd', '')
    if empty(cmd)
        return {'error': 'no cmd in args'}
    endif
    let cmd = substitute(cmd, '{pattern}', a:ctx.pattern, '')
    let cmd = substitute(cmd, '{file_mask}', a:ctx.file_mask, '')
    let cmd = substitute(cmd, '{limit}', a:ctx.limit, '')
    let cmd = substitute(cmd, '{args}', '', '')
    call far#tools#log('qfcmd: '.cmd)

    let backcwd = getcwd()
    if backcwd != a:ctx['cwd']
        try
            exec 'cd '.a:ctx['cwd']
        catch
            return {'error': string(v:exception)}
        endtry
        unlet backcwd
    endif

    try
        exec cmd
    catch
        call far#tools#log('qfcmd error:'.v:exception)
        return {'error': string(v:exception)}
    endtry

    if exists('backcwd')
        exec 'cd '.backcwd
    endif

    let items = getqflist()
    if empty(items)
        return {}
    elseif len(items) > a:ctx.limit
        let items = items[:a:ctx.limit-1]
    endif

    let result = {}
    for item in items
        if get(item, 'bufnr') == 0
            call far#tools#log('item '.item.text.' has no bufnr')
            continue
        endif

        let file_ctx = get(result, item.bufnr, {})
        if empty(file_ctx)
            let file_ctx.fname = bufname(item.bufnr)
            let file_ctx.items = []
            let result[item.bufnr] = file_ctx
        endif

        let item_ctx = {}
        let item_ctx.lnum = item.lnum
        let item_ctx.cnum = item.col
        let item_ctx.text = item.text
        call add(file_ctx.items, item_ctx)
    endfor
    return {'items': values(result)
endfunction "}}}
