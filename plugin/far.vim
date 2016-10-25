" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far') "{{{
    finish
endif "}}}


" TODOs {{{
"TODO preview window (none, top, left, right, buttom, current)
"TODO pass win args as params
"TODO update buff on win resize
"TODO Faredo (repeate same far in same window)
"TODO auto colaps if more than x buffers. items...
"TODO keep file highlight? change bg color to highlight?
"TODO r - change item result
"TODO support far for visual selected lines?!?!?!
"TODO support N[i,x,c] - do N times
"TODO readonly buffers? not saved buffers? modified (after search)?
"TODO check consistancy timer
"TODO wildmenu for args
"TODO async for neovim
"TODO statusline (done in Xms stat, number of matches)
"TODO support alternative providers (not vimgrep)
"TODO support alternative replacers
"TODO pass providers as params (Farp as well)
"TODO python rename provider (tags? rope? jedi?)
"TODO nested ctxs? for dirs? for python package/module/class/method
"TODO u - undo excluded items (redo, multiple (after visual select))
"}}}


" options {{{
let g:far#details_mappings = 1
let g:far#repl_devider = '  ➝  '
let g:far#left_cut_text_sigh = '…'
let g:far#right_cut_text_sigh = '…'
let g:far#auth_close_replaced_buffers = 0
let g:far#auth_write_replaced_buffers = 0
"let g:far#check_buff_consistency = 1
let g:far#confirm_fardo = 0

let g:far#window_width = 115
let g:far#window_height = 25
"(top, left, right, bottom, tab, current)
let g:far#window_layout = 'right'

let g:far#jump_window_width = 60
let g:far#jump_window_height = 15
let g:far#jump_window_layout = 'bottom'
"}}}


" vars {{{
let s:far_buffer_name = 'FAR'
let s:buffer_counter = 1

let s:debug = 1
let s:debugfile = $HOME.'/far.vim.log'
let s:repl_do_pre_cmd = 'zR :let g:far#__readonlytest__ = &readonly || !&modifiable'
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


function! g:far#apply_default_mappings() abort "{{{
    call s:log('apply_default_mappings()')

    nnoremap <buffer><silent> o :call g:far#change_expand_under_cursor(-1)<cr>
    nnoremap <buffer><silent> zo :call g:far#change_expand_under_cursor(1)<cr>
    nnoremap <buffer><silent> zc :call g:far#change_expand_under_cursor(0)<cr>
    nnoremap <buffer><silent> O :call g:far#change_expand_all(-1)<cr>
    nnoremap <buffer><silent> zR :call g:far#change_expand_all(1)<cr>
    nnoremap <buffer><silent> zM :call g:far#change_expand_all(0)<cr>

    nnoremap <buffer><silent> x :call g:far#change_exclude_under_cursor(1)<cr>
    vnoremap <buffer><silent> x :call g:far#change_exclude_under_cursor(1)<cr>
    nnoremap <buffer><silent> i :call g:far#change_exclude_under_cursor(0)<cr>
    vnoremap <buffer><silent> i :call g:far#change_exclude_under_cursor(0)<cr>
    nnoremap <buffer><silent> t :call g:far#change_exclude_under_cursor(-1)<cr>
    vnoremap <buffer><silent> t :call g:far#change_exclude_under_cursor(-1)<cr>

    nnoremap <buffer><silent> X :call g:far#change_exclude_all(1)<cr>
    nnoremap <buffer><silent> I :call g:far#change_exclude_all(0)<cr>
    nnoremap <buffer><silent> T :call g:far#change_exclude_all(-1)<cr>

    nnoremap <buffer><silent> <cr> :call g:far#jump_buffer_under_cursor()<cr>

endfunction "}}}


function! Far(pattern, replace_with, files_mask) abort "{{{
    call s:log('=============== FAR ================')
    call s:log('fargs: '.a:pattern.','. a:replace_with.', '.a:files_mask)

    let files_mask = a:files_mask
    if files_mask == '%'
        let files_mask = bufname('%')
    endif

    let far_ctx = s:assemble_context(a:pattern, a:replace_with, files_mask)
    if empty(far_ctx)
        let pattern = input('No match: "'.a:pattern.'". Repeat?: ', a:pattern)
        if empty(pattern)
            return
        endif
        return Far(pattern, a:replace_with, files_mask)
    endif
    call s:open_far_buff(far_ctx, g:far#window_layout)
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

    if g:far#confirm_fardo
        let files = 0
        let matches = 0
        for bufctx in values(far_ctx.items)
            let excludes = 0
            for item in bufctx.items
                if !item.excluded
                    let excludes += 1
                endif
            endfor
            if !empty(excludes)
                let files += 1
                let matches += excludes
            endif
        endfor
        let answ = confirm('Replace '.matches.' matche(s) in '.files.' file(s)?', "&Yes\n&No")
        if answ != 1
            return
        endif
    endif

    let result = s:do_replece(far_ctx)
    if empty(result)
        return
    endif

    echomsg 'Done in '.result.time.'sec. '.result.matches.' replacements in '.result.files.' file(s). '.
                \   (empty(result.skipped)? '' : result.skipped.' file(s) skipped!')
endfunction
command! -nargs=0 Fardo call FarDo()
"}}}


function! g:far#jump_buffer_under_cursor() abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)
    let pos = getcurpos()[1]
    let index = 0
    let jump_ctx = {}
    let jump_pos = []
    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let index += 1
        if pos == index
            let jump_ctx = buf_ctx
            break
        endif

        if buf_ctx.expanded
            for item_ctx in buf_ctx.items
                let index += 1
                if pos == index
                    let jump_ctx = buf_ctx
                    let jump_pos = [item_ctx.lnum, item_ctx.cnum]
                    break
                endif
            endfor
            if jump_ctx != {}
                break
            endif
        endif
    endfor

    if jump_ctx != {}
        let winnr = bufwinnr(jump_ctx.bufnr)
        if winnr == -1
            exec s:get_new_buf_layout(g:far#jump_window_layout, jump_ctx.bufname,
                \   g:far#jump_window_width, g:far#jump_window_height)
        else
            exec 'norm! '.winnr.''
        endif
        if !empty(jump_pos)
            exec 'norm! '.jump_pos[0].'gg0'.(jump_pos[1]-1).'lzv'
        endif
        return
    endif

    echoerr 'no far ctx item found under cursor '.pos
endfunction "}}}


function! g:far#change_expand_all(cmode) abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let buf_ctx.expanded = a:cmode == -1? (buf_ctx.expanded == 0? 1 : 0) : a:cmode
    endfor

    let pos = getcurpos()[1]
    call setbufvar('%', 'far_ctx', far_ctx)
    call s:update_far_buffer(bufnr)
    exec 'norm! '.pos.'gg'
endfunction "}}}


function! g:far#change_expand_under_cursor(cmode) abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    let pos = getcurpos()[1]
    let index = 0
    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let index += 1
        let buf_curpos = index
        let this_buf = 0
        if pos == index
            let this_buf = 1
        elseif buf_ctx.expanded
            for item_ctx in buf_ctx.items
                let index += 1
                if pos == index
                    let this_buf = 1
                    break
                endif
            endfor
        endif
        if this_buf
            let expanded = a:cmode == -1? (buf_ctx.expanded == 0? 1 : 0) : a:cmode
            if buf_ctx.expanded != expanded
                let buf_ctx.expanded = expanded
                call setbufvar('%', 'far_ctx', far_ctx)
                call s:update_far_buffer(bufnr)
                exec 'norm! '.buf_curpos.'gg'
            endif
            return
        endif
    endfor
    echoerr 'no far ctx item found under cursor '.pos
endfunction "}}}


function! g:far#change_exclude_all(cmode) abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        for item_ctx in buf_ctx.items
            let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
        endfor
    endfor
    call setbufvar('%', 'far_ctx', far_ctx)
    call s:update_far_buffer(bufnr)
    return
endfunction "}}}


function! g:far#change_exclude_under_cursor(cmode) abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)
    let pos = getcurpos()[1]
    let index = 0
    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let index += 1
        if pos == index
            for item_ctx in buf_ctx.items
                let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
            endfor
            call setbufvar('%', 'far_ctx', far_ctx)
            call s:update_far_buffer(bufnr)
            return
        endif

        if buf_ctx.expanded
            for item_ctx in buf_ctx.items
                let index += 1
                if pos == index
                    let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                    call setbufvar('%', 'far_ctx', far_ctx)
                    call s:update_far_buffer(bufnr)
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
    let repl_skipped = 0
    let repl_matches = 0
    let close_buffs = []
    let ts = localtime()
    arglocal
    for k in keys(a:far_ctx.items)
        let buf_ctx = a:far_ctx.items[k]
        call s:log('replacing buffer '.buf_ctx.bufnr.' '.buf_ctx.bufname)

        let cmds = []
        for item_ctx in buf_ctx.items
            if item_ctx.excluded
                continue
            endif
            let cmd = item_ctx.lnum.'gg0'.(item_ctx.cnum-1 > 0? item_ctx.cnum-1.'l' : '').
                        \   'd'.strchars(item_ctx.match_val).'l'.
                        \   'i'.item_ctx.repl_val.''
            call s:log('cmd: '.cmd)
            call add(cmds, cmd)
        endfor

        if empty(cmds)
            call s:log('no commands for buffer '.buf_ctx.bufnr)
        else
            let cmd = join(cmds, '')
            call s:log('argdo: '.s:repl_do_pre_cmd.cmd)

            try
                exec 'argadd '.buf_ctx.bufname
                exec 'silent! argdo! norm! '.s:repl_do_pre_cmd.cmd
                exec 'argdelete '.buf_ctx.bufname

                "flag in set in argdo commands
                if g:far#__readonlytest__
                    let repl_skipped += 1
                else
                    let repl_files += 1
                    let repl_matches += len(cmds)
                endif
            catch /.*/
                call s:log('failed to replace in buffer '.buf_ctx.bufnr.', error: '.v:exception)
                let repl_skipped += 1
                continue
            endtry

            if g:far#auth_write_replaced_buffers
                call s:log('writing buffer: '.buf_ctx.bufnr)
                exec 'silent w'
            endif
            if g:far#auth_close_replaced_buffers && g:far#auth_write_replaced_buffers &&
                        \   !bufloaded(buf_ctx.bufnr)
                call add(close_buffs, buf_ctx.bufnr)
            endif
        endif
    endfor

    if !empty(close_buffs)
        let cbufs = join(close_buffs)
        call s:log('closing buffers: '.cbufs)
        exec 'bd '.cbufs
    endif

    return {'files': repl_files, 'matches': repl_matches,
                \   'skipped': repl_skipped, 'time': (localtime()-ts)}
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
            let buf_ctx.ftime = getftime(item.bufnr)
            let buf_ctx.items = []
            let far_ctx.items[item.bufnr] = buf_ctx
        endif

        let item_ctx = {}
        let item_ctx.lnum = item.lnum
        let item_ctx.cnum = item.col
        let item_ctx.text = item.text
        let item_ctx.match_val = matchstr(item.text, a:pattern, item.col-1)
        let item_ctx.repl_val = substitute(item_ctx.match_val, a:pattern, a:replace_with, "")
        let item_ctx.excluded = 0
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
        let buf_ctx = a:far_ctx.items[ctx_key]
        let expand_sign = buf_ctx.expanded ? '-' : '+'
        let line_num += 1
        let num_matches = 0
        for item_ctx in buf_ctx.items
            if item_ctx.excluded
                let num_matches += 1
            endif
        endfor

        if num_matches < len(buf_ctx.items)
            let bname_syn = 'syn region FarFilePath start="\%'.line_num.
                        \   'l^.."hs=s+2 end=".\{'.(strchars(buf_ctx.bufname)).'\}"'
            call add(syntaxs, bname_syn)
            let bstats_syn = 'syn region FarFileStats start="\%'.line_num.'l^.\{'.
                        \   (strchars(buf_ctx.bufname)+3).'\}"hs=e end="$" contains=FarFilePath keepend'
            call add(syntaxs, bstats_syn)
        else
            let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
            call add(syntaxs, excl_syn)
        endif

        let out = expand_sign.' '.buf_ctx.bufname.' ['.buf_ctx.bufnr.'] ('.(len(buf_ctx.items)-num_matches).' matches)'
        call add(content, out)

        if buf_ctx.expanded == 1
            for item_ctx in buf_ctx.items
                let line_num += 1
                let line_num_text = item_ctx.lnum.':'.item_ctx.cnum
                let line_num_col_text = '  '.line_num_text.repeat(' ', 8-strchars(line_num_text))
                let window_width = winwidth(winnr())
                let max_text_len = window_width / 2 - strchars(line_num_col_text) - 1
                let max_repl_len = window_width / 2 - strchars(g:far#repl_devider) - 4
                let match_text = s:cetrify_text(item_ctx.text, max_text_len, item_ctx.cnum)
                let repl_text = s:cetrify_text(((item_ctx.cnum == 1? '': item_ctx.text[0:item_ctx.cnum-2]).
                            \   item_ctx.repl_val.item_ctx.text[item_ctx.cnum+len(item_ctx.match_val)-1:]),
                            \   max_repl_len, item_ctx.cnum)
                let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
                call add(content, out)

                " Syntax
                if get(item_ctx, 'broken', 0)
                    let excl_syn = 'syn region Error start="\%'.line_num.'l^" end="$"'
                    call add(syntaxs, excl_syn)
                elseif item_ctx.excluded
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
        endif
    endfor

    return {'content': content, 'syntaxs': syntaxs}
endfunction "}}}


function! s:open_far_buff(far_ctx, wmode) abort "{{{
    let bufname = s:far_buffer_name.'-'.s:buffer_counter
    let bufnr = bufnr(bufname)
    if bufnr != -1
        let s:buffer_counter += 1
        call s:open_far_buff(a:far_ctx, a:wmode)
        return
    endif

    let win_layout = s:get_new_buf_layout(a:wmode, bufname, g:far#window_width, g:far#window_height)
    exec 'silent keepalt '.win_layout
    let bufnr = last_buffer_nr()
    let s:buffer_counter += 1

    setlocal noswapfile
    setlocal buftype=nowrite
    " setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nospell
    setlocal norelativenumber
    setlocal cursorline
    setfiletype far_vim

    if g:far#details_mappings
        call g:far#apply_default_mappings()
    endif

    call setbufvar(bufnr, 'far_ctx', a:far_ctx)
    call s:update_far_buffer(bufnr)
endfunction "}}}


function! s:get_new_buf_layout(wmode, bname, width, height) abort "{{{
    if a:wmode == 'current'
        return 'edit '.a:bname
    elseif a:wmode == 'tab'
        return 'tabedit '.a:bname
    elseif a:wmode == 'top'
        let layout = 'topleft '.a:height
    elseif a:wmode == 'left'
        let layout = 'leftabove vertical '.a:width
    elseif a:wmode == 'right'
        let layout = 'rightbelow vertical '.a:width
    elseif a:wmode == 'bottom'
        let layout = 'botright '.a:height
    else
        echoerr 'invalid window layout '.a:wmode
        let layout = 'rightbelow vertical '.a:width
    endif
    return layout.' new '.a:bname
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
        exec 'norm! '.winnr.''
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


function! s:get_buf_far_ctx(bufnr) abort "{{{
    let far_ctx = getbufvar(a:bufnr, 'far_ctx', {})
    if empty(far_ctx)
        throw 'far context not found for current buffer'
    endif
    return far_ctx
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


function! s:echo_msg(msg) abort "{{{
    execute 'normal! \<Esc>'
    echomsg a:msg
endfunction "}}}


function! s:exec_silent(cmd) abort "{{{
    call s:log("s:exec_silent() ".a:cmd)
    let ei_bak= &eventignore
    set eventignore=BufEnter,BufLeave,BufWinLeave,InsertLeave,CursorMoved,BufWritePost
    silent exe a:cmd
    let &eventignore = ei_bak
endfunction "}}}


if !s:debug "{{{
    let g:loaded_far = 0
endif "}}}

" TODO: check badd command to load a buffer
" if g:far#check_buff_consistency && !item_ctx.excluded
"     let actual_text = getbufline(buf_ctx.bufnr, item_ctx.lnum)
"     if empty(actual_text) || actual_text[0] != item_ctx.text
"         call s:log('broken line, actual: '.(empty(actual_text)?
"             \   'empty' : actual_text[0]).', ctx:'.item_ctx.text)
"         let item_ctx.excluded = 1
"         let item_ctx.broken = 1
"     else
"         let item_ctx.broken = 0
"     endif
" endif

" vim: set et fdm=marker sts=4 sw=4:
