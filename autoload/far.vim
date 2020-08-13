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
call far#tools#setdefault('g:far#window_min_content_width', 10)
call far#tools#setdefault('g:far#preview_window_scroll_step', 1)
call far#tools#setdefault('g:far#check_window_resize_period', 2000)
call far#tools#setdefault('g:far#file_mask_favorites',
    \ [ '%', '/', '* (any char)', '*.extenton', '/root-file','/root-dir/',
    \ 'anywhere-file','anywhere-dir/','dir/directly-under' ,'dir/**/recursively-under'])

call far#tools#setdefault('g:far#default_file_mask', '%')
call far#tools#setdefault('g:far#status_line', 1)
call far#tools#setdefault('g:far#source', 'vimgrep')
call far#tools#setdefault('g:far#cwd', getcwd())
call far#tools#setdefault('g:far#regex', 1)
call far#tools#setdefault('g:far#case_sensitive', -1)
call far#tools#setdefault('g:far#word_boundary', 0)
call far#tools#setdefault('g:far#limit', 1000)
call far#tools#setdefault('g:far#max_columns', 400)


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

call far#tools#setdefault('g:far#mode_open', { "regex" : 1, "case_sensitive"  : 0, "word" : 0, "substitute": 0 } )

let s:farvim_dir = resolve(expand('<sfile>:p:h:h'))
call far#tools#setdefault('g:far#ignore_files', [s:farvim_dir.  (has('unix')? '/' : '\') . 'farignore'])


if executable('ag')
    let cmd = ['ag', '--nogroup', '--column', '--nocolor', '--silent', '--vimgrep',
        \   '--max-count={limit}', '{pattern}', '{file_mask}']

    call far#tools#setdefault('g:far#sources.ag', {})
    call far#tools#setdefault('g:far#sources.ag.fn', 'far.sources.shell.search')
    call far#tools#setdefault('g:far#sources.ag.executor', 'py3')
    call far#tools#setdefault('g:far#sources.ag.param_proc', 's:pyglob_param_proc')
    call far#tools#setdefault('g:far#sources.ag.args', {})
    call far#tools#setdefault('g:far#sources.ag.args.cmd', cmd)
    call far#tools#setdefault('g:far#sources.ag.args.submatch', 'all')
    call far#tools#setdefault('g:far#sources.ag.args.items_file_min', 30)
    call far#tools#setdefault('g:far#sources.ag.args.expand_cmdargs', 1)
    call far#tools#setdefault('g:far#sources.ag.args.ignore_files', g:far#ignore_files)
    call far#tools#setdefault('g:far#sources.ag.args.max_columns', g:far#max_columns)

    if has('nvim')
        call far#tools#setdefault('g:far#sources.agnvim', {})
        call far#tools#setdefault('g:far#sources.agnvim.fn', 'far.sources.shell.search')
        call far#tools#setdefault('g:far#sources.agnvim.executor', 'nvim')
        call far#tools#setdefault('g:far#sources.agnvim.param_proc', 's:pyglob_param_proc')
        call far#tools#setdefault('g:far#sources.agnvim.args', {})
        call far#tools#setdefault('g:far#sources.agnvim.args.cmd', cmd)
        call far#tools#setdefault('g:far#sources.agnvim.args.submatch', 'all')
        call far#tools#setdefault('g:far#sources.agnvim.args.items_file_min', 30)
        call far#tools#setdefault('g:far#sources.agnvim.args.expand_cmdargs', 1)
        call far#tools#setdefault('g:far#sources.agnvim.args.ignore_files', g:far#ignore_files)
        call far#tools#setdefault('g:far#sources.agnvim.args.max_columns', g:far#max_columns)
    endif
endif

if executable('ack')
    let cmd = ['ack', '--nogroup', '--column', '--nocolor',
            \   '--max-count={limit}', '{pattern}','-x', '{file_mask}']

    call far#tools#setdefault('g:far#sources.ack', {})
    call far#tools#setdefault('g:far#sources.ack.fn', 'far.sources.shell.search')
    call far#tools#setdefault('g:far#sources.ack.executor', 'py3')
    call far#tools#setdefault('g:far#sources.ack.param_proc', 's:pyglob_param_proc')
    call far#tools#setdefault('g:far#sources.ack.args', {})
    call far#tools#setdefault('g:far#sources.ack.args.cmd', cmd)
    call far#tools#setdefault('g:far#sources.ack.args.submatch', 'first')
    call far#tools#setdefault('g:far#sources.ack.args.items_file_min', 30)
    call far#tools#setdefault('g:far#sources.ack.args.expand_cmdargs', 1)
    call far#tools#setdefault('g:far#sources.ack.args.ignore_files', g:far#ignore_files)
    call far#tools#setdefault('g:far#sources.ack.args.max_columns', g:far#max_columns)

    if has('nvim')
        call far#tools#setdefault('g:far#sources.acknvim', {})
        call far#tools#setdefault('g:far#sources.acknvim.fn', 'far.sources.shell.search')
        call far#tools#setdefault('g:far#sources.acknvim.executor', 'nvim')
        call far#tools#setdefault('g:far#sources.acknvim.param_proc', 's:pyglob_param_proc')
        call far#tools#setdefault('g:far#sources.acknvim.args', {})
        call far#tools#setdefault('g:far#sources.acknvim.args.cmd', cmd)
        call far#tools#setdefault('g:far#sources.acknvim.args.submatch', 'first')
        call far#tools#setdefault('g:far#sources.acknvim.args.items_file_min', 30)
        call far#tools#setdefault('g:far#sources.acknvim.args.expand_cmdargs', 1)
        call far#tools#setdefault('g:far#sources.acknvim.args.ignore_files', g:far#ignore_files)
        call far#tools#setdefault('g:far#sources.acknvim.args.max_columns', g:far#max_columns)
    endif
endif

if executable('rg')
    let cmd = [ 'rg','--json','--with-filename', '--no-heading',
    \ '--vimgrep',  '--max-count={limit}', '{pattern}', '-g', '{file_mask}']

    call far#tools#setdefault('g:far#sources.rg', {})
    call far#tools#setdefault('g:far#sources.rg.fn', 'far.sources.shell.search')
    call far#tools#setdefault('g:far#sources.rg.executor', 'py3')
    call far#tools#setdefault('g:far#sources.rg.param_proc', 's:pyglob_param_proc')
    call far#tools#setdefault('g:far#sources.rg.args', {})
    call far#tools#setdefault('g:far#sources.rg.args.cmd', cmd)
    call far#tools#setdefault('g:far#sources.rg.args.submatch', 'all')
    call far#tools#setdefault('g:far#sources.rg.args.items_file_min', 30)
    call far#tools#setdefault('g:far#sources.rg.args.expand_cmdargs', 1)
    call far#tools#setdefault('g:far#sources.rg.args.ignore_files', g:far#ignore_files)
    call far#tools#setdefault('g:far#sources.rg.args.max_columns', g:far#max_columns)

    if has('nvim')
        call far#tools#setdefault('g:far#sources.rgnvim', {})
        call far#tools#setdefault('g:far#sources.rgnvim.fn', 'far.sources.shell.search')
        call far#tools#setdefault('g:far#sources.rgnvim.executor', 'nvim')
        call far#tools#setdefault('g:far#sources.rgnvim.param_proc', 's:pyglob_param_proc')
        call far#tools#setdefault('g:far#sources.rgnvim.args', {})
        call far#tools#setdefault('g:far#sources.rgnvim.args.cmd', cmd)
        call far#tools#setdefault('g:far#sources.rgnvim.args.submatch', 'all')
        call far#tools#setdefault('g:far#sources.rgnvim.args.items_file_min', 30)
        call far#tools#setdefault('g:far#sources.rgnvim.args.expand_cmdargs', 1)
        call far#tools#setdefault('g:far#sources.rgnvim.args.ignore_files', g:far#ignore_files)
        call far#tools#setdefault('g:far#sources.rgnvim.args.max_columns', g:far#max_columns)
    endif
endif


function! s:create_far_params() abort
    return {
    \   'source': g:far#source,
    \   'cwd': g:far#cwd,
    \   'limit': g:far#limit,
    \   'regex': g:far#regex,
    \   'case_sensitive': g:far#case_sensitive,
    \   'word_boundary': g:far#word_boundary,
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
    \   'auto_preview_on_start' : exists('g:far#auto_preview_on_start') ? g:far#auto_preview_on_start : 1,
    \   'highlight_match': exists('g:far#highlight_match')? g:far#highlight_match : 1,
    \   'collapse_result': exists('g:far#collapse_result')? g:far#collapse_result : 0,
    \   'result_preview': exists('g:far#result_preview')? g:far#result_preview : 1,
    \   'enable_replace': 1,
    \   'mode_prompt': 0,
    \   'parent_buffnr': '',
    \   }
endfunction

function! s:create_repl_params() abort
    if exists('g:far#enable_undo') && g:far#enable_undo
        return { 'auto_write': 1, 'auto_delete': 0 }
    else
        return {
        \   'auto_write': exists('g:far#auto_write_replaced_buffers')?
        \       g:far#auto_write_replaced_buffers : 1,
        \   'auto_delete': exists('g:far#auto_delete_replaced_buffers')?
        \       g:far#auto_delete_replaced_buffers : 0,
        \   }
    endif
endfunction

function! s:create_undo_params() abort
    if exists('g:far#enable_undo') && g:far#enable_undo
        return { 'auto_write': 1, 'auto_delete': 0, 'all': 0 }
    else
        return {
        \   'auto_write': exists('g:far#auto_write_undo_buffers')?
        \       g:far#auto_write_undo_buffers : 1,
        \   'auto_delete': exists('g:far#auto_delete_undo_buffers')?
        \       g:far#auto_delete_undo_buffers : 0,
        \   'all': 0,
        \   }
    endif
endfunction
"}}}

" metas {{{
let s:suggest_sources = keys(filter(copy(g:far#sources), "get(g:far#sources[v:key], 'suggest', '1')"))

let s:far_params_meta = {
    \   '--source': {'param': 'source', 'values': s:suggest_sources},
    \   '--cwd': {'param': 'cwd', 'values': [getcwd()], 'fnvalues': 's:complete_dir'},
    \   '--limit': {'param': 'limit', 'values': [g:far#limit]},
    \   '--regex' : {'param': 'regex', 'values': [1,0]},
    \   '--case-sensitive' : {'param': 'case_sensitive', 'values': [1,0,-1]},
    \   '--word-boundary' : {'param': 'word_boundary', 'values': [1,0]},
    \   '--max-columns' : { 'param': 'max_columns', 'values': [300,400,'..']},
    \   }

let s:far_params_meta_vimgrep = {
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
    \   '--auto-preview-on-start': {'param': 'auto_preview_on_start', 'values': [0, 1]},
    \   '--hl-match': {'param': 'highlight_match', 'values': [0, 1]},
    \   '--collapse': {'param': 'collapse_result', 'values': [0, 1]},
    \   '--result-preview': {'param': 'result_preview', 'values': [0, 1]},
    \   '--enable-replace': {'param': 'enable_replace', 'values': [0, 1]},
    \   }

let s:find_win_params_meta = copy(s:win_params_meta)
call remove(s:find_win_params_meta, '--result-preview')
call remove(s:find_win_params_meta, '--enable-replace')

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



" s:#default_mapping {{{
let s:default_mapping = {
    \ "toggle_expand_all" : "zA",
    \ "stoggle_expand_all" : "zS",
    \ "expand_all" : "zr",
    \ "collapse_all" : "zm",
    \
    \ "toggle_expand" : "za",
    \ "stoggle_expand" : "zs",
    \ "expand" : "zo",
    \ "collapse" : "zc",
    \
    \ "exclude" : "x",
    \ "include" : "i",
    \ "toggle_exclude" : "t",
    \ "stoggle_exclude" : "f",
    \
    \ "exclude_all" : "X",
    \ "include_all" : "I",
    \ "toggle_exclude_all" : "T",
    \ "stoggle_exclude_all" : "F",
    \
    \ "jump_to_source" : "<cr>",
    \ "open_preview" : "p",
    \ "close_preview" : "P",
    \ "preview_scroll_up" : "<c-k>",
    \ "preview_scroll_down" : "<c-j>",
    \
    \ "replace_do" : 's',
    \ "replace_undo" : 'u',
    \ "replace_undo_all" : 'U',
    \ "quit" : 'q',
    \ }

if !exists('g:far#mapping')
    let g:far#mapping = s:default_mapping
else
    for key in keys(s:default_mapping)
        let g:far#mapping[key] = get(g:far#mapping, key,
            \ s:default_mapping[key])
    endfor
endif
" }}}

" s:act_func_ref {{{
let s:act_func_ref = {
    \ "stoggle_expand_all"  : { "nnoremap <silent>" : ":call far#change_collapse_all(-2)<CR>" },
    \ "toggle_expand_all"   : { "nnoremap <silent>" : ":call far#change_collapse_all(-1)<CR>" },
    \ "expand_all"          : { "nnoremap <silent>" : ":call far#change_collapse_all(0)<CR>" },
    \ "collapse_all"        : { "nnoremap <silent>" : ":call far#change_collapse_all(1)<CR>" },
    \
    \ "stoggle_expand"      : { "nnoremap <silent>" : ":call far#change_collapse_under_cursor(-1)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_collapse_under_selection(-2)<CR>" },
    \ "toggle_expand"       : { "nnoremap <silent>" : ":call far#change_collapse_under_cursor(-1)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_collapse_under_selection(-1)<CR>" },
    \ "expand"              : { "nnoremap <silent>" : ":call far#change_collapse_under_cursor(0)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_collapse_under_selection(0)<CR>" },
    \ "collapse"            : { "nnoremap <silent>" : ":call far#change_collapse_under_cursor(1)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_collapse_under_selection(1)<CR>" },
    \
    \ "exclude"             : { "nnoremap <silent>" : ":call far#change_exclude_under_cursor(1)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_exclude_under_selection(1)<CR>" },
    \ "include"             : { "nnoremap <silent>" : ":call far#change_exclude_under_cursor(0)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_exclude_under_selection(0)<CR>" },
    \ "toggle_exclude"      : { "nnoremap <silent>" : ":call far#change_exclude_under_cursor(-1)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_exclude_under_selection(-1)<CR>" },
    \ "stoggle_exclude"     : { "nnoremap <silent>" : ":call far#change_exclude_under_cursor(-2)<CR>",
    \                           "vnoremap <silent>" : ":call far#change_exclude_under_selection(-2)<CR>" },
    \
    \ "exclude_all"         : { "nnoremap <silent>" : ":call far#change_exclude_all(1)<CR>" },
    \ "include_all"         : { "nnoremap <silent>" : ":call far#change_exclude_all(0)<CR>" },
    \ "toggle_exclude_all"  : { "nnoremap <silent>" : ":call far#change_exclude_all(-1)<CR>" },
    \ "stoggle_exclude_all" : { "nnoremap <silent>" : ":call far#change_exclude_all(-2)<CR>" },
    \
    \ "jump_to_source"      : { "nnoremap <silent>" : ":call far#jump_buffer_under_cursor()<CR>" },
    \ "open_preview"        : { "nnoremap <silent>" : ":call far#show_preview_window_under_cursor()<CR>" },
    \ "close_preview"       : { "nnoremap <silent>" : ":call far#close_preview_window()<CR>" },
    \ "preview_scroll_up"   : { "nnoremap <silent>" : ":call far#scroll_preview_window(-g:far#preview_window_scroll_step)<CR>" },
    \ "preview_scroll_down" : { "nnoremap <silent>" : ":call far#scroll_preview_window(g:far#preview_window_scroll_step)<CR>" },
    \
    \ "replace_do"          : { "nnoremap <silent>" : ":Fardo<CR>",
    \                           "vnoremap <silent>" : ":Fardo<CR>" },
    \ "replace_undo"        : { "nnoremap <silent>" : ":Farundo<CR>",
    \                           "vnoremap <silent>" : ":Farundo<CR>" },
    \ "replace_undo_all"    : { "nnoremap <silent>" : ":Farundo --all=1<CR>",
    \                           "vnoremap <silent>" : ":Farundo --all=1<CR>" },
    \ "quit"                : { "nnoremap <silent>" : ":call far#close_far_buff()<CR>",
    \                           "vnoremap <silent>" : ":call far#close_far_buff()<CR>"  },
    \ }
" }}}

function! far#set_mappings(map, act_func_ref) abort "{{{
    for act in keys(a:act_func_ref)
        if empty(get(a:map, act, ""))
            continue
        endif

        if type(a:act_func_ref[act]) != 4
            continue
        endif

        for mapmode in keys(a:act_func_ref[act])
            let func_ref = a:act_func_ref[act][mapmode]

            if type(a:map[act]) == 1
                exec "silent! ".mapmode." <buffer> ".a:map[act]." ".func_ref
            endif

            if type(a:map[act]) == 3
                for key in a:map[act]
                    exec "silent! ".mapmode." <buffer> ".key." ".func_ref
                endfor
            endif
        endfor
    endfor
endfunction "}}}

function! far#apply_default_mappings() abort "{{{
    call far#tools#log('apply_default_mappings()')
    call far#set_mappings(g:far#mapping, s:act_func_ref)
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
    let b:win_params.preview_on = b:win_params.auto_preview


    let ctxs = s:get_contexts_under_cursor()
    if len(ctxs) < 3
        return
    endif


    " let b:win_params.auto_preview = s:create_win_params().auto_preview
    let far_cwd = b:win_params.far_params.cwd
    let far_bufnr = bufnr('%')
    let far_winid = win_getid(winnr())
    let win_params = b:win_params
    let win_pos = winsaveview()
    let fname = ctxs[1].fname
    let file_sep = has('unix')? '/' : '\'
    let fname = far_cwd . file_sep . fname
    let fname = escape(fname, ' ')
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

    call setpos('.', [bufnr('%'), ctxs[2].lnum, ctxs[2].cnum, 0])

    if !ctxs[2].replaced
        let pmatch = 'match FarPreviewMatch "\%'.ctxs[2].lnum.'l\%'.ctxs[2].cnum.'c'.
                    \ escape(ctxs[0].pattern_proc, '"') .(&ignorecase? '\c"' : '"')

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

    let b:win_params.preview_on = 0

    if exists('b:far_preview_winid')
        let winnr = win_id2win(b:far_preview_winid)
        if winnr > 0
            exec 'quit '.winnr
        endif
    else
        call far#tools#echo_err('No preview window for current buffer')
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

    if a:cmode == -2
    " smart toggle: when all files are collapsed, collapse all files; otherwise, expand all files
        let all_collapsed = 1
        for file_ctx in far_ctx.items
            let all_collapsed = all_collapsed && file_ctx.collapsed
        endfor

        for file_ctx in far_ctx.items
            let file_ctx.collapsed = !all_collapsed
        endfor
    else
        for file_ctx in far_ctx.items
            let file_ctx.collapsed = a:cmode == -1? !file_ctx.collapsed : a:cmode
        endfor
    endif

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

    if a:cmode == -2
    " smart toggle: when all items are excluded, include all items; otherwise, exclude all items
        let all_excluded = 1
        for file_ctx in far_ctx.items
            for item_ctx in file_ctx.items
                if !item_ctx.replaced
                    let all_excluded = all_excluded && item_ctx.excluded
                endif
            endfor
        endfor

        for file_ctx in far_ctx.items
            for item_ctx in file_ctx.items
                if !item_ctx.replaced
                    let item_ctx.excluded = !all_excluded
                endif
            endfor
        endfor
    else
        for file_ctx in far_ctx.items
            for item_ctx in file_ctx.items
                if !item_ctx.replaced
                    let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                endif
            endfor
        endfor
    endif

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
            if a:cmode == -2
                let all_excluded = 1
                for item_ctx in file_ctx.items
                    if !item_ctx.replaced
                        let all_excluded = all_excluded && item_ctx.excluded
                    endif
                endfor
                for item_ctx in file_ctx.items
                    if !item_ctx.replaced
                        let item_ctx.excluded = !all_excluded
                    endif
                endfor
            else
                for item_ctx in file_ctx.items
                    if !item_ctx.replaced
                        let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                    endif
                endfor
            endif
            call s:update_far_buffer(far_ctx, bufnr)
            return
        endif

        if !file_ctx.collapsed
            for item_ctx in file_ctx.items
                let index += 1
                if pos == index && !item_ctx.replaced
                    let item_ctx.excluded = (a:cmode == -1 || a:cmode==-2) ? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                    call s:update_far_buffer(far_ctx, bufnr)
                    exec 'norm! j'
                    return
                endif
            endfor
        endif
    endfor
endfunction "}}}


function! far#change_exclude_under_selection(cmode) abort range "{{{
    call far#tools#log('far#change_exclude_under_selection('.a:cmode.')')

    let pos1 = getpos("'<")
    let pos2 = getpos("'>")

    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)
    let loop_num = 0
    let all_excluded = 1

    while 1
        let loop_num += 1
        let index = g:far#status_line ? 1 : 0

        for file_ctx in far_ctx.items
            let index += 1
            if file_ctx.collapsed || index == lnum2
                if lnum1 <= index && index <= lnum2
                    for item_ctx in file_ctx.items
                        if !item_ctx.replaced
                            if a:cmode == -2
                                if loop_num == 1
                                    let all_excluded = all_excluded && item_ctx.excluded
                                else
                                    let item_ctx.excluded = ! all_excluded
                                endif
                            else
                                let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                            endif
                        endif
                    endfor
                endif
            else
                for item_ctx in file_ctx.items
                    let index += 1
                    if lnum1 <= index && index <= lnum2  && !item_ctx.replaced
                        if a:cmode == -2
                            if loop_num == 1
                                let all_excluded = all_excluded && item_ctx.excluded
                            else
                                let item_ctx.excluded = ! all_excluded
                            endif
                        else
                            let item_ctx.excluded = a:cmode == -1? (item_ctx.excluded == 0? 1 : 0) : a:cmode
                        endif
                    endif
                    if index >= lnum2
                        break
                    endif
                endfor
            endif

            if index >= lnum2
                break
            endif
        endfor

        if a:cmode == -2
            if loop_num >= 2
                break
            endif
        else
            break
        endif
    endwhile

    call s:update_far_buffer(far_ctx, bufnr)

    call setpos("'<", pos1)
    call setpos("'>", pos2)
    exe 'normal! gv'

endfunction "}}}


function! far#change_collapse_under_selection(cmode) abort range "{{{
    call far#tools#log('far#change_collapse_under_selection('.a:cmode.')')

    let pos1 = getpos("'<")
    let pos2 = getpos("'>")

    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]

    let bufnr = bufnr('%')
    let far_ctx = s:get_buf_far_ctx(bufnr)


    let all_collapsed = 1
    let loop_num = 0

    while 1
        let loop_num += 1
        let index = g:far#status_line ? 1 : 0
        let new_index = index
        let new_lnum1 = lnum1
        let new_lnum2 = lnum2

        for file_ctx in far_ctx.items
            let index += 1
            let new_index += 1
            let this_buf = 0
            let is_start_buff = 0
            let is_end_buff = 0

            let this_buf = this_buf || (lnum1 <= index && index <= lnum2)

            if file_ctx.collapsed || lnum2 == index
                let is_start_buff = is_start_buff || (lnum1 == index)
                let is_end_buff = is_end_buff || (lnum2 == index)
            else
                for item_ctx in file_ctx.items
                    let index += 1
                    let this_buf = this_buf || (lnum1 <= index && index <= lnum2)
                    let is_start_buff = is_start_buff || (lnum1 == index)
                    let is_end_buff = is_end_buff || (lnum2 == index)
                    if index >= lnum2
                        break
                    endif
                endfor
            endif

            if this_buf
                if a:cmode == -2
                    if loop_num == 1
                        let all_collapsed = file_ctx.collapsed && all_collapsed
                    else
                        let file_ctx.collapsed = ! all_collapsed
                    endif
                else
                    let file_ctx.collapsed = (a:cmode == -1)? !file_ctx.collapsed : a:cmode
                endif
            endif


            let new_lnum1 = is_start_buff ? new_index : new_lnum1
            let new_index += ( file_ctx.collapsed ? 0 : len(file_ctx.items) )
            let new_lnum2 = is_end_buff ? new_index : new_lnum2


            if index >= lnum2
                break
            endif

        endfor

        if a:cmode == -2
            if loop_num >= 2
                break
            endif
        else
            break
        endif

    endwhile

    call s:update_far_buffer(far_ctx, bufnr)

    let new_pos1 = pos1
    let new_pos2 = pos2
    let new_pos1[1:2] = [new_lnum1,0]
    let new_pos2[1:2] = [new_lnum2,0]

    call setpos("'<", new_pos1)
    call setpos("'>", new_pos2)
    exe 'normal! gv$'
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

function! far#ModePromptComplete(arglead, cmdline, cursorpos) abort
    let all_params_meta = extend(copy(s:far_params_meta_vimgrep), s:win_params_meta)
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


    " let far_params['regexp'] = 1

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

    let win_params['far_params'] = far_params


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

    if !b:win_params.enable_replace
        call far#tools#echo_err('Replacement is disabled now! Maybe you are using "far" find without replacement!')
        return
    endif

    if !exists('b:far_ctx')
        call far#tools#echo_err('Not a FAR buffer!')
        return
    endif

    if exists('g:gitgutter_enabled')
        let old_gitgutter_enabled = g:gitgutter_enabled
        let g:gitgutter_enabled = 0
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

    let undonum_list = []
    let undoitems_list = []
    let temp_files = []

    for file_ctx in far_ctx.items
        call far#tools#log('replacing buffer '.file_ctx.fname)
        exe 'buffer! '. bufnr

        let cmds = []
        let items = []
        let delta_cnums = {}
        for item_ctx in file_ctx.items
            if !item_ctx.excluded && !item_ctx.replaced
                let cmd = item_ctx.lnum.'s/\%'.item_ctx.cnum.'c'.
                    \   escape(far_ctx.pattern_proc, '/').'/'.
                    \   escape(far_ctx.replace_with, '/').'/e#'

                call add(cmds, cmd)
                call add(items, item_ctx)

                if has_key(item_ctx, 'match')
                    let match_val = get(item_ctx, 'match')
                else
                    let match_val = matchstr(item_ctx.text, far_ctx.pattern_proc, item_ctx.cnum-1)
                    let multiline = match(far_ctx.pattern_proc, '\\n') >= 0
                    if multiline
                        let match_val = item_ctx.text[item_ctx.cnum:]
                        let match_val = match_val.g:far#multiline_sign
                    endif
                    let match_val = get(item_ctx, 'match', match_val)
                endif

                if far_ctx.regex
                    let repl_val = substitute(match_val, far_ctx.pattern_proc, far_ctx.replace_with, "")
                else
                    let repl_val = far_ctx.replace_with
                endif

                let delta_cnum = len(repl_val) - len(match_val)
                if delta_cnum
                    if !has_key(delta_cnums, item_ctx.lnum)
                        let delta_cnums[item_ctx.lnum] = {}
                    endif
                    let delta_cnums[item_ctx.lnum][item_ctx.cnum] = delta_cnum
                endif
            endif
        endfor

        let undonum = -1
        let undoitems = []

        if !empty(cmds)
            let buf_repls = 0
            let cmds = reverse(cmds)

            if !bufloaded(file_ctx.fname)
                exec 'e! '.substitute(file_ctx.fname, ' ', '\\ ', 'g')
                if repl_params.auto_delete
                    call add(del_bufs, bufnr(file_ctx.fname))
                endif
                call add(temp_files, file_ctx.fname)
            endif
            exe 'buffer! '. bufnr

            let file_bufnr = bufnr(file_ctx.fname)
            exe 'buffer! '. string(file_bufnr)

            let undonum = far#tools#undo_nextnr()

            if !repl_params.auto_delete && !buflisted(file_ctx.fname)
                set buflisted
            endif
            if repl_params.auto_write && !(&mod)
                call add(cmds, 'write')
            endif

            let bufcmd = join(cmds, '|')
            call far#tools#log('bufdo: '.bufcmd)

            exe 'redir => s:bufdo_msgs'
            silent! exec bufcmd
            exe 'redir END'
            call far#tools#log('bufdo_msgs: '.s:bufdo_msgs)

            for item_ctx in file_ctx.items
                let old_cnum = item_ctx.cnum
                if has_key(delta_cnums, item_ctx.lnum)
                    for [others_cnum, delta_cnum] in items(delta_cnums[item_ctx.lnum])
                        if others_cnum < old_cnum
                            if !has_key(item_ctx, 'cnum_undo')
                                let item_ctx.cnum_undo = {}
                            endif
                            let item_ctx.cnum_undo[undonum] = old_cnum
                            let item_ctx.cnum += delta_cnum
                        endif
                    endfor
                endif
            endfor

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
        endif
        call add(undonum_list, undonum)
        call add(undoitems_list, undoitems)
    endfor
    let sum_undoitem_num = 0
    for undoitems in undoitems_list
        let sum_undoitem_num += len(undoitems)
    endfor

    if sum_undoitem_num
        for i in range(0, len(undonum_list)-1)
            call add(far_ctx.items[i].undos, {'num': undonum_list[i], 'items': undoitems_list[i]})
        endfor
    endif

    exec 'b! '.bufnr
    if !empty(del_bufs)
        call far#tools#log('delete buffers: '.join(del_bufs, ' '))
        exec 'silent bd! '.join(del_bufs, ' ')
    endif

    if !exists('b:temp_files')
        let b:temp_files = []
    endif
    let b:temp_files += temp_files
    let b:temp_files = uniq(sort(b:temp_files))

    let b:far_ctx.repl_time = printf('%.3fms', reltimefloat(reltime()) - start_ts)

    if exists('old_gitgutter_enabled') && exists('g:gitgutter_enabled')
        let g:gitgutter_enabled = old_gitgutter_enabled
    endif

    call s:update_far_buffer(b:far_ctx, bufnr)
endfunction "}}}

function! far#undo(xargs) abort "{{{
    call far#tools#log('far#undo('.string(a:xargs).')')

    if !b:win_params.enable_replace
        call far#tools#echo_err('Undo is disabled now! Maybe you are using "far" find without replacement!')
        return
    endif

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

        exec 'buffer! '. string(bufnr)
        let file_bufnr = bufnr(file_ctx.fname)
        if file_bufnr == -1
            continue
        endif
        exec 'buffer! ' . string(file_bufnr)

        let write_buf = undo_params.auto_write && !(&mod)

        " if undo_params.auto_delete && !bufexists(file_ctx.fname)
        if undo_params.auto_delete && !bufexists(file_bufnr)
            call add(del_bufs, file_bufnr)
        endif

        let undo_num = -1
        let items = []
        if undo_params.all

            for undo in file_ctx.undos
                let items += undo.items
            endfor

            " let undo_num = -1
            for undo in file_ctx.undos
                if len(undo.items)
                    let undo_num = undo.num
                    break
                endif
            endfor


            let file_ctx.undos = []
        else
            let undo = remove(file_ctx.undos, len(file_ctx.undos)-1)
            if len(undo.items)
                let undo_num = undo.num
            endif
            let items = undo.items
        endif

        if undo_num != -1
            exec 'silent! undo '. undo_num

            for item_ctx in file_ctx.items
                if has_key(item_ctx, 'cnum_undo') && has_key(item_ctx.cnum_undo, undo_num)
                    let item_ctx.cnum = item_ctx.cnum_undo[undo_num]
                endif
            endfor
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

function! s:proc_pattern_args(far_params, cmdargs) abort "{{{
    let pattern = a:far_params.pattern

    let multiline = match(pattern, '\n') != -1
    if multiline && ! (a:far_params.source == 'rg' || a:far_params.source == 'rgnvim' || a:far_params.source == 'vimgrep' )
        let source_subst = executable('rg') ? ( has('nvim') ? 'rgnvim' : 'rg') : 'vimgrep'
        call far#tools#echo_warn(a:far_params.source.' does not support multiline' .
            \ 'searching in far.vim. Use "' . source_subst . '" instead.')
        let a:far_params.source  = source_subst
    endif


    if a:far_params.regex
        let pattern = escape(pattern, '<>')
    else
        let pattern = substitute(pattern, '\\', '\\\\', 'g')
    endif
    let pattern = substitute(pattern, '\n', '\\n', 'g')

    if a:far_params.case_sensitive == 1
        let pattern = '\C'. pattern
    elseif a:far_params.case_sensitive == 0
        let pattern = '\c'. pattern
    endif

    if !a:far_params.regex && a:far_params.word_boundary
        let pattern = '\<'.pattern.'\>'
    elseif a:far_params.regex && a:far_params.word_boundary
        let pattern = '<'.pattern.'>'
    endif

    let pattern = (a:far_params.regex          ? '\v'   : '\V') . pattern
    let a:far_params.pattern_proc = pattern


    if a:far_params.source == 'rg' || a:far_params.source == 'rgnvim' ||
     \ a:far_params.source == 'ag' ||  a:far_params.source == 'agnvim'

        if !a:far_params.regex
            call add(a:cmdargs, '--fixed-strings')
        endif

        if a:far_params.case_sensitive == 1
            call add(a:cmdargs, '--case-sensitive')
        elseif a:far_params.case_sensitive == 0
            call add(a:cmdargs, '--ignore-case')
        else
            if &smartcase
                call add(a:cmdargs, '--smart-case')
            else
                if &ignorecase
                    call add(a:cmdargs, '--ignore-case')
                else
                    call add(a:cmdargs, '--case-sensitive')
                endif
            endif
        endif

        if a:far_params.word_boundary
            call add(a:cmdargs, '--word-regexp')
        endif

        if multiline
            call add(a:cmdargs, '--multiline')
        endif
    elseif a:far_params.source == 'ack' ||  a:far_params.source == 'acknvim'
        if !a:far_params.regex
            call add(a:cmdargs, '--literal')
        endif

        if a:far_params.case_sensitive == 1
            call add(a:cmdargs, '--no-ignore-case')
        elseif a:far_params.case_sensitive == 0
            call add(a:cmdargs, '--ignore-case')
        else
            if &smartcase
                call add(a:cmdargs, '--smart-case')
            else
                if &ignorecase
                    call add(a:cmdargs, '--ignore-case')
                else
                    call add(a:cmdargs, '--no-ignore-case')
                endif
            endif
        endif

        if a:far_params.word_boundary
            call add(a:cmdargs, '--word-regexp')
        endif
    elseif a:far_params.source == 'vimgrep'
        let a:far_params.pattern = pattern
    endif
endfunction
" }}}

function! s:assemble_context(far_params, win_params, cmdargs, callback, cbparams) abort "{{{
    if far#tools#isdebug()
        call far#tools#log('assemble_context('.string(a:far_params).','.string(a:win_params).')')
    endif

    call s:proc_pattern_args(a:far_params, a:cmdargs)


    if empty(a:far_params.pattern)
        call far#tools#echo_err('No pattern')
        return
    elseif empty(a:far_params.file_mask)
        call far#tools#echo_err('No file mask')
        return
    endif

    try
        call matchstr('str', a:far_params.pattern)
    catch
        call far#tools#echo_err('Invalid pattern regex: '.v:exception)
        return
    endtry

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

    if !empty(get(a:exec_ctx, 'warning', ''))
        call far#tools#echo_warn(a:exec_ctx.warning)
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
        let win_width = a:win_params.width - 1

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


        if strchars(statusline) < win_width
            let statusline = statusline.repeat(' ', win_width - strchars(statusline))
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
        let num_excluded = 0
        for item_ctx in file_ctx.items
            if !item_ctx.excluded && !item_ctx.replaced
                let num_matches += 1
            endif
            if item_ctx.excluded
                let num_excluded +=1
            endif
        endfor


        let file_sep = has('unix')? '/' : '\'
        let filestats = ' ('.len(file_ctx.items).' matches)'
        let maxfilewidth = win_width - strchars(filestats) - strchars(collapse_sign) + 1
        let fileidx = strridx(file_ctx.fname, file_sep)
        if fileidx == -1
            let filepath = far#tools#cut_text_middle(file_ctx.fname, maxfilewidth/2)
        else
            let filepath = far#tools#cut_text_middle(file_ctx.fname[:fileidx-1], maxfilewidth/2 - (maxfilewidth % 2? 0 : 1) - 1).
                \ file_sep.far#tools#cut_text_middle(file_ctx.fname[fileidx+1:], maxfilewidth/2)
        endif
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
            elseif num_excluded > 0
                let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
                call add(syntaxs, excl_syn)
            else
                let bname_syn = 'syn region FarReplacedFilePath start="\%'.line_num.
                    \   'l^.."hs=s+'.strchars(collapse_sign).' end=".\{'.strchars(filepath).'\}"'
                call add(syntaxs, bname_syn)
                let bstats_syn = 'syn region FarFileStats start="\%'.line_num.'l^.\{'.
                    \   (strchars(filepath)+strchars(collapse_sign)+2).'\}"hs=e end="$" contains=FarReplacedFilePath keepend'
                call add(syntaxs, bstats_syn)
            endif
        endif

        if !file_ctx.collapsed
            for item_ctx in file_ctx.items
                let line_num += 1
                let line_num_text = '  '.item_ctx.lnum
                let line_num_col_text = line_num_text.repeat(' ', 8-strchars(line_num_text))
                let pattern = a:far_ctx.pattern
                let pattern = b:win_params.far_params.pattern_proc

                let match_val = matchstr(item_ctx.text, pattern, item_ctx.cnum-1)
                let multiline = match(pattern, '\\n') >= 0
                if multiline
                    let match_val = item_ctx.text[item_ctx.cnum:]
                    let match_val = match_val.g:far#multiline_sign
                endif

                let match_val = get(item_ctx, 'match', match_val)


                if a:win_params.result_preview && !multiline && !item_ctx.replaced
                    " strdisplaywidth: actual displayed width, so as to deal with wide characters
                    let max_text_len = win_width / 2 - strdisplaywidth(line_num_col_text)
                    let max_repl_len = win_width / 2 - strdisplaywidth(g:far#repl_devider)
                    if b:win_params.far_params.regex
                        " item_ctx.cnum : byte id (begin with 1) the matched substring start from
                        let repl_val = substitute(match_val, pattern, a:far_ctx.replace_with, "")
                    else
                        let repl_val = a:far_ctx.replace_with
                    endif

                    let repl_text = (item_ctx.cnum == 1? '' : item_ctx.text[0:item_ctx.cnum-2]).
                        \   repl_val. item_ctx.text[item_ctx.cnum+len(match_val)-1:] " change to len, to support replacing wide char

                    let match_text = far#tools#centrify_text(item_ctx.text, max_text_len, item_ctx.cnum)
                    let repl_text = far#tools#centrify_text(repl_text, max_repl_len, item_ctx.cnum)
                    let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
                else
                    let max_text_len = win_width - strchars(line_num_col_text)
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

    " in case someone has set that a new buf starts in insert mode
    stopinsert

    syntax clear
    set syntax=far
    for buf_syn in buff_content.syntaxs
        exec buf_syn
    endfor

    call setbufvar(a:bufnr, 'far_ctx', a:far_ctx)
endfunction "}}}

function! far#close_far_buff() abort range "{{{
    call far#tools#log('far#close_far_buff() ' . bufnr('%') . ' ' . bufname('%'))

    if !empty(b:temp_files)
        call far#tools#log('delete buffers: '.join(b:temp_files, ' '))
        exec 'silent bd! '.join(b:temp_files, ' ')
    endif

    let parent_buffnr = b:win_params.parent_buffnr
    bdelete

    let winnr = bufwinnr(parent_buffnr)
    if winnr != -1
        exe winnr . "wincmd w"
    endif
endfunction
" }}}

function! s:open_far_buff(far_ctx, win_params) abort "{{{
    call far#tools#log('open_far_buff('.string(a:win_params).')')

    let parent_buffnr = bufnr('%')
    " let parent_buff_path = expand('%:p')
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

    let a:win_params['parent_buffnr'] = parent_buffnr
    call setbufvar(bufnr, 'win_params', a:win_params)

    if a:win_params.mode_prompt
        call far#set_mappings(s:prompt_mapping_keys, s:prompt_act_func_ref)
    else
        if g:far#default_mappings
            call g:far#apply_default_mappings()
        endif
        call s:update_far_buffer(a:far_ctx, bufnr)
        call setbufvar(bufnr, 'temp_files', [])
    endif

    call s:start_resize_timer()

    if !a:win_params.mode_prompt
        let b:win_params.preview_on = a:win_params.auto_preview &&
                                         \ a:win_params.auto_preview_on_start
        if a:win_params.auto_preview
            if v:version >= 704
                autocmd CursorMoved <buffer> if b:win_params.preview_on |
                    \   call g:far#show_preview_window_under_cursor() | endif
            else
                call far#tools#echo_err('auto preview is available on vim 7.4+')
            endif
        endif
        " if !a:win_params.auto_preview_on_start
        "     call far#show_preview_window_under_cursor()
        "     call far#close_preview_window()
        " endif
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
        let a:far_params.pattern = substitute(a:far_params.pattern, "\<C-M>", '\\n', 'g')
    endif

    let a:far_params.replace_with = substitute(a:far_params.replace_with,  "\<C-M>", '\\r', 'g')

    if a:far_params.file_mask == '%'
        let a:far_params.cwd = expand('%:p:h')
        let filename = bufname('%')
        let a:far_params.file_mask = filename
        if !filereadable(filename)
            call far#tools#echo_err('File in current buffer is not readable.')
            let a:far_params.file_mask = ''
            return
        endif
    endif
endfunction "}}}

function! s:pyglob_param_proc(far_params, win_params, cmdargs) "{{{
    call far#tools#log('pyglob_param_proc()')
    if a:far_params.file_mask == '%'
        let filename = expand('%:t')
        let a:far_params.file_mask = '/' . filename
        let a:far_params.cwd = expand('%:p:h')
        if !filereadable(expand('%:p'))
            call far#tools#echo_err('File in current buffer is not readable.')
            let a:far_params.file_mask = ''
            return
        endif
    endif
    call s:param_proc(a:far_params, a:win_params, a:cmdargs)
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:

if !exists('g:far#show_prompt_key')
    let g:far#show_prompt_key=1
endif

let s:default_prompt_mapping={
    \ 'quit'           : { 'key' : '<esc>', 'prompt' : 'Esc' },
    \ 'regex'          : { 'key' : '<c-x>', 'prompt' : '^X'  },
    \ 'case_sensitive' : { 'key' : '<c-c>', 'prompt' : '^C'  },
    \ 'word'           : { 'key' : '<c-w>', 'prompt' : '^W'  },
    \ 'substitute'     : { 'key' : '<c-s>', 'prompt' : '^S'  },
    \ }

if !exists('g:far#prompt_mapping')
    let g:far#prompt_mapping = s:default_prompt_mapping
else
    for key in keys(s:default_prompt_mapping)
        let g:far#prompt_mapping[key] = get(g:far#prompt_mapping, key,
            \ s:default_prompt_mapping[key])
    endfor
endif

let s:prompt_mapping_keys = {}
let s:prompt_key_display = {}
for key in keys(g:far#prompt_mapping)
    let s:prompt_mapping_keys[key] = g:far#prompt_mapping[key]['key']
    let s:prompt_key_display[key] = g:far#prompt_mapping[key]['prompt']
endfor

let s:far_prompt_escape = "\<c-o>"

let s:prompt_act_func_ref={
    \ 'quit'           : {'cnoremap': '<c-e>q'.s:far_prompt_escape.'<cr>'},
    \ 'regex'          : {'cnoremap': '<c-e>x'.s:far_prompt_escape.'<cr>'},
    \ 'case_sensitive' : {'cnoremap': '<c-e>c'.s:far_prompt_escape.'<cr>'},
    \ 'word'           : {'cnoremap': '<c-e>w'.s:far_prompt_escape.'<cr>'},
    \ 'substitute'     : {'cnoremap': '<c-e>s'.s:far_prompt_escape.'<cr>'},
    \ }


function! s:mode_prompt_update()  abort "{{{
    hi FarModeOpen ctermfg=0 ctermbg=lightgray

    let mode_list = ["regex", "case_sensitive", "word", "substitute"]
    let far_mode_icon = {
        \ "regex" : ".*",
        \ "case_sensitive"  : "Aa",
        \ "word" : '""',
        \ "substitute": "⬇ ",
        \ }

    let new_prompt=''
    for mode in mode_list
        let new_prompt.='%* '
        if g:far#mode_open[mode] == 1
            let new_prompt.='%#FarModeOpen#'
        else
            let new_prompt.='%*'
        endif
        let new_prompt.=far_mode_icon[mode]
        let new_prompt.='%*'
        if g:far#show_prompt_key
            let new_prompt.='('.s:prompt_key_display[mode].')'
        endif
    endfor

    set laststatus=2
    call setwinvar(winnr(), '&statusline', new_prompt)
    redrawstatus
endfunction " }}}


function! far#mode_prompt_open() abort "{{{
    let far_ctx = ''
    let win_params = s:create_win_params()
    let win_params['layout'] = 'bottom'
    let win_params['height'] = 0
    let win_params['mode_prompt'] = 1
    call s:open_far_buff(far_ctx, win_params)
endfunction
" }}}


function! far#mode_prompt_close() abort "{{{
    bdelete
endfunction " }}}


function! far#mode_prompt_get_item(item_name, default_item, complete_list) abort "{{{
    call s:mode_prompt_update()
    let item=a:default_item
    while 1
        let item = input(a:item_name.': ', item, a:complete_list)
        if strcharpart(item, strchars(item)-1,1) == s:far_prompt_escape
            let mode=strcharpart(item, strchars(item)-2,1)
            if mode == 'q'
                call far#mode_prompt_close()
                return ''
            endif
            if mode == 'x'
                let g:far#mode_open['regex'] = ! g:far#mode_open['regex']
            elseif mode == 'c'
                let g:far#mode_open['case_sensitive'] = ! g:far#mode_open['case_sensitive']
            elseif mode == 'w'
                let g:far#mode_open['word'] = ! g:far#mode_open['word']
            elseif mode == 's'
                let g:far#mode_open['substitute'] = ! g:far#mode_open['substitute']
            endif
            call s:mode_prompt_update()
            let item=strcharpart(item, 0, strchars(item)-2)

            if !g:far#mode_open['substitute'] && a:item_name=='Replace with'
                return 'disabled subsitution'
            endif
        elseif item != ''
            break
        endif
    endwhile
    return item
endfunction " }}}
