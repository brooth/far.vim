" File: autoload/far.vim
" File: autoload/far.vim
" Description: far.vim plugin business logic
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options {{{
call far#tools#setdefault('g:far#default_mappings', 1)
call far#tools#setdefault('g:far#multiline_sign', '⬎')
call far#tools#setdefault('g:far#repl_devider', ' ➝  ')
call far#tools#setdefault('g:far#cut_text_sign', '…')
call far#tools#setdefault('g:far#collapse_sign', '- ')
call far#tools#setdefault('g:far#expand_sign', '+ ')
call far#tools#setdefault('g:far#window_min_content_width', 60)
call far#tools#setdefault('g:far#preview_window_scroll_step', 1)
call far#tools#setdefault('g:far#check_window_resize_period', 2000)
call far#tools#setdefault('g:far#file_mask_favorites', ['%', '**/*.*', '**/*.html', '**/*.js', '**/*.css'])
call far#tools#setdefault('g:far#default_file_mask', '%')
call far#tools#setdefault('g:far#status_line', 1)
call far#tools#setdefault('g:far#source', 'vimgrep')
call far#tools#setdefault('g:far#cwd', getcwd())
call far#tools#setdefault('g:far#limit', 1000)

call far#tools#setdefault('g:far#executors', {})
call far#tools#setdefault('g:far#executors.vim', 'far#executors#basic#execute')
call far#tools#setdefault('g:far#executors.py3', 'far#executors#py3#execute')
call far#tools#setdefault('g:far#executors.nvim', 'far#executors#nvim#execute')

call far#tools#setdefault('g:far#sources', {})
call far#tools#setdefault('g:far#sources.vimgrep', {})
call far#tools#setdefault('g:far#sources.vimgrep.fn', 'far#sources#qf#search')
call far#tools#setdefault('g:far#sources.vimgrep.executor', 'vim')
call far#tools#setdefault('g:far#sources.vimgrep.args', {})
call far#tools#setdefault('g:far#sources.vimgrep.args.cmd', 'silent! {limit}vimgrep! /{pattern}/gj {file_mask}')
call far#tools#setdefault('g:far#sources.vimgrep.args.escape_pattern', '/')

if executable('ag')
    let cmd = ['ag', '--nogroup', '--column', '--nocolor', '--silent',
        \   '--max-count={limit}', '{pattern}', '--file-search-regex={file_mask}']
    if &smartcase
        call add(cmd, '--smart-case')
    endif
    if &ignorecase
        call add(cmd, '--ignore-case')
    else
        call add(cmd, '--case-sensitive')
    endif

    call far#tools#setdefault('g:far#sources.ag', {})
    call far#tools#setdefault('g:far#sources.ag.fn', 'far.sources.shell.search')
    call far#tools#setdefault('g:far#sources.ag.executor', 'py3')
    call far#tools#setdefault('g:far#sources.ag.args', {})
    call far#tools#setdefault('g:far#sources.ag.args.cmd', cmd)
    call far#tools#setdefault('g:far#sources.ag.args.fix_cnum', 'next')
    call far#tools#setdefault('g:far#sources.ag.args.items_file_min', 30)
    call far#tools#setdefault('g:far#sources.ag.args.expand_cmdargs', 1)

    if has('nvim')
        call far#tools#setdefault('g:far#sources.agnvim', {})
        call far#tools#setdefault('g:far#sources.agnvim.fn', 'far.sources.shell.search')
        call far#tools#setdefault('g:far#sources.agnvim.executor', 'nvim')
        call far#tools#setdefault('g:far#sources.agnvim.args', {})
        call far#tools#setdefault('g:far#sources.agnvim.args.cmd', cmd)
        call far#tools#setdefault('g:far#sources.agnvim.args.fix_cnum', 'next')
        call far#tools#setdefault('g:far#sources.agnvim.args.items_file_min', 30)
        call far#tools#setdefault('g:far#sources.agnvim.args.expand_cmdargs', 1)
    endif
endif

if executable('ack')
    let cmd = ['ack', '--nogroup', '--column', '--nocolor',
            \   '--max-count={limit}', '--type-set=farft:match:{file_mask}', '--farft', '{pattern}']
    if &smartcase
        call add(cmd, '--smart-case')
    endif
    if &ignorecase
        call add(cmd, '--ignore-case')
    endif

    call far#tools#setdefault('g:far#sources.ack', {})
    call far#tools#setdefault('g:far#sources.ack.fn', 'far.sources.shell.search')
    call far#tools#setdefault('g:far#sources.ack.executor', 'py3')
    call far#tools#setdefault('g:far#sources.ack.param_proc', 's:ack_param_proc')
    call far#tools#setdefault('g:far#sources.ack.args', {})
    call far#tools#setdefault('g:far#sources.ack.args.cmd', cmd)
    call far#tools#setdefault('g:far#sources.ack.args.fix_cnum', 'next')
    call far#tools#setdefault('g:far#sources.ack.args.items_file_min', 30)
    call far#tools#setdefault('g:far#sources.ack.args.expand_cmdargs', 1)

    if has('nvim')
        call far#tools#setdefault('g:far#sources.acknvim', {})
        call far#tools#setdefault('g:far#sources.acknvim.fn', 'far.sources.shell.search')
        call far#tools#setdefault('g:far#sources.acknvim.executor', 'nvim')
        call far#tools#setdefault('g:far#sources.acknvim.param_proc', 's:ack_param_proc')
        call far#tools#setdefault('g:far#sources.acknvim.args', {})
        call far#tools#setdefault('g:far#sources.acknvim.args.cmd', cmd)
        call far#tools#setdefault('g:far#sources.acknvim.args.fix_cnum', 'next')
        call far#tools#setdefault('g:far#sources.acknvim.args.items_file_min', 30)
        call far#tools#setdefault('g:far#sources.acknvim.args.expand_cmdargs', 1)
    endif
endif

if executable('rg')
    let cmd = ['rg', '--no-heading', '--column', '--no-messages',
        \   '--max-count={limit}']
    if &smartcase
        call add(cmd, '--smart-case')
    endif
    if &ignorecase
        call add(cmd, '--ignore-case')
    else
        call add(cmd, '--case-sensitive')
    endif
    call add(cmd, '--glob={file_mask}')
    call add(cmd, '{pattern}')

    call far#tools#setdefault('g:far#sources.rg', {})
    call far#tools#setdefault('g:far#sources.rg.fn', 'far.sources.shell.search')
    call far#tools#setdefault('g:far#sources.rg.executor', 'py3')
    call far#tools#setdefault('g:far#sources.rg.args', {})
    call far#tools#setdefault('g:far#sources.rg.args.cmd', cmd)
    call far#tools#setdefault('g:far#sources.rg.args.fix_cnum', 'next')
    call far#tools#setdefault('g:far#sources.rg.args.items_file_min', 30)
    call far#tools#setdefault('g:far#sources.rg.args.expand_cmdargs', 1)

    if has('nvim')
        call far#tools#setdefault('g:far#sources.rgnvim', {})
        call far#tools#setdefault('g:far#sources.rgnvim.fn', 'far.sources.shell.search')
        call far#tools#setdefault('g:far#sources.rgnvim.executor', 'nvim')
        call far#tools#setdefault('g:far#sources.rgnvim.args', {})
        call far#tools#setdefault('g:far#sources.rgnvim.args.cmd', cmd)
        call far#tools#setdefault('g:far#sources.rgnvim.args.fix_cnum', 'next')
        call far#tools#setdefault('g:far#sources.rgnvim.args.items_file_min', 30)
        call far#tools#setdefault('g:far#sources.rgnvim.args.expand_cmdargs', 1)
    endif
endif


function! s:create_far_params() abort
    return {
    \   'source': g:far#source,
    \   'cwd': g:far#cwd,
    \   'limit': g:far#limit,
    \   }
endfunction

function! s:create_win_params() abort
    return {
    \   'layout': exists('g:far#window_layout')? g:far#window_layout : 'right',
    \   'width': exists('g:far#window_width')? g:far#window_width : 100,
    \   'height': exists('g:far#window_height')? g:far#window_height : 20,
    \   'preview_layout': exists('g:far#preview_window_layout')? g:far#preview_window_layout : 'bottom',
    \   'preview_width': exists('g:far#preview_window_width')? g:far#preview_window_width : 100,
    \   'preview_height': exists('g:far#preview_window_height')? g:far#preview_window_height : 11,
    \   'auto_preview': exists('g:far#auto_preview')? g:far#auto_preview : 1,
    \   'highlight_match': exists('g:far#highlight_match')? g:far#highlight_match : 1,
    \   'collapse_result': exists('g:far#collapse_result')? g:far#collapse_result : 0,
    \   'result_preview': exists('g:far#result_preview')? g:far#result_preview : 1,
    \   }
endfunction

function! s:create_repl_params() abort
    return {
    \   'auto_write': exists('g:far#auto_write_replaced_buffers')?
    \       g:far#auto_write_replaced_buffers : 1,
    \   'auto_delete': exists('g:far#auto_delete_replaced_buffers')?
    \       g:far#auto_delete_replaced_buffers : 1,
    \   }
endfunction

function! s:create_undo_params() abort
    return {
    \   'auto_write': exists('g:far#auto_write_undo_buffers')?
    \       g:far#auto_write_undo_buffers : 1,
    \   'auto_delete': exists('g:far#auto_delete_undo_buffers')?
    \       g:far#auto_delete_undo_buffers : 0,
    \   'all': 0,
    \   }
endfunction
"}}}

" metas {{{
let s:suggest_sources = keys(filter(copy(g:far#sources), "get(g:far#sources[v:key], 'suggest', '1')"))

let s:far_params_meta = {
    \   '--source': {'param': 'source', 'values': s:suggest_sources},
    \   '--cwd': {'param': 'cwd', 'values': [getcwd()], 'fnvalues': 's:complete_dir'},
    \   '--limit': {'param': 'limit', 'values': [g:far#limit]},
    \   }

let s:win_params_meta = {
    \   '--win-layout': {'param': 'layout', 'values': ['top', 'left', 'right', 'bottom', 'tab', 'current']},
    \   '--win-width': {'param': 'width', 'values': [60, 70, 80, 90, 100, 110, 120, 130, 140, 150]},
    \   '--win-height': {'param': 'height', 'values': [5, 7, 10, 15, 20, 25, 30]},
    \   '--preview-win-layout': {'param': 'preview_layout', 'values': ['top', 'left', 'right', 'bottom']},
    \   '--preview-win-width': {'param': 'preview_width', 'values': [60, 70, 80, 90, 100, 110, 120, 130, 140, 150]},
    \   '--preview-win-height': {'param': 'preview_height', 'values': [5, 7, 10, 15, 20, 25, 30]},
    \   '--auto-preview': {'param': 'auto_preview', 'values': [0, 1]},
    \   '--hl-match': {'param': 'highlight_match', 'values': [0, 1]},
    \   '--collapse': {'param': 'collapse_result', 'values': [0, 1]},
    \   '--result-preview': {'param': 'result_preview', 'values': [0, 1]},
    \   }

let s:find_win_params_meta = copy(s:win_params_meta)
call remove(s:find_win_params_meta, '--result-preview')

let s:repl_params_meta = {
    \   '--auto-write-bufs': {'param': 'auto_write', 'values': [0, 1]},
    \   '--auto-delete-bufs': {'param': 'auto_delete', 'values': [0, 1]},
    \   }

let s:undo_params_meta = {
    \   '--auto-write-bufs': {'param': 'auto_write', 'values': [0, 1]},
    \   '--auto-delete-bufs': {'param': 'auto_delete', 'values': [0, 1]},
    \   '--all': {'param': 'all', 'values': [0, 1]},
    \   }

let s:refar_params_meta = {
    \   '--pattern': {'param': 'pattern', 'values': ['*']},
    \   '--replace-with': {'param': 'replace_with', 'values': []},
    \   '--file-mask': {'param': 'file_mask', 'values': g:far#file_mask_favorites},
    \   '--cwd': {'param': 'cwd', 'values': [getcwd()], 'fnvalues': 's:complete_dir'},
    \   '--source': {'param': 'source', 'values': s:suggest_sources},
    \   '--limit': {'param': 'limit', 'values': [g:far#limit]},
    \   }
"}}}

" vars {{{
let s:far_buffer_name = 'FAR %d'
let s:far_preview_buffer_name = 'Preview'
let s:buffer_counter = 1

let g:far#search_history = []
let g:far#repl_history = []
let g:far#file_mask_history = []
"}}}

function! far#apply_default_mappings() abort "{{{
    call far#tools#log('apply_default_mappings()')

    nnoremap <buffer><silent> zA :call far#change_collapse_all(-1)<cr>
    nnoremap <buffer><silent> zm :call far#change_collapse_all(1)<cr>
    nnoremap <buffer><silent> zr :call far#change_collapse_all(0)<cr>

    nnoremap <buffer><silent> za :call far#change_collapse_under_cursor(-1)<cr>
    nnoremap <buffer><silent> zc :call far#change_collapse_under_cursor(1)<cr>
    nnoremap <buffer><silent> zo :call far#change_collapse_under_cursor(0)<cr>

    nnoremap <buffer><silent> x :call far#change_exclude_under_cursor(1)<cr>
    vnoremap <buffer><silent> x :call far#change_exclude_under_cursor(1)<cr>
    nnoremap <buffer><silent> i :call far#change_exclude_under_cursor(0)<cr>
    vnoremap <buffer><silent> i :call far#change_exclude_under_cursor(0)<cr>
    nnoremap <buffer><silent> t :call far#change_exclude_under_cursor(-1)<cr>
    vnoremap <buffer><silent> t :call far#change_exclude_under_cursor(-1)<cr>

    nnoremap <buffer><silent> X :call far#change_exclude_all(1)<cr>
    nnoremap <buffer><silent> I :call far#change_exclude_all(0)<cr>
    nnoremap <buffer><silent> T :call far#change_exclude_all(-1)<cr>

    nnoremap <buffer><silent> <cr> :call far#jump_buffer_under_cursor()<cr>
    nnoremap <buffer><silent> p :call far#show_preview_window_under_cursor()<cr>
    nnoremap <buffer><silent> P :call far#close_preview_window()<cr>

    nnoremap <buffer><silent> <c-k> :call far#scroll_preview_window(-g:far#preview_window_scroll_step)<cr>
    nnoremap <buffer><silent> <c-j> :call far#scroll_preview_window(g:far#preview_window_scroll_step)<cr>
endfunction "}}}

augroup faraugroup "{{{
    autocmd!

    " close preview window on far window closing
    au BufHidden * if exists('b:far_preview_winid') && win_id2win(b:far_preview_winid) > 0 |
        \   exec win_id2win(b:far_preview_winid).'hide' | endif
    " turn off auth preview on preview window closing
    au BufHidden * if exists('w:far_preview_win') |
        \   let win_params = getbufvar(w:far_bufnr, 'win_params') |
        \   let win_params.auto_preview = 0 |
        \   endif
augroup END "}}}

 " resize timer {{{
function! far#CheckFarWindowsToResizeHandler(timer) abort
    let n = bufnr('$')
    let no_far_bufs = 1
    while n > 0
        if !empty(getbufvar(n, 'far_ctx', {})) && bufwinnr(n) != -1
            call s:check_far_window_to_resize(n)
            let no_far_bufs = 0
        endif
        let n -= 1
    endwhile

    if no_far_bufs
        call far#tools#log('no far bufs, stopping resize timer #'.a:timer)
        call timer_stop(a:timer)
    endif
endfun

function! s:start_resize_timer() abort
    if g:far#check_window_resize_period < 1
        call far#tools#log('cant start resize timer, period is off')
        return
    endif
    if !has('timers')
        call far#tools#log('cant start resize timer. not supported')
        return
    endif
    if exists('g:far#check_windows_to_resize_timer')
        call far#tools#log('cant start resize timer. already started')
        return
    endif
    let g:far#check_windows_to_resize_timer =
        \    timer_start(g:far#check_window_resize_period,
        \    'far#CheckFarWindowsToResizeHandler', {'repeat': -1})
    call far#tools#log('resize timer started #'.g:far#check_windows_to_resize_timer)
endfunction
"}}}

function! far#scroll_preview_window(steps) abort "{{{
    call far#tools#log('far#scroll_preview_window('.a:steps.')')

    if !exists('b:far_preview_winid') || win_id2win(b:far_preview_winid) == 0
        call far#tools#echo_err('No preview window for curren buffer')
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

function! far#show_preview_window_under_cursor() abort "{{{
    call far#tools#log('far#show_preview_window_under_cursor()')

    let ctxs = s:get_contexts_under_cursor()
    if len(ctxs) < 3
        return
    endif

    let far_bufnr = bufnr('%')
    let far_winid = win_getid(winnr())
    let win_params = b:win_params
    let win_pos = winsaveview()
    let fname = escape(ctxs[1].fname, ' ')
    let bufnr = bufnr(fname)
    let transbuf = bufnr == -1
    let refrbuf = 0
    let synbuf = bufnr == -1 || !bufloaded(bufnr)
    let bufcmd = !transbuf? 'buffer! '.bufnr : 'edit! '.fname

    if exists('b:far_preview_winid')
        let preview_winnr = win_id2win(b:far_preview_winid)
        if preview_winnr == 0
            unlet b:far_preview_winid
        endif
    endif
    if !exists('b:far_preview_winid')
        let splitcmd = far#tools#split_layout(win_params.preview_layout, ' | '.bufcmd,
            \   win_params.preview_width, win_params.preview_height)
        call far#tools#log('preview split: '.splitcmd)
        silent! exec splitcmd
        let refrbuf = 1
        let preview_winnr = winnr()
        let w:far_preview_win = 1
        let w:far_bufnr = far_bufnr
        call setbufvar(far_bufnr, 'far_preview_winid', win_getid(preview_winnr))
        call setwinvar(win_id2win(far_winid), 'far_preview_winid', win_getid(preview_winnr))
        call s:check_far_window_to_resize(far_bufnr)
    else
        call win_gotoid(b:far_preview_winid)
        if winbufnr(preview_winnr) != bufnr
            call far#tools#log('change preview buf cmd: '.bufcmd)
            silent! exec bufcmd
            let refrbuf = 1
        endif
    endif

    if transbuf
        set nobuflisted
        set filetype=off
        set bufhidden=delete
    endif
    if refrbuf
        set nofoldenable
    endif
    if synbuf
        let syncmd = 'set syntax='.far#tools#ftlookup(expand('%:e'))
        call far#tools#log('synbuf:'.syncmd)
        exec syncmd
    endif

    exec 'norm! '.ctxs[2].lnum.'ggzz0'.ctxs[2].cnum.'l'
    if !ctxs[2].replaced
        let pmatch = 'match FarPreviewMatch "\%'.ctxs[2].lnum.'l\%'.ctxs[2].cnum.'c'.
                    \   escape(ctxs[0].pattern, '"').(&ignorecase? '\c"' : '"')
        call far#tools#log('preview match: '.pmatch)
        exec pmatch
    else
        exec 'match'
    endif

    call win_gotoid(far_winid)
    call winrestview(win_pos)
endfunction "}}}

function! far#close_preview_window() abort "{{{
    call far#tools#log('far#close_preview_window()')

    if !exists('b:far_preview_winid')
        call far#tools#echo_err('No preview window for current buffer')
        return
    endif

    let winnr = win_id2win(b:far_preview_winid)
    if winnr > 0
        let b:win_params.auto_preview = 0
        exec 'quit '.winnr
    endif
endfunction "}}}

function! far#jump_buffer_under_cursor() abort "{{{
    call far#tools#log('far#jump_buffer_under_cursor()')

    let ctxs = s:get_contexts_under_cursor()
    if len(ctxs) < 2
        return
    endif

    let nowin = 1
    let fname = ctxs[1].fname
    let bufnr = bufnr(fname)
    if bufnr > 0
        for winnr in range(1, winnr('$'))
            if winbufnr(winnr) == bufnr && !getwinvar(winnr, 'far_preview_win', 0)
                call win_gotoid(win_getid(winnr))
                let new_win = 0
                break
            endif
        endfor
    endif
    if nowin
        let cmd = bufnr != -1 ? 'buffer '.bufnr : 'edit '.fname
        call far#tools#log('jump wincmd: '.cmd)
        exec cmd
    endif
    if len(ctxs) == 3
        exec 'norm! '.ctxs[2].lnum.'gg0'.(ctxs[2].cnum-1).'lzv'
    endif
endfunction "}}}

function! far#change_collapse_all(cmode) abort "{{{
    call far#tools#log('far#change_collapse_all('.a:cmode.')')

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    for file_ctx in far_ctx.items
        let file_ctx.collapsed = a:cmode == -1? !file_ctx.collapsed : a:cmode
    endfor

    let pos = getcurpos()[1]
    call s:update_far_buffer(far_ctx, bufnr)
    exec 'norm! '.pos.'gg'
endfunction "}}}

function! far#change_collapse_under_cursor(cmode) abort "{{{
    call far#tools#log('far#change_collapse_under_cursor('.a:cmode.')')

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    let pos = getcurpos()[1]
    let index = g:far#status_line ? 1 : 0
    for file_ctx in far_ctx.items
        let index += 1
        let buf_curpos = index
        let this_buf = 0
        if pos == index
            let this_buf = 1
        elseif !file_ctx.collapsed
            for item_ctx in file_ctx.items
                let index += 1
                if pos == index
                    let this_buf = 1
                    break
                endif
            endfor
        endif
        if this_buf
            let collapsed = a:cmode == -1? !file_ctx.collapsed : a:cmode
            if file_ctx.collapsed != collapsed
                let file_ctx.collapsed = collapsed
                call s:update_far_buffer(far_ctx, bufnr)
                exec 'norm! '.buf_curpos.'gg'
            endif
            return
        endif
    endfor
endfunction "}}}

function! far#change_exclude_all(cmode) abort "{{{
    call far#tools#log('far#change_exclude_all('.a:cmode.')')

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)

    for file_ctx in far_ctx.items
        for item_ctx in file_ctx.items
            let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
        endfor
    endfor
    call s:update_far_buffer(far_ctx, bufnr)
    return
endfunction "}}}

function! far#change_exclude_under_cursor(cmode) abort "{{{
    call far#tools#log('far#change_exclude_under_cursor('.a:cmode.')')

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)
    let pos = getcurpos()[1]
    let index = g:far#status_line ? 1 : 0
    for file_ctx in far_ctx.items
        let index += 1
        if pos == index
            for item_ctx in file_ctx.items
                let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
            endfor
            call s:update_far_buffer(far_ctx, bufnr)
            return
        endif

        if !file_ctx.collapsed
            for item_ctx in file_ctx.items
                let index += 1
                if pos == index
                    let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                    call s:update_far_buffer(far_ctx, bufnr)
                    exec 'norm! j'
                    return
                endif
            endfor
        endif
    endfor
endfunction "}}}

"command complete functions {{{
function! s:find_matches(items, key) abort
    call far#tools#log('find matches: "'.a:key.'" in '.string(a:items))
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

function! s:complete_dir(val)
    let sep = strridx(a:val, has('unix')? '/' : '\')
    let path = a:val[:sep-1]
    let exp = '*'.a:val[sep+1:].'*'
    let res = []
    for dir in split(globpath(path, exp), '\n')
        if isdirectory(dir)
            call add(res, dir)
        endif
    endfor
    return res
endfunction

function! s:metargs_complete(arglead, cmdline, cursorpos, params_meta) abort
    call far#tools#log('metargs_complete:'.a:arglead.','.a:cmdline.','.a:cursorpos.','.string(a:params_meta))
    let items = far#tools#splitcmd(a:cmdline[:a:cursorpos-1])

    let all_args = []
    let cmpl_val = match(a:arglead, '\V=') != -1
    for metarg in keys(a:params_meta)
        "complete values?
        if cmpl_val
            if match(a:arglead, '\V'.metarg) == -1
                continue
            else
                let argval = a:arglead[stridx(a:arglead, '=')+1:]
                if !empty(argval)
                    let fnvalues = get(a:params_meta[metarg], 'fnvalues', '')
                    if !empty(fnvalues)
                        for val in call(fnvalues, [argval])
                            call add(all_args, metarg.'='.val)
                        endfor
                    endif
                endif
                for val in get(a:params_meta[metarg], 'values', [])
                    let narg = metarg.'='.val
                    if index(all_args, narg) == -1
                        call add(all_args, narg)
                    endif
                endfor
            endif
            return s:find_matches(all_args, a:arglead)
        endif

        "exclude existing?
        let exclude = 0
        for item in items
            if match(item, metarg) == 0
                let exclude = 1
                break
            endif
        endfor
        if !exclude
            call add(all_args, metarg)
        endif
    endfor
    return s:find_matches(all_args, a:arglead)
endfunction

function! far#FarSearchComplete(arglead, cmdline, cursorpos) abort
    let search_hist = g:far#search_history
    if match(a:cmdline, "'<,'>") == 0
        let search_hist = ['*'] + search_hist
    endif
    return s:find_matches(search_hist, a:arglead)
endfunction

function! far#FarReplaceComplete(arglead, cmdline, cursorpos) abort
    return s:find_matches(g:far#repl_history, a:arglead)
endfunction

function! far#FarFileMaskComplete(arglead, cmdline, cursorpos) abort
    return s:find_matches(g:far#file_mask_favorites + g:far#file_mask_history, a:arglead)
endfunction

function! far#FarArgsComplete(arglead, cmdline, cursorpos) abort
    let all_params_meta = extend(copy(s:far_params_meta), s:win_params_meta)
    return s:metargs_complete(a:arglead, a:cmdline, a:cursorpos, all_params_meta)
endfunction

function! far#FindArgsComplete(arglead, cmdline, cursorpos) abort
    let all_params_meta = extend(copy(s:far_params_meta), s:find_win_params_meta)
    return s:metargs_complete(a:arglead, a:cmdline, a:cursorpos, all_params_meta)
endfunction

function! far#FindComplete(arglead, cmdline, cursorpos) abort
    let items = far#tools#splitcmd(a:cmdline[:a:cursorpos-1])
    let argnr = len(items) - (empty(a:arglead) ? 0 : 1)
    if argnr == 1
        return far#FarSearchComplete(a:arglead, a:cmdline, a:cursorpos)
    elseif argnr == 2
        return far#FarFileMaskComplete(a:arglead, a:cmdline, a:cursorpos)
    else
        return far#FindArgsComplete(a:arglead, a:cmdline, a:cursorpos)
    endif
endfunction

function! far#FarComplete(arglead, cmdline, cursorpos) abort
    let items = far#tools#splitcmd(a:cmdline[:a:cursorpos-1])
    let argnr = len(items) - (empty(a:arglead) ? 0 : 1)
    if argnr == 1
        return far#FarSearchComplete(a:arglead, a:cmdline, a:cursorpos)
    elseif argnr == 2
        return far#FarReplaceComplete(a:arglead, a:cmdline, a:cursorpos)
    elseif argnr == 3
        return far#FarFileMaskComplete(a:arglead, a:cmdline, a:cursorpos)
    else
        return far#FarArgsComplete(a:arglead, a:cmdline, a:cursorpos)
    endif
endfunction

function! far#FardoComplete(arglead, cmdline, cursorpos) abort
    return s:metargs_complete(a:arglead, a:cmdline, a:cursorpos, s:repl_params_meta)
endfunction

function! far#FarundoComplete(arglead, cmdline, cursorpos) abort
    return s:metargs_complete(a:arglead, a:cmdline, a:cursorpos, s:undo_params_meta)
endfunction

function! far#RefarComplete(arglead, cmdline, cursorpos) abort
    if exists('b:far_ctx')
        let meta = copy(s:refar_params_meta)
        if index(meta['--pattern'].values, b:far_ctx.pattern) == -1
            call insert(meta['--pattern'].values, b:far_ctx.pattern, 0)
        endif
        if index(meta['--replace-with'].values, b:far_ctx.replace_with) == -1
            call insert(meta['--replace-with'].values, b:far_ctx.replace_with, 0)
        endif
        if index(meta['--file-mask'].values, b:far_ctx.file_mask) == -1
            call insert(meta['--file-mask'].values, b:far_ctx.file_mask, 0)
        endif
    else
        let meta = s:refar_params_meta
    endif
    return s:metargs_complete(a:arglead, a:cmdline, a:cursorpos, meta)
endfunction
"}}}

function! far#find(far_params, xargs) "{{{
    call far#tools#log('far#find('.string(a:far_params).','.string(a:xargs).')')

    let far_params = extend(copy(a:far_params), s:create_far_params())

    if far_params.pattern != '*' && index(g:far#search_history, far_params.pattern) == -1
        call add(g:far#search_history, far_params.pattern)
    endif
    if index(g:far#repl_history, far_params.replace_with) == -1
        call add(g:far#repl_history, far_params.replace_with)
    endif
    if index(g:far#file_mask_favorites, far_params.file_mask) == -1 &&
            \   index(g:far#file_mask_history, far_params.file_mask) == -1
        call add(g:far#file_mask_history, far_params.file_mask)
    endif

    let cmdargs = []
    let win_params = s:create_win_params()
    for xarg in a:xargs
        let d = stridx(xarg, '=')
        if d != -1
            let param = xarg[:d-1]
            let val = xarg[d+1:]
            let meta = get(s:far_params_meta, param, '')
            if !empty(meta)
                let far_params[meta.param] = val
                continue
            endif
            let meta = get(s:win_params_meta, param, '')
            if !empty(meta)
                let win_params[meta.param] = val
                continue
            endif
        endif
        call add(cmdargs, xarg)
    endfor
    call s:assemble_context(far_params, win_params, cmdargs,
    \   function('s:open_far_buff'), [win_params])
endfunction
"}}}

function! far#refind(range, xargs) abort "{{{
    call far#tools#log('far#refind('.string(a:xargs).')')

    if !exists('b:far_ctx')
        call far#tools#echo_err('Not a FAR buffer!')
        return
    endif

    let cmdargs = []
    for xarg in a:xargs
        let d = stridx(xarg, '=')
        if d != -1
            let param = xarg[:d-1]
            let val = xarg[d+1:]
            let meta = get(s:refar_params_meta, param, '')
            if !empty(meta)
                let b:far_ctx[meta.param] = val
                continue
            endif
        endif
        call add(cmdargs, xarg)
    endfor

    if !empty(a:range)
        let b:far_ctx['range'] = a:range
    endif

    call s:assemble_context(b:far_ctx, b:win_params, cmdargs,
        \   function('s:update_far_buffer'), [bufnr('%')])
endfunction "}}}

function! far#replace(xargs) abort "{{{
    call far#tools#log('far#replace('.string(a:xargs).')')

    if !exists('b:far_ctx')
        call far#tools#echo_err('Not a FAR buffer!')
        return
    endif

    let start_ts = reltimefloat(reltime())
    let bufnr = bufnr('%')
    let del_bufs = []
    let far_ctx = b:far_ctx
    let replines = far#tools#matchcnt(far_ctx.replace_with, '\r')
    call far#tools#log('replines:'.replines)

    let repl_params = s:create_repl_params()
    for xarg in a:xargs
        for k in keys(s:repl_params_meta)
            if match(xarg, k) == 0
                let val = xarg[len(k)+1:]
                let repl_params[s:repl_params_meta[k].param] = val
                break
            endif
        endfor
    endfor

    for file_ctx in far_ctx.items
        call far#tools#log('replacing buffer '.file_ctx.fname)

        let cmds = []
        let items = []
        for item_ctx in file_ctx.items
            if !item_ctx.excluded && !item_ctx.replaced
                let cmd = item_ctx.lnum.'s/\%'.item_ctx.cnum.'c'.
                    \   escape(far_ctx.pattern, '/').'/'.
                    \   escape(far_ctx.replace_with, '/').'/e#'
                call add(cmds, cmd)
                call add(items, item_ctx)
            endif
        endfor

        if !empty(cmds)
            let buf_repls = 0
            let cmds = reverse(cmds)
            let undonum = far#tools#undo_nextnr()
            let undoitems = []

            if !bufloaded(file_ctx.fname)
                exec 'e! '.substitute(file_ctx.fname, ' ', '\\ ', 'g')
                if repl_params.auto_delete
                    call add(del_bufs, bufnr(file_ctx.fname))
                endif
            endif
            exec 'buffer! '.file_ctx.fname

            if !repl_params.auto_delete && !buflisted(file_ctx.fname)
                set buflisted
            endif
            if repl_params.auto_write && !(&mod)
                call add(cmds, 'write')
            endif

            let bufcmd = join(cmds, '|')
            call far#tools#log('bufdo: '.bufcmd)

            exec 'redir => s:bufdo_msgs'
            silent! exec bufcmd
            exec 'redir END'
            call far#tools#log('bufdo_msgs: '.s:bufdo_msgs)

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
                    if (item_ctx.lnum + replines) == repl_lines[idx][0]
                        let item_ctx.replaced = 1
                        let item_ctx.repl_text = repl_lines[idx][1]
                        let buf_repls += 1
                        unlet repl_lines[idx]
                        call add(undoitems, item_ctx)
                        break
                    endif
                endfor
                if !item_ctx.replaced
                    let item_ctx.broken = 1
                endif
            endfor

            if !empty(undoitems)
                call add(file_ctx.undos, {'num': undonum, 'items': undoitems})
            endif
        endif
    endfor

    exec 'b! '.bufnr
    if !empty(del_bufs)
        call far#tools#log('delete buffers: '.join(del_bufs, ' '))
        exec 'silent bd! '.join(del_bufs, ' ')
    endif

    let b:far_ctx.repl_time = printf('%.3fms', reltimefloat(reltime()) - start_ts)
    call s:update_far_buffer(b:far_ctx, bufnr)
endfunction

function! far#undo(xargs) abort "{{{
    call far#tools#log('far#undo('.string(a:xargs).')')

    if !exists('b:far_ctx')
        call far#tools#echo_err('Not a FAR buffer!')
        return
    endif

    let undo_params = s:create_undo_params()
    for xarg in a:xargs
        for k in keys(s:undo_params_meta)
            if match(xarg, k) == 0
                let val = xarg[len(k)+1:]
                let undo_params[s:undo_params_meta[k].param] = val
                break
            endif
        endfor
    endfor

    let bufnr = bufnr('%')
    let start_ts = reltimefloat(reltime())
    let del_bufs = []
    for file_ctx in b:far_ctx.items
        if empty(file_ctx.undos)
            continue
        endif

        if far#tools#isdebug()
            call far#tools#log('undo '.file_ctx.fname.', undos:'.string(file_ctx.undos))
        endif

        exec 'buffer! '.file_ctx.fname

        let write_buf = undo_params.auto_write && !(&mod)

        if undo_params.auto_delete && !bufexists(file_ctx.fname)
            call add(del_bufs, bufnr(file_ctx.fname))
        endif

        let items = []
        if undo_params.all
            exec 'silent! undo '.file_ctx.undos[0].num
            for undo in file_ctx.undos
                let items += undo.items
            endfor
            let file_ctx.undos = []
        else
            let undo = remove(file_ctx.undos, len(file_ctx.undos)-1)
            exec 'silent! undo '.undo.num
            let items = undo.items
        endif

        if write_buf
            exec 'silent! write'
        endif

        for item_ctx in items
            let item_ctx.replaced = 0
            unlet item_ctx.repl_text
        endfor
    endfor

    exec 'b! '.bufnr
    if !empty(del_bufs)
        call far#tools#log('delete buffers: '.join(del_bufs, ' '))
        exec 'silent bd! '.join(del_bufs, ' ')
    endif

    if !empty(get(b:far_ctx, 'repl_time', ''))
        unlet b:far_ctx.repl_time
    endif
    let b:far_ctx.undo_time = printf('%.3fms', reltimefloat(reltime()) - start_ts)
    call s:update_far_buffer(b:far_ctx, bufnr)
endfunction "}}}

function! s:assemble_context(far_params, win_params, cmdargs, callback, cbparams) abort "{{{
    if far#tools#isdebug()
        call far#tools#log('assemble_context('.string(a:far_params).','.string(a:win_params).')')
    endif

    if empty(a:far_params.pattern)
        call far#tools#echo_err('No pattern')
        return
    elseif empty(a:far_params.file_mask)
        call far#tools#echo_err('No file mask')
        return
    endif

    let fsource = get(g:far#sources, a:far_params.source, '')
    if empty(fsource)
        echoerr 'Unknown source '.a:far_params.source
        return {}
    endif
    call far#tools#log('source: '.string(fsource))

    let executor = get(g:far#executors, fsource.executor, '')
    if empty(executor)
        echoerr 'Unknown executor '.fsource.executor
        return {}
    endif
    call far#tools#log('executor: '.executor)

    let param_proc = get(fsource, 'param_proc', 's:param_proc')
    call call(function(param_proc), [a:far_params, a:win_params, a:cmdargs])

    if (empty(a:far_params.file_mask))
        call far#tools#echo_err('Invalid file mask')
        return
    endif

    let exec_ctx = {
        \   'fn_args': get(fsource, 'args', {}),
        \   'cmdargs': a:cmdargs,
        \   'far_ctx': a:far_params,
        \   'start_ts': reltimefloat(reltime()),
        \   'source': fsource,
        \   'callback': a:callback,
        \   'callback_params': a:cbparams,
        \   'win_params': a:win_params,
        \   }
    call call(function(executor), [exec_ctx, function('s:assemble_context_callback')])
endfunction "}}}

function! s:assemble_context_callback(exec_ctx) abort "{{{
    call far#tools#log('assemble_context_callback()')

    if !empty(get(a:exec_ctx, 'error', ''))
        call far#tools#echo_err(a:exec_ctx.error)
        return
    endif

    let far_ctx = a:exec_ctx.far_ctx
    let far_ctx['search_time'] = printf('%.3fms', reltimefloat(reltime()) - a:exec_ctx.start_ts)

    for file_ctx in far_ctx.items
        let file_ctx.collapsed = a:exec_ctx.win_params.collapse_result
        let file_ctx.undos = []

        for item_ctx in file_ctx.items
            let item_ctx.excluded = 0
            let item_ctx.replaced = 0
        endfor
    endfor

    let params = [far_ctx]
    if !empty(a:exec_ctx.callback_params)
        call extend(params, a:exec_ctx.callback_params)
    endif
    call call(a:exec_ctx.callback, params)
endfunction "}}}

function! s:build_buffer_content(far_ctx, win_params) abort "{{{
    if far#tools#isdebug()
        call far#tools#log('build_buffer_content(...,'.string(a:win_params).')')
    endif

    let content = []
    let syntaxs = []
    let line_num = 0

    if a:win_params.highlight_match
        call extend(syntaxs, [
            \   'syn match FarNone ".*" contains=FarSearchVal,FarReplaceVal,FarItem',
            \   'syn match FarLineCol "^..\d*" contains=FarSearchVal,FarReplaceVal,FarItem'])
    endif

    if g:far#status_line
        let line_num += 1
        let total_matches = 0
        let total_excludes = 0
        let total_repls = 0

        for file_ctx in a:far_ctx.items
            for item_ctx in file_ctx.items
                let total_matches += 1
                let total_excludes += item_ctx.excluded
                let total_repls += item_ctx.replaced
            endfor
        endfor

        let statusline = 'Files:'.len(a:far_ctx.items).'  Matches:'.total_matches
        if total_excludes > 0
            let statusline = statusline.'  Excludes:'.total_excludes
        endif
            let statusline = statusline.'  Time:'.a:far_ctx.search_time
        if !empty(get(a:far_ctx, 'repl_time', ''))
            let statusline = statusline.
                \   ' ~ Replaced:'.total_repls.
                \   '  Time:'.a:far_ctx.repl_time
        endif

        if strchars(statusline) < a:win_params.width
            let statusline = statusline.repeat(' ', a:win_params.width - strchars(statusline))
        endif
        call add(content, statusline)

        if a:win_params.highlight_match
            let sl_syn = 'syn region FarStatusLine start="\%1l^" end="$"'
            call add(syntaxs, sl_syn)
        endif
    endif

    for file_ctx in a:far_ctx.items
        let collapse_sign = file_ctx.collapsed? g:far#expand_sign : g:far#collapse_sign
        let line_num += 1
        let num_matches = 0
        for item_ctx in file_ctx.items
            if !item_ctx.excluded && !item_ctx.replaced
                let num_matches += 1
            endif
        endfor

        let file_sep = has('unix')? '/' : '\'
        let filestats = ' ('.len(file_ctx.items).' matches)'
        let maxfilewidth = a:win_params.width - strchars(filestats) - strchars(collapse_sign) + 1
        let fileidx = strridx(file_ctx.fname, file_sep)
        let filepath = far#tools#cut_text_middle(file_ctx.fname[:fileidx-1], maxfilewidth/2 - (maxfilewidth % 2? 0 : 1) - 1).
            \ file_sep.far#tools#cut_text_middle(file_ctx.fname[fileidx+1:], maxfilewidth/2)
        let out = collapse_sign.filepath.filestats
        call add(content, out)

        if a:win_params.highlight_match
            if num_matches > 0
                let bname_syn = 'syn region FarFilePath start="\%'.line_num.
                    \   'l^.."hs=s+'.strchars(collapse_sign).' end=".\{'.strchars(filepath).'\}"'
                call add(syntaxs, bname_syn)
                let bstats_syn = 'syn region FarFileStats start="\%'.line_num.'l^.\{'.
                    \   (strchars(filepath)+strchars(collapse_sign)+2).'\}"hs=e end="$" contains=FarFilePath keepend'
                call add(syntaxs, bstats_syn)
            else
                let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
                call add(syntaxs, excl_syn)
            endif
        endif

        if !file_ctx.collapsed
            for item_ctx in file_ctx.items
                let line_num += 1
                let line_num_text = '  '.item_ctx.lnum
                let line_num_col_text = line_num_text.repeat(' ', 8-strchars(line_num_text))
                let match_val = matchstr(item_ctx.text, a:far_ctx.pattern, item_ctx.cnum-1)
                let multiline = match(a:far_ctx.pattern, '\\n') >= 0
                if multiline
                    let match_val = item_ctx.text[item_ctx.cnum:]
                    let match_val = match_val.g:far#multiline_sign
                endif

                if a:win_params.result_preview && !multiline && !item_ctx.replaced
                    let max_text_len = a:win_params.width / 2 - strchars(line_num_col_text)
                    let max_repl_len = a:win_params.width / 2 - strchars(g:far#repl_devider)
                    let repl_val = substitute(match_val, a:far_ctx.pattern, a:far_ctx.replace_with, "")
                    let repl_text = (item_ctx.cnum == 1? '' : item_ctx.text[0:item_ctx.cnum-2]).
                        \   repl_val.item_ctx.text[item_ctx.cnum+strchars(match_val)-1:]
                    let match_text = far#tools#centrify_text(item_ctx.text, max_text_len, item_ctx.cnum)
                    let repl_text = far#tools#centrify_text(repl_text, max_repl_len, item_ctx.cnum)
                    let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
                else
                    let max_text_len = a:win_params.width - strchars(line_num_col_text)
                    let match_text = far#tools#centrify_text((item_ctx.replaced ? item_ctx.repl_text : item_ctx.text),
                        \   max_text_len, item_ctx.cnum)
                    if multiline
                        let match_text.text = match_text.text[:strchars(match_text.text)-
                                    \   strchars(g:far#multiline_sign)-1].g:far#multiline_sign
                    endif
                    let out = line_num_col_text.match_text.text
                endif

                " Syntax
                if a:win_params.highlight_match
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
                        if a:win_params.result_preview && !multiline && !item_ctx.replaced
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

function! s:update_far_buffer(far_ctx, bufnr) abort "{{{
    let winnr = bufwinnr(a:bufnr)
    call far#tools#log('update_far_buffer('.a:bufnr.', '.winnr.')')

    if winnr == -1
        echoerr 'far buffer not open'
        return
    endif

    let win_params = getbufvar(a:bufnr, 'win_params')
    let far_win_width = winwidth(bufwinnr(a:bufnr))
    if win_params.width != far_win_width
        let win_params.width = far_win_width
    endif
    if win_params.width < g:far#window_min_content_width
        let win_params.width = g:far#window_min_content_width
    endif
    let buff_content = s:build_buffer_content(a:far_ctx, win_params)

    if far#tools#isdebug()
        call far#tools#log('content:')
        for line in buff_content.content
            call far#tools#log(line)
        endfor
        call far#tools#log('syntax:')
        for line in buff_content.syntaxs
            call far#tools#log(line)
        endfor
    endif

    if winnr != winnr()
        exec 'norm! '.winnr.''
    endif

    if exists('b:far_preview_winid')
        let preview_winnr = win_id2win(b:far_preview_winid)
        if preview_winnr > 0
            exec 'quit '.preview_winnr
        endif
    endif

    let pos = winsaveview()
    setlocal modifiable
    exec 'norm! ggdG'
    call append(0, buff_content.content)
    exec 'norm! Gdd'
    call winrestview(pos)
    setlocal nomodifiable

    syntax clear
    set syntax=far
    for buf_syn in buff_content.syntaxs
        exec buf_syn
    endfor

    call setbufvar(a:bufnr, 'far_ctx', a:far_ctx)
endfunction "}}}

function! s:open_far_buff(far_ctx, win_params) abort "{{{
    call far#tools#log('open_far_buff('.string(a:win_params).')')

    let fname = printf(s:far_buffer_name, s:buffer_counter)
    let bufnr = bufnr(fname)
    if bufnr != -1
        let s:buffer_counter += 1
        call s:open_far_buff(a:far_ctx, a:win_params)
        return
    endif

    let cmd = far#tools#win_layout(a:win_params, '', fname)
    call far#tools#log('new bufcmd: '.cmd)
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
    setfiletype far

    if g:far#default_mappings
        call g:far#apply_default_mappings()
    endif

    call setbufvar(bufnr, 'win_params', a:win_params)
    call s:update_far_buffer(a:far_ctx, bufnr)
    call s:start_resize_timer()

    if a:win_params.auto_preview
        if v:version >= 704
            autocmd CursorMoved <buffer> if b:win_params.auto_preview |
                \   call g:far#show_preview_window_under_cursor() | endif
        else
            call far#tools#echo_err('auto preview is available on vim 7.4+')
        endif
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
    let index = g:far#status_line ? 1 : 0
    for file_ctx in far_ctx.items
        let index += 1
        if pos == index
            return [far_ctx, file_ctx]
        endif

        if !file_ctx.collapsed
            for item_ctx in file_ctx.items
                let index += 1
                if pos == index
                    return [far_ctx, file_ctx, item_ctx]
                endif
            endfor
        endif
    endfor
    return [far_ctx]
endfunction "}}}

function! s:check_far_window_to_resize(bufnr) abort "{{{
    let win_params = getbufvar(a:bufnr, 'win_params', {})
    if empty(win_params)
        call far#tools#echo_err('Not a FAR buffer')
        return
    endif
    if win_params.width != winwidth(bufwinnr(a:bufnr))
        call far#tools#log('resizing buf '.a:bufnr.' to '.winwidth(bufwinnr(a:bufnr)))
        let cur_winid = win_getid(winnr())
        call s:update_far_buffer(getbufvar(a:bufnr, 'far_ctx'), a:bufnr)
        call win_gotoid(cur_winid)
    endif
endfunction "}}}

function! s:param_proc(far_params, win_params, cmdargs) "{{{
    call far#tools#log('s:param_proc()')

    if a:far_params.pattern == '*'
        let a:far_params.pattern = far#tools#visualtext()
        let a:far_params.range = [-1, -1]
        call far#tools#log('*pattern:'.a:far_params.pattern)
    else
        let a:far_params.pattern = substitute(a:far_params.pattern, '', '\\n', 'g')
    endif

    let a:far_params.replace_with = substitute(a:far_params.replace_with, '', '\\r', 'g')

    if a:far_params.file_mask == '%'
        let a:far_params.file_mask = bufname('%')
    endif
endfunction "}}}

function! s:ack_param_proc(far_params, win_params, cmdargs) "{{{
    call far#tools#log('ack_expand_curfile()')
    if a:far_params.file_mask == '%'
        let a:far_params.file_mask = '--wtf'
        let a:far_params.cwd = expand('%:p:h')
        call add(a:cmdargs, '--type-add=wtf:is:'.expand('%:t'))
        call add(a:cmdargs, '--no-recurse')
    endif

    call s:param_proc(a:far_params, a:win_params, a:cmdargs)
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
