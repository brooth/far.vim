"=================================================
" File: far_vim.vim
" Description: far.vim syntax
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

hi def link FarFileStats Comment
hi def link FarFilePath Title
hi def link FarSearchVal Statement
hi def link FarReplaceVal Special
hi def link FarExcludedItem NonText
hi def link FarLineCol LineNr

syn match FarNone ".*" contains=FarSearchVal,FarReplaceVal,FarItem
syn match FarLineCol "^\ \ \d*:\d*" contains=FarSearchVal,FarReplaceVal,FarItem
