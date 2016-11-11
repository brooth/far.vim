" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far') && !far#tools#isdebug() "{{{
    finish
endif "}}}

" TODO beta2 {{{
" (X) Farundo
" (X) cut filename if long
" (X) FIXME: closing preview window should disable auto preview
" (X) FIXME: jump to buffer fails on file names with spaces
" (X) Refar params [--pattern=,--replace-with, --file-mask]
" (X) alternative sources. pass source as Far param
" (X) rename buf_ctx -> file_ctx, bufname -> fname, far_ctx.items -> list
" (X) Ag
" (X) remap review scrolling to <c-j><c-k>
" (X) auto 'vimgrep' source for multiline pattern
" (X) move business logic to autoload
" complete Refar with current values
" FIXME: far#log -> far#log not working
" FIXME: partial selecion in one line work as full line
" FIXME: ag not find many matches in one line
" Ack
" fzf
" Async, Neovim, Vim8
" Find in <range> if pattern is not *
" FIXME: one jump window for each jump
" FIXME: remember preview window size ???
" /dev/shm for temp files
"}}}

function! Far(cmdline, fline, lline) range abort "{{{
    call far#tools#log('=============== FAR ================')
    call far#tools#log('cmdline: '.a:cmdline)

    let cargs = far#tools#splitcmd(a:cmdline)
    if len(cargs) < 3
        call far#tools#echo_err('Arguments required. Format :Far <pattern> <replace> <filemask> [<param1>...]')
        return
    endif

    call far#find(cargs[0], cargs[1], cargs[2], a:fline, a:lline, cargs[3:])
endfunction
command! -complete=customlist,far#FarComplete -nargs=1 -range Far call Far('<args>',<line1>,<line2>)
"}}}

function! FarPrompt(...) abort range "{{{
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

    call far#find(pattern, replace_with, file_mask, a:firstline, a:lastline, a:000)
endfunction
command! -complete=customlist,far#FarArgsComplete -nargs=* -range Farp <line1>,<line2>call FarPrompt(<f-args>)
"}}}

function! Refar(...) abort "{{{
    call far#tools#log('============== REFAR  ==============')
    call far#refind(a:000)
endfunction
command! -complete=customlist,far#RefarComplete -nargs=* Refar call Refar(<f-args>)
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
