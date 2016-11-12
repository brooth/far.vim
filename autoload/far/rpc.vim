" File: rpc.vim
" Description: far.py python rpc helper
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

if !has('python3')
    throw 'python3 is required'
endif

if far#tools#isdebug() " redirect python logging to vim if debug {{{
python3 << EOL
import logging, vim

class VimLoggerHandler(logging.Handler):
    def emit(self, record):
        msg = self.format(record).replace('"', '`')
        vim.command('call far#tools#log("farpy:' + msg + '")')

logger = logging.getLogger('far')
logger.addHandler(VimLoggerHandler())
logger.setLevel(logging.DEBUG)
EOL
endif "}}}

" add far package to sys.path {{{
let farpy_path = fnamemodify(expand('<sfile>'), ':p:h:h:h').'/rplugin/python3'
exec 'python3 sys.path.insert(0, "'.farpy_path.'")'
"}}}

function! far#rpc#invoke(imports, evalstr) abort "{{{
    let cmd = ['def far_rpc_invoker():']
    for import in a:imports
        call add(cmd, ' import '.import)
    endfor
    call add(cmd, ' return '.a:evalstr)
    call far#tools#log('invoke cmd:'.string(cmd))

    exec 'py3 '.join(cmd, '')
    let result = py3eval('far_rpc_invoker()')
    call far#tools#log('invoke res:'.string(result))
    exec 'py3 del far_rpc_invoker'

    return result
endfunction "}}}

function! far#rpc#nvim_invoke(execlist) abort "{{{
    call far#tools#log('far#rpc#nvim_invoke('.string(a:execlist).')')
    try
        if !exists('g:loaded_remote_plugins')
            runtime! plugin/rplugin.vim
        endif
        let result = _far_nvim_rpc_async_invoke(a:execlist)
    catch
        call far#tools#log('nvim invoke error:'.string(v:exception))
        echoerr 'Failed to invoke nvim plugin. Try the :UpdateRemotePlugins and restart Neovim'
        return
    endtry
    call far#tools#log('nvim invoke res:'.string(result))
    return result
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
