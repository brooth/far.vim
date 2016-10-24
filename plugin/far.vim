" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far') "{{{
    finish
endif "}}}


" TODOs {{{
"TODO X - toogle excluded ALL
"TODO confirm Fardo: Replace 67 matches in 5 files? (option...)
"TODO readonly buffers? not saved buffers?
"TODO far redo (repeate same far)
"TODO zc & zo for expanding
"TODO config window (top, left, right, buttom, current)
"TODO preview window (none, top, left, right, buttom, current)
"TODO auto colaps if more than x buffers. items...
"TODO support Nx - N excludes in a row
"TODO async for neovim
"TODO support alternative providers (not vimgrep)
"TODO support alternative replacers
"TODO statusline (done in Xms stat, number of matches)
"TODO u - undo excluded items (redo, multiple (after visual select))
"}}}


" options {{{
let g:far#window_width = 110
let g:far#repl_devider = '  ➝  '
let g:far#left_cut_text_sigh = '…'
let g:far#right_cut_text_sigh = '…'
let g:far#auth_close_replaced_buffers = 0
let g:far#auth_write_replaced_buffers = 1

let g:far#window_name = 'FAR'
let g:far#buffer_counter = 1

let s:debug = 1
let s:debugfile = $HOME.'/far.vim.log'
"}}}


"logging {{{
if s:debug
    exec 'redir! > ' . s:debugfile
    redir END
endif

function! s:log(msg)
    if s:debug
        exec 'redir >> ' . s:debugfile
        silent echon a:msg."\n"
        redir END
    endif
endfunction
"}}}


function! Far(pattern, replace_with, files_mask) abort "{{{
    call s:log('=============== FAR ================')
    call s:log('fargs: '.a:pattern.','. a:replace_with.', '.a:files_mask)

    let far_ctx = s:assemble_context(a:pattern, a:replace_with, a:files_mask)
    if empty(far_ctx)
        let pattern = input('No match: "'.a:pattern.'". Repeat?: ', a:pattern)
        if empty(pattern)
            return
        endif
        return Far(pattern, a:replace_with, a:files_mask)
    endif
    call s:open_far_buffer(far_ctx)
endfunction
command! -nargs=+ Far call Far(<f-args>)
"}}}


function! FarPrompt() abort "{{{
    call s:log('============ FAR PROMPT ================')
    let g:far_prompt_pattern = input('Search (pattern): ',
        \   (exists('g:far_prompt_pattern')? g:far_prompt_pattern : ''))
    if g:far_prompt_pattern == ''
        call s:echo_err('Empty search pattern')
        return []
    endif

    let g:far_prompt_replace_with = input('Replace with: ',
        \   (exists('g:far_prompt_replace_with')? g:far_prompt_replace_with : ''))
    if g:far_prompt_replace_with == ''
        call s:echo_err('Empty replace pattern')
        return []
    endif

    let g:far_prompt_files_mask = input('File mask: ',
        \   (exists('g:far_prompt_files_mask')? g:far_prompt_files_mask : '**/*.*'))
    if g:far_prompt_files_mask == ''
        call s:echo_err('Empty files mask')
        return []
    endif

    call Far(g:far_prompt_pattern, g:far_prompt_replace_with, g:far_prompt_files_mask)
endfunction
command! -nargs=0 Farp call FarPrompt()
"}}}


function! FarDo() abort "{{{
    call s:log('============= FAR DO ================')
    let bufnr = bufnr('%')
    let far_ctx = getbufvar(bufnr, 'far_ctx', {})
    if empty(far_ctx)
        call s:echo_err('Not a FAR buffer!')
        return
    endif

    call s:do_replece(far_ctx)
endfunction
command! -nargs=0 Fardo call FarDo()
"}}}


function! g:far#toogle_expand_under_cursor() abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = getbufvar(bufnr, 'far_ctx', {})
    if empty(far_ctx)
        echoerr 'far context not found for current buffer'
        return
    endif

    let pos = getcurpos()[1]
    let index = 0
    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let index += 1
        let buf_curpos = index
        let toogle_expand = 0
        if pos == index
            let toogle_expand = 1
        elseif buf_ctx.expanded
            for item_ctx in buf_ctx.items
                let index += 1
                if pos == index
                    let toogle_expand = 1
                    break
                endif
            endfor
        endif
        if toogle_expand
            let buf_ctx.expanded = buf_ctx.expanded == 0 ? 1 :0
            call setbufvar('%', 'far_ctx', far_ctx)
            call s:update_far_buffer(bufnr)
            exec 'norm! '.buf_curpos.'gg'
            return
        endif
    endfor

    echoerr 'no far ctx item found under cursor '.pos
endfunction "}}}


function! g:far#toogle_exclude_under_cursor() abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = getbufvar(bufnr, 'far_ctx', {})
    if empty(far_ctx)
        echoerr 'far context not found for current buffer'
        return
    endif

    let pos = getcurpos()[1]
    call s:toogle_expand(far_ctx, bufnr, pos)
endfunction "}}}


function! s:toogle_expand(far_ctx, bufnr, pos) abort "{{{
    let index = 0
    for k in keys(a:far_ctx.items)
        let buf_ctx = a:far_ctx.items[k]
        let index += 1
        if a:pos == index
            for item_ctx in buf_ctx.items
                let item_ctx.excluded = item_ctx.excluded == 0 ? 1 : 0
            endfor
            call setbufvar('%', 'far_ctx', a:far_ctx)
            call s:update_far_buffer(a:bufnr)
            return
        endif

        if buf_ctx.expanded
            for item_ctx in buf_ctx.items
                let index += 1
                if a:pos == index
                    let item_ctx.excluded = item_ctx.excluded == 0 ? 1 : 0
                    call setbufvar('%', 'far_ctx', a:far_ctx)
                    call s:update_far_buffer(a:bufnr)
                    exec 'norm! j'
                    return
                endif
            endfor
        endif
    endfor
endfunction "}}}


function! s:do_replece(far_ctx) abort "{{{
    call s:log('do_replece('.a:far_ctx.pattern.', '.a:far_ctx.replace_with.
        \   ', '.a:far_ctx.files_mask.')')
    call s:log(' -far#auth_close_replaced_buffers: '.g:far#auth_close_replaced_buffers)
    call s:log(' -far#auth_write_replaced_buffers: '.g:far#auth_write_replaced_buffers)

    let bufnr = bufnr('%')
    let repl_files = 0
    let repl_errors = 0
    let repl_matches = 0
    let close_buffs = []
    arglocal
    for k in keys(a:far_ctx.items)
        let ctx = a:far_ctx.items[k]
        call s:log('replacing buffer '.ctx.bufnr.' '.ctx.bufname)

        let cmds = []
        for item_ctx in ctx.items
            if item_ctx.excluded
                continue
            endif
            let cmd = item_ctx.lnum.'gg0'.(item_ctx.col-1 > 0? item_ctx.col-1.'l' : '').
                \   'd'.strchars(item_ctx.match_val).'l'.
                \   'i'.item_ctx.repl_val.''
            call s:log('cmd: '.cmd)
            call add(cmds, cmd)
        endfor

        if empty(cmds)
            call s:log('no commands for buffer '.ctx.bufnr)
        else
            let cmd = join(cmds)
            call s:log('argdo: '.cmd)

            try
                exec 'argadd '.ctx.bufname
                exec 'silent! argdo! norm!'.join(cmds)
                exec 'argdelete '.ctx.bufname
            catch /.*/
                call s:log('failed to replace in buffer '.ctx.bufnr.', error: '.v:exception)
                let repl_errors += 1
                continue
            endtry

            let repl_files += 1
            if g:far#auth_write_replaced_buffers
                call s:log('writing buffer: '.ctx.bufnr)
                exec 'w'
            endif
            if g:far#auth_close_replaced_buffers && g:far#auth_write_replaced_buffers &&
                        \   !bufloaded(ctx.bufnr)
                call add(close_buffs, ctx.bufnr)
            endif
        endif
    endfor

    if !empty(close_buffs)
        let cbufs = join(close_buffs)
        call s:log('closing buffers: '.cbufs)
        exec 'bd '.cbufs
    endif

    return {'files': repl_files, 'matches': repl_matches, 'errors': repl_errors}
endfunction "}}}


function! s:assemble_context(pattern, replace_with, files_mask) abort "{{{
    call s:log('assemble_context(): '.string([a:pattern, a:replace_with, a:files_mask]))

    let qfitems = getqflist()
    try
        silent exec 'vimgrep/'.a:pattern.'/gj '.a:files_mask
    catch /.*/
        call s:log('vimgrep error:'.v:exception)
    endtry

    let items = getqflist()
    call setqflist(qfitems, 'r')

    if empty(items)
        return {}
    endif

    let far_ctx = {
                \ 'pattern': a:pattern,
                \ 'files_mask': a:files_mask,
                \ 'replace_with': a:replace_with,
                \ 'items': {}}

    for item in items
        if get(item, 'bufnr') == 0
            call s:log('item '.item.text.' has no bufnr')
            continue
        endif

        let buf_ctx = get(far_ctx.items, item.bufnr, {})
        if empty(buf_ctx)
            let buf_ctx.bufnr = item.bufnr
            let buf_ctx.bufname = bufname(item.bufnr)
            let buf_ctx.expanded = 1
            let buf_ctx.readonly = 0
            let buf_ctx.items = []
            let far_ctx.items[item.bufnr] = buf_ctx
        endif

        let item_ctx = {}
        let item_ctx.lnum = item.lnum
        let item_ctx.col = item.col
        let item_ctx.excluded = 0
        let item_ctx.match_val = matchstr(item.text, a:pattern, item.col-1)
        let item_ctx.repl_val = substitute(item_ctx.match_val, a:pattern, a:replace_with, "")
        let item_ctx.match_text = item.text
        if item.col == 1
            let front = ''
        else
            let front = item.text[0:item.col-2]
        endif
        let item_ctx.repl_text = front.substitute(item.text[item.col-1:],
            \    item_ctx.match_val, item_ctx.repl_val, '')
        call add(buf_ctx.items, item_ctx)
    endfor
    return far_ctx
endfunction "}}}


function! s:build_buffer_content(far_ctx) abort "{{{
    if len(a:far_ctx.items) == 0
        call s:log('empty context result')
        return
    endif

    let content = []
    let syntaxs = []
    let line_num = 0
    for ctx_key in keys(a:far_ctx.items)
        let ctx = a:far_ctx.items[ctx_key]
        let line_num += 1

        let num_excluded = 0
        for item_ctx in ctx.items
            if item_ctx.excluded
                let num_excluded += 1
            endif
        endfor

        if num_excluded < len(ctx.items)
            let bname_syn = 'syn region FarFilePath start="\%'.line_num.
                        \   'l^.."hs=s+2 end=".\{'.(strchars(ctx.bufname)).'\}"'
            call add(syntaxs, bname_syn)
            let bstats_syn = 'syn region FarFileStats start="\%'.line_num.'l^.\{'.
                \   (strchars(ctx.bufname)+3).'\}"hs=e end="$" contains=FarFilePath keepend'
            call add(syntaxs, bstats_syn)
        else
            let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
            call add(syntaxs, excl_syn)
        endif

        if ctx.expanded
            let expand_sign = '-'
        else
            let expand_sign = '+'
        endif

        let out = expand_sign.' '.ctx.bufname.' ['.ctx.bufnr.'] ('.(len(ctx.items)-num_excluded).' matches)'
        call add(content, out)

        if ctx.expanded == 0
            continue
        endif

        for item_ctx in ctx.items
            let line_num += 1
            let line_num_text = item_ctx.lnum.':'.item_ctx.col
            let line_num_col_text = '  '.line_num_text.repeat(' ', 8-strchars(line_num_text))
            let max_text_len = g:far#window_width / 2 - strchars(line_num_col_text) - 1
            let max_repl_len = g:far#window_width / 2 - strchars(g:far#repl_devider) - 4
            let match_text = s:cetrify_text(item_ctx.match_text, max_text_len, item_ctx.col)
            let repl_text = s:cetrify_text(item_ctx.repl_text, max_repl_len, item_ctx.col)
            let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
            call add(content, out)

            " Syntax
            if item_ctx.excluded
                let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
                call add(syntaxs, excl_syn)
            else
                let match_col = match_text.val_col
                let repl_col = strchars(match_text.text) + strchars(g:far#repl_devider) + repl_text.val_col -
                            \    match_col - strchars(item_ctx.match_val)
                let repl_col_wtf = len(match_text.text) + len(g:far#repl_devider) + repl_text.val_col -
                            \    match_col - len(item_ctx.match_val)
                let line_syn = 'syn region FarItem matchgroup=FarSearchVal '.
                            \   'start="\%'.line_num.'l\%'.strchars(line_num_col_text).'c"rs=s+'.
                            \   (match_col+strchars(item_ctx.match_val)).
                            \   ',hs=s+'.match_col.' matchgroup=FarReplaceVal end=".*$"re=s+'.
                            \   repl_col_wtf.',he=s+'.(repl_col+strchars(item_ctx.repl_val)-1).
                            \   ' oneline'
                call add(syntaxs, line_syn)
            endif
        endfor
    endfor

    return {'content': content, 'syntaxs': syntaxs}
endfunction "}}}


function! s:open_far_buffer(far_ctx) abort "{{{
    let bufname = g:far#window_name.' '.g:far#buffer_counter
    let bufnr = bufnr(bufname)
    if bufnr != -1
        let g:far#buffer_counter += 1
        call s:open_far_buffer(a:far_ctx)
        return
    endif

    let win_layout ='botright vertical '.g:far#window_width
    exec 'silent keepalt '.win_layout.'new '.g:far#window_name.'\ '.g:far#buffer_counter
    let bufnr = last_buffer_nr()
    let g:far#buffer_counter += 1

    setlocal noswapfile
    setlocal buftype=nowrite
    " setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nospell
    setlocal norelativenumber
    setlocal cursorline
    setfiletype far_vim

    nnoremap <buffer><silent> x :call g:far#toogle_exclude_under_cursor()<cr>
    nnoremap <buffer><silent> o :call g:far#toogle_expand_under_cursor()<cr>
    vnoremap <buffer><silent> x :call g:far#toogle_exclude_under_cursor()<cr>

    call setbufvar(bufnr, 'far_ctx', a:far_ctx)
    call s:update_far_buffer(bufnr)
endfunction "}}}


function! s:update_far_buffer(bufnr) abort "{{{
    let winnr = bufwinnr(a:bufnr)
    if winnr == -1
        echoerr 'far buffer not open'
        return
    endif

    let far_ctx = getbufvar(a:bufnr, 'far_ctx', {})
    if empty(far_ctx)
        echoerr 'far context not found for current buffer'
        return
    endif
    let buff_content = s:build_buffer_content(far_ctx)

    if winnr != winnr()
        exec 'norm! '.winnr.'\<c-w>\<c-w>'
    endif

    let pos = winsaveview()
    setlocal modifiable
    exec 'norm! ggdG'
    call append(0, buff_content.content)
    exec 'norm! Gdd'
    call winrestview(pos)
    setlocal nomodifiable

    syntax clear
    set syntax=far_vim
    for buf_syn in buff_content.syntaxs
        call s:log('apply syntax: '.buf_syn)
        exec buf_syn
    endfor
endfunction "}}}


function! s:cetrify_text(text, width, val_col) abort "{{{
    let text = copy(a:text)
    let val_col = a:val_col
    if strchars(text) > a:width && a:val_col > a:width/2 - 7
        let left_start = a:val_col - a:width/2 + 7
        let val_col = a:val_col - left_start + strchars(g:far#left_cut_text_sigh)
        let text = g:far#left_cut_text_sigh.text[left_start:]
    endif
    if strchars(text) > a:width
        let wtf = -1-(len(text)-strchars(text))
        let text = text[0:a:width-len(g:far#right_cut_text_sigh)-wtf].g:far#right_cut_text_sigh
    endif
    if strchars(text) < a:width
        let text = text.repeat(' ', a:width - strchars(text))
    endif

    return {'text': text, 'val_col': val_col}
endfunction "}}}


function! s:echo_err(msg) abort "{{{
    execute 'normal! \<Esc>'
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction "}}}


function! s:exec_silent(cmd) abort "{{{
    call s:log("s:exec_silent() ".a:cmd)
    let ei_bak= &eventignore
    set eventignore=BufEnter,BufLeave,BufWinLeave,InsertLeave,CursorMoved,BufWritePost
    silent exe a:cmd
    let &eventignore = ei_bak
endfunction "}}}


" let g:loaded_far = 0

" vim: set et fdm=marker sts=4 sw=4:
