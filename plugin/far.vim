" File: far.vim
" Description: Find And Replace
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if exists('g:loaded_far')
    finish
endif

" options {{{
let g:far#window_width = 100
let g:far#repl_devider = '  >  '

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


function! Far(pattern, path, replace_with)
    let far_ctx = s:assemble_context(a:pattern, a:replace_with, a:path)
    let buff_content = s:build_buffer_content(far_ctx)
    call s:open_far_buffer(buff_content.content, buff_content.syntaxs)
endfunction

function! s:assemble_context(pattern, replace_with, files_mask) abort "{{{
    let qfitems = getqflist()
    exec 'vimgrep/'.a:pattern.'/gj '.a:files_mask
    let items = getqflist()
    call setqflist(qfitems, 'r')

    if empty(items)
        return
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
            let buf_ctx.readonly = 0    "TODO: readonly?
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
        let item_ctx.repl_text = front.substitute(item.text[item.col-1:9999],
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
    for ctx_key in keys(a:far_ctx.items)
        let ctx = a:far_ctx.items[ctx_key]
        if ctx_key[0] == 'b'
            let line_num = len(content)+1

            let bname = bufname(ctx.bufnr)
            let bname_syn = 'syn region FarFilePath start="\%'.line_num.
                \   'l^.."hs=s+2 end=".\{'.(len(bname)).'\}"'
            call add(syntaxs, bname_syn)
            let bstats_syn = 'syn region FarFileStats start="\%'.line_num.
                \   'l^.\{'.(len(bname)+3).'\}"hs=e end="$" contains=FarFilePath keepend'
            call add(syntaxs, bstats_syn)

            let out = '+ '.bname.' ['.ctx.bufnr.'] ('.len(ctx.items).' matches)'
            call add(content, out)
        endif

        for item_ctx in ctx.items
            let line_num = len(content)+1

            " Number Column
            let line_num_text = item_ctx.lnum.':'.item_ctx.col
            let line_num_col_text = '  '.line_num_text.repeat(' ', 8-len(line_num_text))
            "syn region FarLineColNmbr start="\%2l^"hs=s+2 end=".\{10\}"he=e-5
            let line_num_col_syn = 'syn region FarLineColNmbr start="\%'.line_num.
                \   'l^"hs=s+2 end=".\{'.(len(line_num_col_text)).'\}"he=e-'.
                \   (len(line_num_col_text)-len(line_num_text)-2)
            call add(syntaxs, line_num_col_syn)

            " Match Column
            let max_text_len = g:far#window_width / 2 - len(line_num_col_text) - 1
            let max_repl_len = g:far#window_width / 2 - len(g:far#repl_devider) - 4
            let match_text = s:limit_text(item_ctx.match_text, max_text_len, item_ctx.col, 5)

            "syn region FarSearchText start="\%3l^.\{17\}"hs=e+1 end=".\{3\}" contains=FarLineColNmbr keepend
            let match_col_syn = 'syn region FarSearchText start="\%'.line_num.
                \   'l^.\{'.(len(line_num_col_text)+match_text.centr-1).'\}"hs=e+1'.
                \   ' end="'.item_ctx.match_val.'" contains=FarLineColNmbr keepend'
            call add(syntaxs, match_col_syn)

            " Devider Column
            let devi_col_syn = 'syn region FarDevider start="\%'.line_num.'l^.\{'.
                \   (len(line_num_col_text)+len(match_text.text)).
                \   '\}"hs=e+1 end=".\{'.len(g:far#repl_devider).'\}" contains=FarSearchText keepend'
            call add(syntaxs, devi_col_syn)

            " Replace Column
            let repl_text = s:limit_text(item_ctx.repl_text, max_repl_len, item_ctx.col, 5)
            let repl_col_syn = 'syn region FarReplaceText start="\%'.line_num.'l^.\{'.
                \   (len(line_num_col_text)+len(match_text.text)+len(g:far#repl_devider)+repl_text.centr-1).
                \   '\}"hs=e+1 end="'.item_ctx.repl_val.'" contains=FarDevider keepend'
            call add(syntaxs, repl_col_syn)

            let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
            call add(content, out)
        endfor
    endfor

    return {'content': content, 'syntaxs': syntaxs}
endfunction "}}}


function! s:open_far_buffer(content, syntaxs) abort "{{{
    let bufname = g:far#window_name.' '.g:far#buffer_counter
    let bufnr = bufnr(bufname)
    if bufnr != -1
        let g:far#buffer_counter += 1
        call s:open_far_buffer(a:content, a:syntaxs)
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
    " setlocal statusline=%!t:undotree.GetStatusLine() TODO: done in 32ms...
    setfiletype far_vim

    call s:update_far_buffer(bufnr, a:content, a:syntaxs)
endfunction "}}}


function! s:update_far_buffer(bufnr, content, syntaxs) abort "{{{
    let winnr = bufwinnr(a:bufnr)
    if winnr == -1
        echoerr 'far buffer not open'
        return
    endif

    if winnr != winnr()
        exec 'norm! '.winnr.'\<c-w>\<c-w>'
    endif

    setlocal modifiable
    call append(0, a:content)
    setlocal nomodifiable

    syntax clear
    set syntax=far_vim
    for buf_syn in a:syntaxs
        exec buf_syn
    endfor
endfunction "}}}


function! s:limit_text(text, limit, centr, shift) abort "{{{
    let text = copy(a:text)
    let centr = a:centr
    if len(text) > a:limit
        if a:centr > a:limit/2
            let left_start = a:centr - a:limit/2 + a:shift
            let centr = a:centr - left_start + 2
            let text = '..'.a:text[left_start:9999]
        endif
    endif
    if len(text) > a:limit
        let text = text[0:a:limit-3].'..'
    else
        let text = text.repeat(' ', a:limit - len(text))
    endif

    return {'text': text, 'centr': centr}
endfunction "}}}

" let g:loaded_far = 0

" vim: set et fdm=marker sts=4 sw=4:
