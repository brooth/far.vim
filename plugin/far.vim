" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far') && !far#tools#isdebug() "{{{
    finish
endif "}}}

" TODO beta3 {{{
" (?) FIXME: highlight issue: Far number num **/*.py --win=top --preview=right
" refar in current result (special source..)
" nodes.
" nodes nesting param: how many modes to show. the rest show as one node
" smart nesting: group same nodes in one: [foo/bar]/baz.py and [foo/bar]/boo.py
" quickfix as --win-layout
" async build_far_buffer (https://gist.github.com/mhinz/1d62b803d328f83551e15c97a4b57868)
" vim8 async support
" test coverage
"}}}

function! Find(rngmode, rngline1, rngline2, cmdline, ...) range abort "{{{
    call far#tools#log('=============== FIND ================')
    call far#tools#log('cmdline: '.a:cmdline)

    let cargs = far#tools#splitcmd(a:cmdline)
    if len(cargs) == 1
        call add(cargs, g:far#default_file_mask)
    endif
    if len(cargs) < 2
        call far#tools#echo_err('Arguments required. Format :F <pattern> <filemask> [<param1>...]')
        return
    endif
    call add(cargs, '--result-preview=0')

    let far_params = {
        \   'pattern': cargs[0],
        \   'replace_with': cargs[0],
        \   'file_mask': cargs[1],
        \   'range': a:rngmode == -1? [-1,-1] : [a:rngline1, a:rngline2],
        \   }

    call far#find(far_params, cargs[2:])
endfunction
command! -complete=customlist,far#FindComplete -nargs=+ -range=-1 F
    \   call Find(<count>,<line1>,<line2>,<q-args>)
"}}}

function! Far(rngmode, rngline1, rngline2, cmdline) range abort "{{{
    call far#tools#log('=============== FAR ================')
    call far#tools#log('cmdline: '.a:cmdline)

    let cargs = far#tools#splitcmd(a:cmdline)
    if len(cargs) == 2
        call add(cargs, g:far#default_file_mask)
    endif
    if len(cargs) < 3
        call far#tools#echo_err('Arguments required. Format :Far <pattern> <replace> <filemask> [<param1>...]')
        return
    endif

    let far_params = {
        \   'pattern': cargs[0],
        \   'replace_with': cargs[1],
        \   'file_mask': cargs[2],
        \   'range': a:rngmode == -1? [-1,-1] : [a:rngline1, a:rngline2],
        \   }

    call far#find(far_params, cargs[3:])
endfunction
command! -complete=customlist,far#FarComplete -nargs=+ -range=-1 Far
    \   call Far(<count>,<line1>,<line2>,<q-args>)
"}}}

let g:far_mode_open =  {
    \ "regex" : 1,
    \ "case_sensitive"  : 0,
    \ "word" : 0,
    \ "subsitute": 0,
    \ }
let g:far_mode_fix =  {
    \ "regex" : 0,
    \ "case_sensitive"  : 0,
    \ "word" : 0,
    \ "subsitute": 0,
    \ }

function! UpdateModePrompt()  abort "{{{
    hi FarModeOpen ctermfg=0 ctermbg=lightgray

    let mode_list = ["regex", "case_sensitive", "word", "subsitute"]
    let far_mode_icon = {
        \ "regex" : ".*",
        \ "case_sensitive"  : "Aa",
        \ "word" : "“”",
        \ "subsitute": "⬇ ",
        \ }
    let far_mode_key = {
        \ "regex" : "^X",
        \ "case_sensitive"  : "^C",
        \ "word" : "^W",
        \ "subsitute": "^S",
        \ }

    let new_prompt=''
    for mode in mode_list
        let new_prompt.='%* '
        if g:far_mode_open[mode] == 1
            let new_prompt.='%#FarModeOpen#'
        else
            let new_prompt.='%*'
        endif
        let new_prompt.=far_mode_icon[mode]
        let new_prompt.='%*'
        if !g:far_mode_fix[mode]
            let new_prompt.='('.far_mode_key[mode].')'
        endif
    endfor

    set laststatus=2
    " exec 'set statusline=' . new_prompt
    call setwinvar(winnr(), '&statusline', new_prompt)
    redrawstatus
endfunction
" }}}




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

" " let s:far_preview_buffer_name = 'Preview'
let s:farfind_buffer_counter = 1
let s:far_prompt_escape = "\<c-o>"

function! s:open_farfind_buff() abort "{{{
    call far#tools#log('open_farfind_buff()')

    let fname = printf('FAR %d', s:farfind_buffer_counter)
    let bufnr = bufnr(fname)
    if bufnr != -1
        let s:farfind_buffer_counter += 1
        call s:open_farfind_buff()
        return
    endif

    let cmd = 'botright 1 new "Far Find"'
    " far#tools#win_layout(a:win_params, '', fname)
    call far#tools#log('new bufcmd: '.cmd)
    exec cmd
    let bufnr = bufnr('%')
    let s:farfind_buffer_counter += 1

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

    " if g:far#default_mappings
    exec 'silent! cnoremap <buffer> <esc> <c-e>q'.s:far_prompt_escape.'<cr>'
    exec 'silent! cnoremap <buffer> <c-x> <c-e>x'.s:far_prompt_escape.'<cr>'
    exec 'silent! cnoremap <buffer> <c-c> <c-e>c'.s:far_prompt_escape.'<cr>'
    exec 'silent! cnoremap <buffer> <c-w> <c-e>w'.s:far_prompt_escape.'<cr>'
    exec 'silent! cnoremap <buffer> <c-s> <c-e>s'.s:far_prompt_escape.'<cr>'

    " <bs>
    " <esc>:call FarGetPatten()<cr><up>

    " call g:far#apply_default_mappings()
    " endif

    let win_params = s:create_win_params()
    call setbufvar(bufnr, 'win_params', win_params)
    " call s:update_far_buffer(a:far_ctx, bufnr)
    call s:start_resize_timer()

    " if a:win_params.auto_preview
    "     if v:version >= 704
    "         autocmd CursorMoved <buffer> if b:win_params.auto_preview |
    "             \   call g:far#show_preview_window_under_cursor() | endif
    "     else
    "         call far#tools#echo_err('auto preview is available on vim 7.4+')
    "     endif
    " endif
endfunction "}}}

function! FarModePromptClose() abort "{{{
    quit
    exec 'normal :echo'
endfunction
" }}}

function! FarGetItem(item_name, default_item, mode_changable) abort "{{{
    call UpdateModePrompt()
    let item=a:default_item
    while 1
        let item = input(a:item_name.': ', item, 'customlist,far#FarSearchComplete')
        if strcharpart(item, strchars(item)-1,1) == s:far_prompt_escape
            let mode=strcharpart(item, strchars(item)-2,1)
            if mode == 'q'
                call FarModePromptClose()
                return ''
            endif
            if mode == 'x'
                let g:far_mode_open['regex'] = ! g:far_mode_open['regex']
            elseif mode == 'c'
                let g:far_mode_open['case_sensitive'] = ! g:far_mode_open['case_sensitive']
            elseif mode == 'w'
                let g:far_mode_open['word'] = ! g:far_mode_open['word']
            elseif mode == 's' && a:mode_changable
                let g:far_mode_open['subsitute'] = ! g:far_mode_open['subsitute']
            endif
            call UpdateModePrompt()
            let item=strcharpart(item, 0, strchars(item)-2)

            if !g:far_mode_open['subsitute'] && a:item_name=='Replace with'
                return 'disabled subsitution'
            endif
        elseif item != ''
            break
        endif
    endwhile
    return item
endfunction
" }}}

function! FarModePrompt(rngmode, rngline1, rngline2, cmdline, ...) abort range "{{{
    call far#tools#log('=========== FAR MODE PROMPT ============')
    call s:open_farfind_buff()

    let cargs = far#tools#splitcmd(a:cmdline)

    let pattern = FarGetItem('Pattern', '',  1)
    if pattern == '' | return | endif
    call far#tools#log('>pattern: '.pattern)

    if g:far_mode_open['subsitute']
        let replace_with = FarGetItem('Replace with', '', 1)
        if replace_with == '' | return | endif
    endif
    let g:far_mode_fix['subsitute'] = 1

    if !g:far_mode_open['subsitute']
        let replace_with = pattern
        call add(cargs, '--result-preview=0')
    endif
    call far#tools#log('>replace_with: '.replace_with)


    let file_mask = FarGetItem('File mask', g:far#default_file_mask, 0)
    if file_mask == '' | return | endif
    call far#tools#log('>file_mask: '.file_mask)

    call FarModePromptClose()

    " disable escaped sequence
    let pattern= g:far_mode_open['regex'] ? pattern : substitute(pattern, '\\', '\\\\', 'g')
    let pattern = (g:far_mode_open['case_sensitive'] ? '\C' : '\c') . pattern
    let pattern = g:far_mode_open['word']            ? ('\<'.pattern.'\>') : pattern
    let pattern = (g:far_mode_open['regex']          ? ''   : '\V') . pattern

    let far_params = {
        \   'pattern': pattern,
        \   'replace_with': replace_with,
        \   'file_mask': file_mask,
        \   'range': a:rngmode == -1? [-1,-1] : [a:rngline1, a:rngline2],
        \   }

    call far#find(far_params, cargs)
endfunction
command! -complete=customlist,far#FarArgsComplete -nargs=* -range=-1 Farr
    \  let g:far_mode_open['subsitute'] = 1 | call FarModePrompt(<count>,<line1>,<line2>,<q-args>)
command! -complete=customlist,far#FarArgsComplete -nargs=* -range=-1 Farf
    \  let g:far_mode_open['subsitute'] = 0 | call FarModePrompt(<count>,<line1>,<line2>,<q-args>)
"}}}


" function! Find(rngmode, rngline1, rngline2, cmdline, ...) range abort "{{{
"     call far#tools#log('=============== FIND ================')
"     call far#tools#log('cmdline: '.a:cmdline)

"     let cargs = far#tools#splitcmd(a:cmdline)
"     if len(cargs) == 1
"         call add(cargs, g:far#default_file_mask)
"     endif
"     if len(cargs) < 2
"         call far#tools#echo_err('Arguments required. Format :F <pattern> <filemask> [<param1>...]')
"         return
"     endif
"     call add(cargs, '--result-preview=0')

"     let far_params = {
"         \   'pattern': cargs[0],
"         \   'replace_with': cargs[0],
"         \   'file_mask': cargs[1],
"         \   'range': a:rngmode == -1? [-1,-1] : [a:rngline1, a:rngline2],
"         \   }

"     call far#find(far_params, cargs[2:])
" endfunction
" command! -complete=customlist,far#FindComplete -nargs=+ -range=-1 F
"     \   call Find(<count>,<line1>,<line2>,<q-args>)
" "}}}


function! FarPrompt(rngmode, rngline1, rngline2, ...) abort range "{{{
    call far#tools#log('============ FAR PROMPT ================')

    let pattern = input('Search (pattern): ', '', 'customlist,far#FarSearchComplete')
    call far#tools#log('>pattern: '.pattern)
    if empty(pattern)
        call far#tools#echo_err('No pattern')
        return
    endif

    let replace_with = input('Replace with: ', '', 'customlist,far#FarReplaceComplete')
    call far#tools#log('>replace_with: '.replace_with)

    let file_mask = input('File mask: ', '', 'customlist,far#FarFileMaskComplete')
    call far#tools#log('>file_mask: '.file_mask)
    if empty(file_mask)
        call far#tools#echo_err('No file mask')
        return
    endif

    let far_params = {
        \   'pattern': pattern,
        \   'replace_with': replace_with,
        \   'file_mask': file_mask,
        \   'range': a:rngmode == -1? [-1,-1] : [a:rngline1, a:rngline2],
        \   }

    call far#find(far_params, a:000)
endfunction
command! -complete=customlist,far#FarArgsComplete -nargs=* -range=-1 Farp
    \   call FarPrompt(<count>,<line1>,<line2>,<f-args>)
"}}}

function! Refar(rngmode, rngline1, rngline2, ...) abort "{{{
    call far#tools#log('============== REFAR  ==============')
    call far#refind(a:rngmode == -1? [] : [a:rngline1, a:rngline2], a:000)
endfunction
command! -complete=customlist,far#RefarComplete -nargs=* -range=-1 Refar
    \   call Refar(<count>,<line1>,<line2>,<f-args>)
"}}}

function! FarDo(...) abort "{{{
    call far#tools#log('============= FAR DO ================')
    call far#replace(a:000)
endfunction
command! -complete=customlist,far#FardoComplete -nargs=* Fardo call FarDo(<f-args>)
"}}}

function! FarUndo(...) abort "{{{
    call far#tools#log('============= FAR UNDO ================')
    call far#undo(a:000)
endfunction
command! -complete=customlist,far#FarundoComplete -nargs=* Farundo call FarUndo(<f-args>)
"}}}

" loaded {{{
let g:loaded_far = 0
"}}}

" vim: set et fdm=marker sts=4 sw=4:
