" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far') "{{{
    finish
endif "}}}


" TODO {{{
" Farundo
" statusline (done in Xms stat, number of matches)
" Find in <range> if pattern is not *
"}}}


"logging {{{
let s:debug = exists('g:far#debug')? g:far#debug : 0
let s:debugfile = $HOME.'/far.vim.log'

if s:debug
    exec 'redir! > ' . s:debugfile
    silent echon "debug enabled!\n"
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


" options {{{
let g:far#default_mappings = exists('g:far#default_mappings')?
    \   g:far#default_mappings : 1
let g:far#multiline_sign = exists('g:far#multiline_sign')?
    \   g:far#multiline_sign : '⬎'
let g:far#repl_devider = exists('g:far#repl_devider')?
    \   g:far#repl_devider : '  ➝  '
let g:far#left_cut_text_sign = exists('g:far#left_cut_text_sign')?
    \   g:far#left_cut_text_sign : '…'
let g:far#right_cut_text_sign = exists('g:far#right_cut_text_sign')?
    \   g:far#right_cut_text_sign : '…'
let g:far#collapse_sign = exists('g:far#collapse_sign')?
    \   g:far#collapse_sign : '-'
let g:far#expand_sign = exists('g:far#expand_sign')?
    \   g:far#expand_sign : '+'
let g:far#confirm_fardo = exists('g:far#confirm_fardo')?
    \   g:far#confirm_fardo : 1
let g:far#window_min_content_width = exists('g:far#window_min_content_width')?
    \   g:far#window_min_content_width : 60
let g:far#preview_window_scroll_step = exists('g:far#preview_window_scroll_step')?
    \   g:far#preview_window_scroll_step : 1
let g:far#check_window_resize_period = exists('g:far#check_window_resize_period')?
    \   g:far#check_window_resize_period : 2000
let g:far#file_mask_favorites = exists('g:far#file_mask_favorites')?
    \   g:far#file_mask_favorites : ['%', '**/*.*', '**/*.html', '**/*.js', '**/*.css']

let s:win_params = {
    \   'layout': exists('g:far#window_layout')? g:far#window_layout : 'right',
    \   'width': exists('g:far#window_width')? g:far#window_width : 100,
    \   'height': exists('g:far#window_height')? g:far#window_height : 20,
    \   'preview_layout': exists('g:far#preview_window_layout')? g:far#preview_window_layout : 'bottom',
    \   'preview_width': exists('g:far#preview_window_width')? g:far#preview_window_width : 100,
    \   'preview_height': exists('g:far#preview_window_height')? g:far#preview_window_height : 11,
    \   'jump_win_layout': exists('g:far#jump_window_layout')? g:far#jump_window_layout : 'current',
    \   'jump_win_width': exists('g:far#jump_window_width')? g:far#jump_window_width : 100,
    \   'jump_win_height': exists('g:far#jump_window_height')? g:far#jump_window_height : 15,
    \   'auto_preview': exists('g:far#auto_preview')? g:far#auto_preview : 1,
    \   'highlight_match': exists('far#highlight_match')? g:far#highlight_match : 1,
    \   'collapse_result': exists('far#collapse_result')? g:far#collapse_result : 0,
    \   'result_preview': exists('far#result_preview')? g:far#result_preview : 1,
    \   }

let s:repl_params = {
    \   'auto_write': exists('far#auto_write_replaced_buffers')? g:far#auto_write_replaced_buffers : 0,
    \   'auto_delete': exists('far#auto_delete_replaced_buffers')? g:far#auto_delete_replaced_buffers : 0,
    \   }
"}}}


" vars {{{
let s:far_buffer_name = 'FAR %d'
let s:far_preview_buffer_name = 'Preview'
let s:buffer_counter = 1

let g:far#search_history = []
let g:far#repl_history = []
let g:far#file_mask_history = []

let s:win_params_meta = {
    \   '--win-layout': {'param': 'layout', 'values': ['top', 'left', 'right', 'bottom', 'tab', 'current']},
    \   '--win-width': {'param': 'width', 'values': [60, 70, 80, 90, 100, 110, 120, 130, 140, 150]},
    \   '--win-height': {'param': 'height', 'values': [5, 7, 10, 15, 20, 25, 30]},
    \   '--preview-win-layout': {'param': 'preview_layout', 'values': ['top', 'left', 'right', 'bottom']},
    \   '--preview-win-width': {'param': 'preview_width', 'values': [60, 70, 80, 90, 100, 110, 120, 130, 140, 150]},
    \   '--preview-win-height': {'param': 'preview_height', 'values': [5, 7, 10, 15, 20, 25, 30]},
    \   '--jump-win-layout': {'param': 'jump_win_layout', 'values': ['top', 'left', 'right', 'bottom', 'tab', 'current']},
    \   '--jump-win-width': {'param': 'jump_win_width', 'values': [60, 70, 80, 90, 100, 110, 120, 130, 140, 150]},
    \   '--jump-win-height': {'param': 'jump_win_height', 'values': [5, 7, 10, 15, 20, 25, 30]},
    \   '--auto-preview': {'param': 'auto_preview', 'values': [0, 1]},
    \   '--hl-match': {'param': 'highlight_match', 'values': [0, 1]},
    \   '--collapse': {'param': 'collapse_result', 'values': [0, 1]},
    \   '--result-preview': {'param': 'result_preview', 'values': [0, 1]},
    \   }

let s:repl_params_meta = {
    \   '--auto-write-bufs': {'param': 'auto_write', 'values': [0, 1]},
    \   '--auto-delete-bufs': {'param': 'auto_delete', 'values': [0, 1]},
    \   }
"}}}


function! g:far#apply_default_mappings() abort "{{{
    call s:log('apply_default_mappings()')

    nnoremap <buffer><silent> zA :call g:far#change_collapse_all(-1)<cr>
    nnoremap <buffer><silent> zm :call g:far#change_collapse_all(1)<cr>
    nnoremap <buffer><silent> zr :call g:far#change_collapse_all(0)<cr>

    nnoremap <buffer><silent> za :call g:far#change_collapse_under_cursor(-1)<cr>
    nnoremap <buffer><silent> zc :call g:far#change_collapse_under_cursor(1)<cr>
    nnoremap <buffer><silent> zo :call g:far#change_collapse_under_cursor(0)<cr>

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
    nnoremap <buffer><silent> p :call g:far#show_preview_window_under_cursor()<cr>
    nnoremap <buffer><silent> P :call g:far#close_preview_window()<cr>

    nnoremap <buffer><silent> <c-p> :call g:far#scroll_preview_window(-g:far#preview_window_scroll_step)<cr>
    nnoremap <buffer><silent> <c-n> :call g:far#scroll_preview_window(g:far#preview_window_scroll_step)<cr>
endfunction "}}}


augroup faraugroup "{{{
    autocmd!

    au BufHidden * if exists('b:far_preview_winid') |
        \   exec win_id2win(b:far_preview_winid).'hide' | endif
augroup END "}}}


 " resize timer {{{
func! FarCheckFarWindowsToResizeHandler(timer) abort
    let n = bufnr('$')
    let no_far_bufs = 1
    while n > 0
        if !empty(getbufvar(n, 'far_ctx', {})) && bufwinnr(n) != -1
            call g:far#check_far_window_to_resize(n)
            let no_far_bufs = 0
        endif
        let n -= 1
    endwhile

    if no_far_bufs
        call s:log('no far bufs, stopping resize timer #'.a:timer)
        call timer_stop(a:timer)
    endif
endfun

function! s:start_resize_timer() abort
    if g:far#check_window_resize_period < 1
        call s:log('cant start resize timer, period is off')
        return
    endif
    if !has('timers')
        call s:log('cant start resize timer. not supported')
        return
    endif
    if exists('g:far#check_windows_to_resize_timer')
        call s:log('cant start resize timer. already started')
        return
    endif
    let g:far#check_windows_to_resize_timer =
        \    timer_start(g:far#check_window_resize_period,
        \    'FarCheckFarWindowsToResizeHandler', {'repeat': -1})
    call s:log('resize timer started #'.g:far#check_windows_to_resize_timer)
endfunction
"}}}


function! g:far#check_far_window_to_resize(bufnr) abort "{{{
    call s:log('far#check_window_resize_period('.a:bufnr.')')

    let width = getbufvar(a:bufnr, 'far_window_width', -1)
    if width == -1
        call s:echo_err('Not a FAR buffer')
        return
    endif
    if width != winwidth(bufwinnr(a:bufnr))
        call s:log('resizing buf '.a:bufnr.' '.winwidth(bufwinnr(a:bufnr)).'->'.width)
        let cur_winid = win_getid(winnr())
        call s:update_far_buffer(a:bufnr)
        call win_gotoid(cur_winid)
    endif
endfunction "}}}


function! g:far#scroll_preview_window(steps) abort "{{{
    call s:log('far#scroll_preview_window('.a:steps.')')

    if !exists('b:far_preview_winid') || win_id2win(b:far_preview_winid) == 0
        call s:echo_err('No preview window for curren buffer')
        return
    endif

    let far_winid = win_getid(winnr())
    call win_gotoid(b:far_preview_winid)
    if a:steps > 0
        exec 'norm '.a:steps.''
    else
        exec 'norm '.(-a:steps).''
    endif
    call win_gotoid(far_winid)

endfunction "}}}


function! g:far#show_preview_window_under_cursor() abort "{{{
    call s:log('far#show_preview_window_under_cursor()')

    let ctxs = s:get_contexts_under_cursor()
    if len(ctxs) < 2
        return
    endif

    let far_bufnr = bufnr('%')
    let far_winid = win_getid(winnr())
    let win_params = getbufvar(far_bufnr, 'win_params')
    let preview_winnr = -1

    if exists('b:far_preview_winid')
        let preview_winnr = win_id2win(b:far_preview_winid)
        if preview_winnr == 0
            unlet b:far_preview_winid
        endif
    endif
    if !exists('b:far_preview_winid')
        let splitcmd = s:get_new_split_layout(win_params.preview_layout, '| b'.ctxs[1].bufnr,
            \   win_params.preview_width, win_params.preview_height)
        call s:log('preview split: '.splitcmd)
        exec splitcmd
        exec 'set filetype='.&filetype
        set nofoldenable
        let preview_winnr = winnr()
        let w:far_preview_win = 1
        call setbufvar(far_bufnr, 'far_preview_winid', win_getid(preview_winnr))
        call setwinvar(win_id2win(far_winid), 'far_preview_winid', win_getid(preview_winnr))
        call g:far#check_far_window_to_resize(far_bufnr)
    else
        call win_gotoid(b:far_preview_winid)
    endif

    if winbufnr(preview_winnr) != ctxs[1].bufnr
        exec 'buffer! '.ctxs[1].bufnr
        exec 'set filetype='.&filetype
        set nofoldenable
    endif

    if len(ctxs) > 2
        exec 'norm! '.ctxs[2].lnum.'ggzz'.ctxs[2].cnum.'l'
        if !ctxs[2].replaced
            let pmatch = 'match FarPreviewMatch "\%'.ctxs[2].lnum.'l\%'.ctxs[2].cnum.'c'.
                \   escape(ctxs[0].pattern, '"').(&ignorecase? '\c"' : '"')
            call s:log('preview match: '.pmatch)
            exec pmatch
        else
            exec 'match'
        endif
    endif

    call win_gotoid(far_winid)
endfunction "}}}


function! g:far#close_preview_window() abort "{{{
    call s:log('far#close_preview_window()')

    if !exists('b:far_preview_winid')
        call s:echo_err('Not preview window for current buffer')
        return
    endif

    let winnr = win_id2win(b:far_preview_winid)
    if winnr > 0
        autocmd! FarAutoPreview CursorMoved <buffer>
        exec 'quit '.win_id2win(b:far_preview_winid)
        unlet b:far_preview_winid
    endif
endfunction "}}}


function! g:far#jump_buffer_under_cursor() abort "{{{
    call s:log('far#jump_buffer_under_cursor()')

    let ctxs = s:get_contexts_under_cursor()
    let win_params = getbufvar('%', 'win_params')

    if len(ctxs) > 1
        let new_win = 1
        for winnr in range(1, winnr('$'))
            if winbufnr(winnr) == ctxs[1].bufnr && !getwinvar(winnr, 'far_preview_win', 0)
                call win_gotoid(win_getid(winnr))
                let new_win = 0
                break
            endif
        endfor
        if new_win
            let cmd = s:get_new_buf_layout(win_params, 'jump_win_', ctxs[1].bufname)
            call s:log('jump wincmd: '.cmd)
            exec cmd
        endif
        if len(ctxs) == 3
            exec 'norm! '.ctxs[2].lnum.'gg0'.(ctxs[2].cnum-1).'lzv'
        endif
        return
    endif
endfunction "}}}


function! g:far#change_collapse_all(cmode) abort "{{{
    call s:log('far#change_collapse_all('.a:cmode.')')

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    for k in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[k]
        let buf_ctx.collapsed = a:cmode == -1? !buf_ctx.collapsed : a:cmode
    endfor

    let pos = getcurpos()[1]
    call setbufvar('%', 'far_ctx', far_ctx)
    call s:update_far_buffer(bufnr)
    exec 'norm! '.pos.'gg'
endfunction "}}}


function! g:far#change_collapse_under_cursor(cmode) abort "{{{
    call s:log('far#change_collapse_under_cursor('.a:cmode.')')

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
        elseif !buf_ctx.collapsed
            for item_ctx in buf_ctx.items
                let index += 1
                if pos == index
                    let this_buf = 1
                    break
                endif
            endfor
        endif
        if this_buf
            let collapsed = a:cmode == -1? !buf_ctx.collapsed : a:cmode
            if buf_ctx.collapsed != collapsed
                let buf_ctx.collapsed = collapsed
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
    call s:log('far#change_exclude_all('.a:cmode.')')

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
    call s:log('far#change_exclude_under_cursor('.a:cmode.')')

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

        if !buf_ctx.collapsed
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


function! Far(cmdline, fline, lline) range abort "{{{
    call s:log('=============== FAR ================')
    call s:log('cmdline: '.a:cmdline)

    let cargs = s:splitcmd(a:cmdline)
    if len(cargs) < 3
        call s:echo_err('Arguments required. Format :Far <pattern> <replace> <filemask> [<param1>...]')
        return
    endif

    return s:do_find(cargs[0], cargs[1], cargs[2], a:fline, a:lline, cargs[3:])
endfunction
command! -complete=customlist,FarComplete -nargs=1 -range Far call Far('<args>',<line1>,<line2>)
"}}}


function! FarPrompt(...) abort range "{{{
    call s:log('============ FAR PROMPT ================')

    let pattern = input('Search (pattern): ', '', 'customlist,FarSearchComplete')
    call s:log('>pattern: '.pattern)
    if empty(pattern)
        call s:echo_err('No pattern')
        return
    endif

    let replace_with = input('Replace with: ', '', 'customlist,FarReplaceComplete')
    call s:log('>replace_with: '.replace_with)

    let file_mask = input('File mask: ', '', 'customlist,FarFileMaskComplete')
    call s:log('>file_mask: '.file_mask)
    if empty(file_mask)
        call s:echo_err('No file mask')
        return
    endif

    return s:do_find(pattern, replace_with, file_mask, a:firstline, a:lastline, a:000)
endfunction
command! -complete=customlist,FarArgsComplete -nargs=* -range Farp <line1>,<line2>call FarPrompt(<f-args>)
"}}}


function! FarRepeat() abort "{{{
    call s:log('=========== FAR REPEAT ==============')

    let bufnr = bufnr('%')
    let far_ctx = getbufvar(bufnr, 'far_ctx', {})
    if empty(far_ctx)
        call s:echo_err('Not a FAR buffer!')
        return
    endif
    let win_params = getbufvar(bufnr, 'win_params')

    let far_ctx = s:assemble_context(far_ctx.pattern, far_ctx.replace_with, far_ctx.file_mask, win_params)
    call setbufvar(bufnr, 'far_ctx', far_ctx)
    call s:update_far_buffer(bufnr)

    if empty(far_ctx.items)
        call s:echo_err('No more matches')
    endif
endfunction
command! -nargs=0 Refar call FarRepeat()
"}}}


function! FarDo(...) abort "{{{
    call s:log('============= FAR DO ================')

    let bufnr = bufnr('%')
    let far_ctx = getbufvar(bufnr, 'far_ctx', {})
    if empty(far_ctx)
        call s:echo_err('Not a FAR buffer!')
        return
    endif

    let repl_params = copy(s:repl_params)
    for xarg in a:000
        for k in keys(s:repl_params_meta)
            if match(xarg, k) == 0
                let val = xarg[len(k)+1:]
                let repl_params[s:repl_params_meta[k].param] = val
                break
            endif
        endfor
    endfor

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

    call s:do_replace(far_ctx, repl_params)
endfunction
command! -complete=customlist,FardoComplete -nargs=* Fardo call FarDo(<f-args>)
"}}}


"command complete functions {{{
function! s:find_matches(items, key) abort
    call s:log('find matches: "'.a:key.'" in '.string(a:items))
    if empty(a:key)
        return a:items
    else
        let matches = []
        for item in a:items
            if match(item, '\V'.a:key) != -1
                call add(matches, item)
            endif
        endfor
        return matches
    endif
endfunction

function! FarSearchComplete(arglead, cmdline, cursorpos) abort
    let search_hist = g:far#search_history
    if match(a:cmdline, "'<,'>") == 0 || 1
        let search_hist = ['*'] + search_hist
    endif
    return s:find_matches(search_hist, a:arglead)
endfunction

function! FarReplaceComplete(arglead, cmdline, cursorpos) abort
    return s:find_matches(g:far#repl_history, a:arglead)
endfunction

function! FarFileMaskComplete(arglead, cmdline, cursorpos) abort
    return s:find_matches(g:far#file_mask_favorites + g:far#file_mask_history, a:arglead)
endfunction

function! FarArgsComplete(arglead, cmdline, cursorpos) abort
    let items = s:splitcmd(a:cmdline)
    let wargs = []
    let cmpl_val = match(a:arglead, '\V=') != -1
    for win_arg in keys(s:win_params_meta)
        "complete values?
        if cmpl_val
            if match(a:arglead, '\V'.win_arg) == -1
                continue
            else
                for val in get(s:win_params_meta[win_arg], 'values', [])
                    call add(wargs, win_arg.'='.val)
                endfor
            endif
            return s:find_matches(wargs, a:arglead)
        endif

        "exclude existing?
        let exclude = 0
        for item in items
            if match(item, '\V'.win_arg) != -1
                let exclude = 1
                break
            endif
        endfor
        if !exclude
            call add(wargs, win_arg)
        endif
    endfor
    return s:find_matches(wargs, a:arglead)
endfunction

function! FarComplete(arglead, cmdline, cursorpos) abort
    let items = s:splitcmd(a:cmdline)
    let argnr = len(items)-1
    if argnr == 1
        return FarSearchComplete(a:arglead, a:cmdline, a:cursorpos)
    elseif argnr == 2
        return FarReplaceComplete(a:arglead, a:cmdline, a:cursorpos)
    elseif argnr == 3
        return FarFileMaskComplete(a:arglead, a:cmdline, a:cursorpos)
    else
        return FarArgsComplete(a:arglead, a:cmdline, a:cursorpos)
    endif
endfunction

function! FardoComplete(arglead, cmdline, cursorpos) abort
    call s:log('fardo-complete:'.a:arglead.','.a:cmdline.','.a:cursorpos)
    let items = s:splitcmd(a:cmdline)

    let wargs = []
    for repl_arg in keys(s:repl_params_meta)
        "complete values?
        if a:arglead == repl_arg.'='
            for val in get(s:repl_params_meta[repl_arg], 'values', [])
                call add(wargs, repl_arg.'='.val)
            endfor
            return s:find_matches(wargs, a:arglead)
        endif

        "exclude existing?
        let exclude = 0
        for item in items
            if match(item, repl_arg) == 0
                let exclude = 1
                break
            endif
        endfor
        if !exclude
            call add(wargs, repl_arg)
        endif
    endfor
    return s:find_matches(wargs, a:arglead)
endfunction
"}}}


function! s:do_find(pattern, replace_with, file_mask, fline, lline, xargs) "{{{
    call s:log('do_find('.a:pattern.','. a:replace_with.','.a:file_mask.','
        \   .a:fline.','. a:lline.','.string(a:xargs).')')

    if empty(a:pattern)
        call s:echo_err('No pattern')
        return
    elseif empty(a:file_mask)
        call s:echo_err('No file mask')
        return
    endif

    if a:pattern != '*' && index(g:far#search_history, a:pattern) == -1
        call add(g:far#search_history, a:pattern)
    endif
    if index(g:far#repl_history, a:replace_with) == -1
        call add(g:far#repl_history, a:replace_with)
    endif
    if index(g:far#file_mask_favorites, a:file_mask) == -1 &&
            \   index(g:far#file_mask_history, a:file_mask) == -1
        call add(g:far#file_mask_history, a:file_mask)
    endif

    let pattern = a:pattern
    if a:pattern == '*'
        let pattern = ''
        let p1 = getpos("'<")[1:2]
        let p2 = getpos("'>")[1:2]
        let lnum = a:fline
        while lnum <= a:lline
            let line = getline(lnum)
            if lnum == a:fline
                let line = line[p1[1]-1:]
            elseif lnum == a:lline
                let line = line[:p2[1]-1]
            endif
            let pattern = pattern.escape(line, '\ /[]*')
            if lnum != a:lline
                let pattern = pattern.'\n'
            endif
            let lnum += 1
        endwhile
        call s:log('*pattern:'.pattern)
    else
        let pattern = substitute(pattern, '', '\\n', 'g')
    endif

    let replace_with = substitute(a:replace_with, '', '\\r', 'g')

    let file_mask = a:file_mask
    if file_mask == '%'
        let file_mask = bufname('%')
    endif

    let win_params = copy(s:win_params)
    for xarg in a:xargs
        for k in keys(s:win_params_meta)
            if match(xarg, k) == 0
                let val = xarg[len(k)+1:]
                let win_params[s:win_params_meta[k].param] = val
                break
            endif
        endfor
    endfor

    let far_ctx = s:assemble_context(pattern, replace_with, file_mask, win_params)
    if empty(far_ctx.items)
        call s:echo_err('No match')
        return
    endif
    call s:open_far_buff(far_ctx, win_params)
endfunction
"}}}


function! s:do_replace(far_ctx, repl_params) abort "{{{
    call s:log('do_replace('.a:far_ctx.replace_with.', '.string(a:repl_params).')')

    let ts = localtime()
    let bufnr = bufnr('%')
    let del_bufs = []
    let lines_to_repl = len(substitute(a:far_ctx.replace_with, '[^\\r]', '','g'))/2
    for k in keys(a:far_ctx.items)
        let buf_ctx = a:far_ctx.items[k]
        call s:log('replacing buffer '.buf_ctx.bufnr.' '.buf_ctx.bufname)

        let cmds = []
        let items = []
        for item_ctx in buf_ctx.items
            if !item_ctx.excluded && !item_ctx.replaced
                let cmd = item_ctx.lnum.'s/\%'.item_ctx.cnum.'c'.
                    \   escape(a:far_ctx.pattern, '/').'/'.a:far_ctx.replace_with.'/e#'
                call add(cmds, cmd)
                call add(items, item_ctx)
            endif
        endfor

        if !empty(cmds)
            let buf_repls = 0
            let cmds = reverse(cmds)

            exec 'buffer! '.buf_ctx.bufname

            if a:repl_params.auto_write && !(&mod)
                call add(cmds, 'write')
            endif
            if a:repl_params.auto_delete && !bufexists(buf_ctx.bufnr)
                call add(del_bufs, buf_ctx.bufnr)
            endif

            let bufcmd = join(cmds, '|')
            call s:log('bufdo: '.bufcmd)

            if !a:repl_params.auto_delete && !buflisted(buf_ctx.bufnr)
                set buflisted
            endif

            exec 'redir => s:bufdo_msgs'
            silent! exec bufcmd
            exec 'redir END'
            call s:log('bufdo_msgs: '.s:bufdo_msgs)

            let repl_lines = []
            for bufdo_msg in reverse(split(s:bufdo_msgs, "\n"))
                let sp = matchend(bufdo_msg, '^\s*\d*')
                if sp != -1
                    let nr = str2nr(bufdo_msg[:sp-1])
                    let text = bufdo_msg[sp:]
                    call add(repl_lines, [nr, text])
                else
                    break
                endif
            endfor

            for item_ctx in items
                for idx in range(len(repl_lines))
                    if (item_ctx.lnum + lines_to_repl) == repl_lines[idx][0]
                        let item_ctx.replaced = 1
                        let item_ctx.text = repl_lines[idx][1]
                        let buf_repls += 1
                        unlet repl_lines[idx]
                        break
                    endif
                endfor
                if !item_ctx.replaced
                    let item_ctx.broken = 1
                endif
            endfor
        endif
    endfor

    exec 'b! '.bufnr
    if !empty(del_bufs)
        call s:log('delete buffers: '.join(del_bufs, ' '))
        exec 'silent bd! '.join(del_bufs, ' ')
    endif

    call setbufvar('%', 'far_ctx', a:far_ctx)
    call s:update_far_buffer(bufnr)
endfunction "}}}


function! s:vimgrep_source(pattern, file_mask) abort "{{{
    call s:log('vimgrep_source('.a:pattern.','.a:file_mask.')')

    try
        let cmd = 'silent! vimgrep! /'.escape(a:pattern, '/').'/gj '.a:file_mask
        call s:log('vimgrep cmd: '.cmd)
        exec cmd
    catch /.*/
        call s:log('vimgrep error:'.v:exception)
    endtry

    let items = getqflist()
    if empty(items)
        return {}
    endif

    let result = {}
    for item in items
        if get(item, 'bufnr') == 0
            call s:log('item '.item.text.' has no bufnr')
            continue
        endif

        let buf_ctx = get(result, item.bufnr, {})
        if empty(buf_ctx)
            let buf_ctx.bufnr = item.bufnr
            let buf_ctx.bufname = bufname(item.bufnr)
            let buf_ctx.items = []
            let result[item.bufnr] = buf_ctx
        endif

        let item_ctx = {}
        let item_ctx.lnum = item.lnum
        let item_ctx.cnum = item.col
        let item_ctx.text = item.text
        call add(buf_ctx.items, item_ctx)
    endfor
    return result
endfunction "}}}


function! s:assemble_context(pattern, replace_with, file_mask, win_params) abort "{{{
    call s:log('assemble_context('.a:pattern.','.a:replace_with.','.a:file_mask.')')

    let items = s:vimgrep_source(a:pattern, a:file_mask)
    let far_ctx = {
                \ 'pattern': a:pattern,
                \ 'file_mask': a:file_mask,
                \ 'replace_with': a:replace_with,
                \ 'items': items}

    for buf_ctx in values(far_ctx.items)
        let buf_ctx.collapsed = a:win_params.collapse_result

        for item_ctx in buf_ctx.items
            let item_ctx.excluded = 0
            let item_ctx.replaced = 0
        endfor
    endfor
    return far_ctx
endfunction "}}}


function! s:build_buffer_content(bufnr) abort "{{{
    call s:log('build_buffer_content('.a:bufnr.')')

    let far_ctx = getbufvar(a:bufnr, 'far_ctx', {})
    if empty(far_ctx)
        echoerr 'far context not found for '.a:bufnr.' buffer'
        return
    endif
    if len(far_ctx.items) == 0
        call s:log('empty context result')
        return {'content': [], 'syntaxs': []}
    endif
    let win_params = getbufvar(a:bufnr, 'win_params')

    let content = []
    let syntaxs = []
    let line_num = 0
    for ctx_key in keys(far_ctx.items)
        let buf_ctx = far_ctx.items[ctx_key]
        let collapse_sign = buf_ctx.collapsed? g:far#expand_sign : g:far#collapse_sign
        let line_num += 1
        let num_matches = 0
        for item_ctx in buf_ctx.items
            if !item_ctx.excluded && !item_ctx.replaced
                let num_matches += 1
            endif
        endfor

        if win_params.highlight_match
            if num_matches > 0
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
        endif

        let out = collapse_sign.' '.buf_ctx.bufname.' ['.buf_ctx.bufnr.'] ('.num_matches.' matches)'
        call add(content, out)

        if !buf_ctx.collapsed
            for item_ctx in buf_ctx.items
                let line_num += 1
                let line_num_text = '  '.item_ctx.lnum
                let line_num_col_text = line_num_text.repeat(' ', 10-strchars(line_num_text))
                let match_val = matchstr(item_ctx.text, far_ctx.pattern, item_ctx.cnum-1)

                let far_window_width = winwidth(bufwinnr(a:bufnr))
                if far_window_width < g:far#window_min_content_width
                    let far_window_width = g:far#window_min_content_width
                endif
                call setbufvar(a:bufnr, 'far_window_width', far_window_width)

                let multiline = match(far_ctx.pattern, '\\n') >= 0
                if multiline
                    let match_val = item_ctx.text[item_ctx.cnum:]
                    let match_val = match_val.g:far#multiline_sign
                endif

                if win_params.result_preview && !multiline && !item_ctx.replaced
                    let max_text_len = far_window_width / 2 - strchars(line_num_col_text)
                    let max_repl_len = far_window_width / 2 - strchars(g:far#repl_devider)
                    let repl_val = substitute(match_val, far_ctx.pattern, far_ctx.replace_with, "")
                    let repl_text = (item_ctx.cnum == 1? '' : item_ctx.text[0:item_ctx.cnum-2]).
                        \   repl_val.item_ctx.text[item_ctx.cnum+strchars(match_val)-1:]
                    let match_text = s:centrify_text(item_ctx.text, max_text_len, item_ctx.cnum)
                    let repl_text = s:centrify_text(repl_text, max_repl_len, item_ctx.cnum)
                    let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
                else
                    let max_text_len = far_window_width - strchars(line_num_col_text)
                    let match_text = s:centrify_text(item_ctx.text, max_text_len, item_ctx.cnum)
                    if multiline
                        let match_text.text = match_text.text[:strchars(match_text.text)-
                                    \   strchars(g:far#multiline_sign)-1].g:far#multiline_sign
                    endif
                    let out = line_num_col_text.match_text.text
                endif

                " Syntax
                if win_params.highlight_match
                    if item_ctx.replaced
                        let excl_syn = 'syn region FarReplacedItem start="\%'.line_num.'l^" end="$"'
                        call add(syntaxs, excl_syn)
                    elseif item_ctx.excluded
                        let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
                        call add(syntaxs, excl_syn)
                    elseif get(item_ctx, 'broken', 0)
                        let excl_syn = 'syn region FarBrokenItem start="\%'.line_num.'l^" end="$"'
                        call add(syntaxs, excl_syn)
                    else
                        if win_params.result_preview && !multiline && !item_ctx.replaced
                            let match_col = match_text.val_col
                            let repl_col_h = strchars(repl_text.text) - repl_text.val_col - strchars(repl_val) + 1
                            let repl_col_e = len(repl_text.text) - repl_text.val_idx + 1
                            let line_syn = 'syn region FarItem matchgroup=FarSearchVal '.
                                        \   'start="\%'.line_num.'l\%'.strchars(line_num_col_text).'c"rs=s+'.
                                        \   (match_col+strchars(match_val)).
                                        \   ',hs=s+'.match_col.' matchgroup=FarReplaceVal end=".*$"re=e-'.
                                        \   repl_col_e.',he=e-'.repl_col_h.' oneline'
                            call add(syntaxs, line_syn)
                        else
                            let match_col = match_text.val_col
                            let line_syn = 'syn region FarItem matchgroup=FarSearchVal '.
                                        \   'start="\%'.line_num.'l\%'.strchars(line_num_col_text).'c"rs=s+'.
                                        \   (match_col+strchars(match_val)).
                                        \   ',hs=s+'.match_col.' matchgroup=FarReplaceVal end="" oneline'
                            call add(syntaxs, line_syn)
                        endif
                    endif
                else
                    if get(item_ctx, 'broken', 0)
                        let out = 'B'.out[1:]
                    elseif item_ctx.replaced
                        let out = 'R'.out[1:]
                    elseif item_ctx.excluded
                        let out = 'X'.out[1:]
                    endif
                endif
                call add(content, out)
            endfor
        endif
    endfor

    return {'content': content, 'syntaxs': syntaxs}
endfunction "}}}


function! s:update_far_buffer(bufnr) abort "{{{
    let winnr = bufwinnr(a:bufnr)
    call s:log('update_far_buffer('.a:bufnr.', '.winnr.')')

    if winnr == -1
        echoerr 'far buffer not open'
        return
    endif

    let buff_content = s:build_buffer_content(a:bufnr)

    if s:debug
        call s:log('content:')
        for line in buff_content.content
            call s:log(line)
        endfor
        call s:log('syntax:')
        for line in buff_content.syntaxs
            call s:log(line)
        endfor
    endif

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
        exec buf_syn
    endfor
endfunction "}}}


function! s:open_far_buff(far_ctx, win_params) abort "{{{
    call s:log('open_far_buff('.string(a:win_params).')')

    let bufname = escape(printf(s:far_buffer_name, s:buffer_counter), ' ')
    let bufnr = bufnr(bufname)
    if bufnr != -1
        let s:buffer_counter += 1
        call s:open_far_buff(a:far_ctx, a:win_params)
        return
    endif

    let cmd = s:get_new_buf_layout(a:win_params, '', bufname)
    call s:log('new bufcmd: '.cmd)
    exec cmd
    let bufnr = bufnr('%')
    let s:buffer_counter += 1

    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nospell
    setlocal norelativenumber
    setlocal nonumber
    setlocal cursorline
    setfiletype far_vim

    if g:far#default_mappings
        call g:far#apply_default_mappings()
    endif

    call setbufvar(bufnr, 'far_ctx', a:far_ctx)
    call setbufvar(bufnr, 'win_params', a:win_params)
    call s:update_far_buffer(bufnr)
    call s:start_resize_timer()

    if a:win_params.auto_preview
        if v:version >= 704
            augroup FarAutoPreview
                autocmd! * <buffer>
                autocmd CursorMoved <buffer> :call g:far#show_preview_window_under_cursor()
            augroup END
        else
            call s:echo_err('auto preview is available on vim 7.4+')
        endif
    endif
endfunction "}}}


function! s:get_new_buf_layout(win_params, param_prefix, bname) abort "{{{
    if get(a:win_params, a:param_prefix.'layout') == 'current'
        return 'edit '.a:bname
    elseif get(a:win_params, a:param_prefix.'layout') == 'tab'
        return 'tabedit '.a:bname
    elseif get(a:win_params, a:param_prefix.'layout') == 'top'
        let layout = 'topleft '.get(a:win_params, a:param_prefix.'height')
    elseif get(a:win_params, a:param_prefix.'layout') == 'left'
        let layout = 'topleft vertical '.get(a:win_params, a:param_prefix.'width')
    elseif get(a:win_params, a:param_prefix.'layout') == 'right'
        let layout = 'botright vertical '.get(a:win_params, a:param_prefix.'width')
    elseif get(a:win_params, a:param_prefix.'layout') == 'bottom'
        let layout = 'botright '.get(a:win_params, a:param_prefix.'height')
    else
        echoerr 'invalid window layout '.get(a:win_params, a:param_prefix.'layout')
        let layout = 'botright vertical '.a:width
    endif
    return layout.' new '.a:bname
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


function! s:get_buf_far_ctx(bufnr) abort "{{{
    let far_ctx = getbufvar(a:bufnr, 'far_ctx', {})
    if empty(far_ctx)
        throw 'far context not found for current buffer'
    endif
    return far_ctx
endfunction "}}}


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

        if !buf_ctx.collapsed
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


function! s:centrify_text(text, width, val_col) abort "{{{
    let text = copy(a:text)
    let val_col = a:val_col
    let val_idx = a:val_col
    if strchars(text) > a:width && a:val_col > a:width/2 - 7
        let left_start = a:val_col - a:width/2 + 7
        let val_col = a:val_col - left_start + strchars(g:far#left_cut_text_sign)
        let val_idx = a:val_col - left_start + len(g:far#left_cut_text_sign)
        let text = g:far#left_cut_text_sign.text[left_start:]
    endif
    if strchars(text) > a:width
        let wtf = -1-(len(text)-strchars(text))
        let text = text[0:a:width-len(g:far#right_cut_text_sign)-wtf].g:far#right_cut_text_sign
    endif
    if strchars(text) < a:width
        let text = text.repeat(' ', a:width - strchars(text))
    endif

    return {'text': text, 'val_col': val_col, 'val_idx': val_idx}
endfunction "}}}


function! s:splitcmd(cmdline) "{{{
    let slashes = split(a:cmdline, '\\\\')
    let cmds = []
    let slash_weight = 0
    let p1 = 0
    for idx in range(0, len(slashes)-1)
        let slash = slashes[idx]
        let pos = -1
        while 1
            let pos = match(slash, '\(.*\\\)\@<!\s', pos+1)
            if pos != -1
                let p2 = pos + idx*2 + slash_weight
                call add(cmds, a:cmdline[p1:p2-1])
                let p1 = p2+1
            else
                break
            endif
        endwhile
        let slash_weight += len(slash)
        let idx += 1
    endfor
    call add(cmds, a:cmdline[p1:])
    return cmds
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


" vim: set et fdm=marker sts=4 sw=4:
