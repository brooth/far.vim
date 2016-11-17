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
" (X) move business logic to autoload
" (X) cwd param (current working directory)
" (X) limit
" (X) Neovim async
" (X) FIXME: far#log -> far#log masked as broken
" (X) FIXME: set filetype=off if already open
" (X) FIXME: far undo is broken? on broken strings?
" (X) FIXME: partial selecion in one line work as full line, syn is broken as well
" (?) FIXME: undo issue: far-fardo, manual undo, farundo
" (X) remove jump setting, always open in far window
" (X) FIXME: DA search by Activity fails on 500
" (X) shell.py instead of ag.py. pass cmd and configs via 'args'
" (X) vimcmd.vim instead of vimgrep and greppg
" (X) cmdargs: pass to source not processed cmd params
" (X) complete Refar with current values
" (X) complete cwd
" (?) FIXME: highlight issue: Far number num **/*.py --win=top --preview=right
" (X) fix_cnum: search column number manually (all - fzf?, next modes -ag,ack)
" (X) Ack
" (X) FIXME: command completion doens't respect cursor position
" (X) FIXME: limit doensn't respect fix_cnum items
" (?) FIXME: --result-preview=0 not working
" (X) F command - only find (--result-preview=0 by default, disable fardo for this)
" (X) remove greppg source
" (X) override source args, 'suggest' flag (suggest for completion)
" (X) return tmp file instead of items if big amount
" (X) <range> support
" (X) FIXME: win_params not applied (floating bug)
" (X) FIXME: cursor position not working if inside a param (command completion)
" amend to doc
"}}}

function! Find(rngmode, rngline1, rngline2, cmdline, ...) range abort "{{{
    call far#tools#log('=============== FIND ================')
    call far#tools#log('cmdline: '.a:cmdline)

    let cargs = far#tools#splitcmd(a:cmdline)
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
command! -complete=customlist,far#FindComplete -nargs=1 -range=-1 F
    \   call Find(<count>, <line1>, <line2>, '<args>')
"}}}

function! Far(rngmode, rngline1, rngline2, cmdline) range abort "{{{
    call far#tools#log('=============== FAR ================')
    call far#tools#log('cmdline: '.a:cmdline)

    let cargs = far#tools#splitcmd(a:cmdline)
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
command! -complete=customlist,far#FarComplete -nargs=1 -range=-1 Far
    \   call Far(<count>,<line1>,<line2>,'<args>')
"}}}

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
