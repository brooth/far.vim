" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far') "{{{
    finish
endif "}}}


" TODOs {{{
"TODO preview window (none, top, left, right, buttom, current)
"TODO update buff on win resize
"TODO pass win args as params
"TODO wildmenu for args
"TODO no highlighting for big searchs (g:far#nohighligth_amount = 300)
"TODO Faredo (repeate same far in same window)
"TODO auto colaps if more than x buffers. items...
"TODO r - change item result
"TODO support far for visual selected lines?!?!?! multi line pattern?
"TODO support N[i,x,c] - do N times
"TODO readonly buffers? not saved buffers? modified (after search)?
"TODO check consistancy timer
"TODO statusline (done in Xms stat, number of matches)
"TODO async for neovim
"TODO support alternative providers (not vimgrep)
"TODO multiple providers, excluder (dublicates..)
"TODO support alternative replacers?
"TODO pass providers as params (Farp as well)
"TODO nodes: nested ctxs? for dirs? for python package/module/class/method
"TODO python rename provider (tags? rope? jedi? all of them!)
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

let g:far#window_width = exists('g:far#window_width')?
    \   g:far#window_width : 100
let g:far#window_height = exists('g:far#window_height')?
    \   g:far#window_height : 25
"(top, left, right, bottom, tab, current)
let g:far#window_layout = exists('g:far#window_layout')?
    \   g:far#window_layout : 'right'

let g:far#jump_window_width = 100
let g:far#jump_window_height = 15
"(top, left, right, bottom, tab, current)
let g:far#jump_window_layout = 'left'

let g:far#preview_window_width = 60
let g:far#preview_window_height = 11
"(top, left, right, buttom)
let g:far#preview_window_layout = 'top'
let g:far#auto_preview = 1
"}}}


" vars {{{
let s:far_buffer_name = 'FAR'
let s:far_preview_buffer_name = 'Preview'
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

    nnoremap <buffer><silent> zA :call g:far#change_expand_all(-1)<cr>
    nnoremap <buffer><silent> zR :call g:far#change_expand_all(1)<cr>
    nnoremap <buffer><silent> zM :call g:far#change_expand_all(0)<cr>

    nnoremap <buffer><silent> za :call g:far#change_expand_under_cursor(-1)<cr>
    nnoremap <buffer><silent> zo :call g:far#change_expand_under_cursor(1)<cr>
    nnoremap <buffer><silent> zc :call g:far#change_expand_under_cursor(0)<cr>

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
    nnoremap <buffer><silent> p :call g:far#open_preview_window_under_cursor()<cr>

endfunction "}}}


augroup faraugroup "{{{
    autocmd!

    au BufDelete * if exists('b:far_preview_winid') |
                \   exec 'norm :'.win_id2win(b:far_preview_winid).'q' | endif

    au BufWinLeave * if exists('w:far_preview_winid') |
                \   exec 'norm :'.win_id2win(w:far_preview_winid).'q' | endif

    if g:far#auto_preview && v:version >= 704
        au CursorMoved * if &ft ==# 'far_vim' |
                    \   :call g:far#open_preview_window_under_cursor() | endif
    endif
augroup END "}}}


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


function! s:get_contexts_under_cursor() abort "{{{
    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)
    let pos = getcurpos()[1]
    let index = 0
    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let index += 1
        if pos == index
            return [far_ctx, buf_ctx]
        endif

        if buf_ctx.expanded
            for item_ctx in buf_ctx.items
                let index += 1
                if pos == index
                    return [far_ctx, buf_ctx, item_ctx]
                endif
            endfor
        endif
    endfor
    return [far_ctx]
endfunction "}}}


function! s:get_new_split_layout(smode, bname, width, height) abort "{{{
    if a:smode == 'top'
        return 'aboveleft '.a:height.'split '.a:bname
    elseif a:smode == 'left'
        return 'leftabove '.a:width.'vsplit '.a:bname
    elseif a:smode == 'right'
        return 'rightbelow '.a:width.'vsplit '.a:bname
    elseif a:smode == 'bottom'
        return 'belowright '.a:height.'split '.a:bname
    else
        echoerr 'invalid window layout '.a:smode
        return 'aboveleft '.a:height.'split '.a:bname
    endif
endfunction "}}}


function! g:far#open_preview_window_under_cursor() abort "{{{
    let ctxs = s:get_contexts_under_cursor()
    if len(ctxs) < 3
        return
    endif

    let far_bufnr = bufnr('%')
    let far_winid = win_getid(winnr())
    let preview_winnr = -1

    if exists('b:far_preview_winid')
        let preview_winnr = win_id2win(b:far_preview_winid)
        if preview_winnr == 0
            unlet b:far_preview_winid
        endif
    endif
    if !exists('b:far_preview_winid')
        exec s:get_new_split_layout(g:far#preview_window_layout, '| b'.ctxs[1].bufnr,
            \   g:far#preview_window_width, g:far#preview_window_height)
        let preview_winnr = winnr()
        call setbufvar(far_bufnr, 'far_preview_winid', win_getid(preview_winnr))
        call setwinvar(win_id2win(far_winid), 'far_preview_winid', win_getid(preview_winnr))
    else
        call win_gotoid(b:far_preview_winid)
    endif

    if winbufnr(preview_winnr) != ctxs[1].bufnr
        exec 'buffer '.ctxs[1].bufnr
    endif

    exec 'norm! '.ctxs[2].lnum.'ggzz'
    exec 'match Search "\%'.ctxs[2].lnum.'l\%'.ctxs[2].cnum.'c.\{'.strchars(ctxs[2].match_val).'\}"'
    set nofoldenable

    call win_gotoid(far_winid)
endfunction "}}}


function! g:far#jump_buffer_under_cursor() abort "{{{
    let ctxs = s:get_contexts_under_cursor()

    if len(ctxs) > 1
        let winnr = bufwinnr(ctxs[1].bufnr)
        if winnr == -1
            exec s:get_new_buf_layout(g:far#jump_window_layout, ctxs[1].bufname,
                \   g:far#jump_window_width, g:far#jump_window_height)
        else
            exec 'norm! '.winnr.''
        endif
        if len(ctxs) == 3
            exec 'norm! '.ctxs[2].lnum.'gg0'.(ctxs[2].cnum-1).'lzv'
        endif
        return
    endif

    echoerr 'no far ctx item found under cursor '
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
                let line_num_text = '  '.item_ctx.lnum
                let line_num_col_text = line_num_text.repeat(' ', 10-strchars(line_num_text))
                let window_width = winwidth(winnr())
                let max_text_len = window_width / 2 - strchars(line_num_col_text)
                let max_repl_len = window_width / 2 - strchars(g:far#repl_devider)
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

    exec s:get_new_buf_layout(a:wmode, bufname, g:far#window_width, g:far#window_height)
    let bufnr = last_buffer_nr()
    let s:buffer_counter += 1

    setlocal noswapfile
    setlocal buftype=nowrite
    " setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nospell
    setlocal norelativenumber
    setlocal nonumber
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
        let layout = 'topleft vertical '.a:width
    elseif a:wmode == 'right'
        let layout = 'botright vertical '.a:width
    elseif a:wmode == 'bottom'
        let layout = 'botright '.a:height
    else
        echoerr 'invalid window layout '.a:wmode
        let layout = 'botright vertical '.a:width
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
