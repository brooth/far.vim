" File: ag.vim
" Description: Ag (silver searcher) source for far.vim
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT


function! far#sources#ag#search(ctx) abort "{{{
    call a:ctx.logger('ag#search('.a:ctx.pattern.','.a:ctx.file_mask.')')

    if !executable('ag')
        echoerr 'ag not executable'
        return {}
    endif

    let tmpfile = tempname()
    try
        let cmd = 'silent! !ag --nogroup --column --nocolor '.
            \   escape(a:ctx.pattern, ' ').' '.a:ctx.file_mask.' > '.tmpfile
        call a:ctx.logger('ag cmd: '.cmd)
        exec cmd
    catch /.*/
        call a:ctx.logger('ag error:'.v:exception)
        throw v:exception
    endtry

    if filereadable(tmpfile)
        try
            let lines = readfile(tmpfile)
        catch /.*/
            call a:ctx.logger('read ag result file error:'.v:exception)
            throw v:exception
        endtry
    else
        call a:ctx.logger('file not readable '.tmpfile)
        return []
    endif

    let result = {}
    for line in lines
        let idx1 = stridx(line, ':')
        let fname = line[:idx1-1]

        let file_ctx = get(result, fname, {})
        if empty(file_ctx)
            let file_ctx.fname = fname
            let file_ctx.items = []
            let result[fname] = file_ctx
        endif

        let idx2 = stridx(line, ':', idx1+1)
        let idx3 = stridx(line, ':', idx2+1)
        let item_ctx = {}
        let item_ctx.lnum = str2nr(line[idx1+1:idx2-1])
        let item_ctx.cnum = str2nr(line[idx2+1:idx3-1])
        let item_ctx.text = line[idx3+1:]
        call add(file_ctx.items, item_ctx)
    endfor
    return values(result)
endfunction "}}}
