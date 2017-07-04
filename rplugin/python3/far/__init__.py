"""
File: nvim.py
Description: Async source invocation through neovim api
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

try:
    import neovim
    import logging
    import importlib

    logger = logging.getLogger('far')


    @neovim.plugin
    class FarPlugin(object):

        def __init__(self, nvim):
            self.nvim = nvim

            if nvim.eval('far#tools#isdebug()'):
                logger.addHandler(NeoVimLoggerHandler(nvim))
                logger.setLevel(logging.DEBUG)

        @neovim.function('_far_nvim_rpc_async_invoke', sync=False)
        def _far_nvim_rpc_invoke(self, args):

            logger.debug('_far_nvim_rpc_invoke(%s)', str(args))
            for execline in args[0]:
                exec(execline)


    class NeoVimLoggerHandler(logging.Handler):
        def __init__(self, nvim):
            super().__init__()
            self.nvim = nvim

        def emit(self, record):
            msg = self.format(record).replace('"', '`')
            self.nvim.command('call far#tools#log("farnvim:' + msg + '")')

except ImportError:
    pass

