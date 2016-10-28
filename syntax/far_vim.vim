"=================================================
" File: far_vim.vim
" Description: far.vim syntax
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

hi def link FarFileStats Comment
hi def link FarFilePath Title
hi def link FarSearchVal Statement
hi def link FarReplaceVal Title
hi def link FarExcludedItem NonText
hi def link FarReplacedItem Conceal
hi def link FarLineCol LineNr
hi def link FarPreviewMatch Search

syn match FarNone ".*" contains=FarSearchVal,FarReplaceVal,FarItem
syn match FarLineCol "^..\d*" contains=FarSearchVal,FarReplaceVal,FarItem
