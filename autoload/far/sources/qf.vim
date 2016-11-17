" File: qf.vim
" Description: quick fix source for far.vim
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT


function! far#sources#qf#search(ctx, fargs, cmdargs) abort "{{{
    call far#tools#log('qf.search('.a:ctx.pattern.','.a:ctx.file_mask.
        \   ','.string(a:fargs).','.string(a:cmdargs).')')

    let cmd = get(a:fargs, 'cmd', '')
    if empty(cmd)
        return {'error': 'no cmd in args'}
    endif

    let backcwd = getcwd()
    if backcwd != a:ctx['cwd']
        try
            exec 'cd '.a:ctx['cwd']
        catch
            return {'error': string(v:exception)}
        endtry
        unlet backcwd
    endif

    let pattern = a:ctx.pattern
    let escape_pattern = get(a:fargs, 'escape_pattern', '')
    if !empty(escape_pattern)
         let pattern = escape(pattern, escape_pattern)
    endif

    let cmd = far#tools#replace(cmd, '{pattern}', pattern)
    let cmd = far#tools#replace(cmd, '{file_mask}', a:ctx.file_mask)
    let cmd = far#tools#replace(cmd, '{limit}', a:ctx.limit)
    let cmd = far#tools#replace(cmd, '{args}', join(a:cmdargs, ''))
    call far#tools#log('qfcmd: '.cmd)

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
        return {'items':[]}
    elseif len(items) > a:ctx.limit
        let items = items[:a:ctx.limit-1]
    endif

    let result = {}
    for item in items
        if get(item, 'bufnr') == 0
            call far#tools#log('item '.item.text.' has no bufnr')
            continue
        endif

        if (a:ctx.range[0] != -1 && a:ctx.range[0] > item.lnum) ||
                \   (a:ctx.range[1] != -1 && a:ctx.range[1] < item.lnum)
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
    return {'items': values(result)}
endfunction "}}}
