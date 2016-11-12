"""
File: rplugin/python3/far/far.py
Description: far.vim python business logic
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

import os


# def build_far_content(far_ctx, win_params, vars):
#     content = []
#     syntaxs = []
#     line_num = 0

#     if win_params['highlight_match']:
#         syntaxs.extend([
#             'syn match FarNone ".*" contains=FarSearchVal,FarReplaceVal,FarItem',
#             'syn match FarLineCol "^..\d*" contains=FarSearchVal,FarReplaceVal,FarItem'])

#     if vars['g:far#status_line']:
#         line_num += 1
#         total_matches = 0
#         total_excludes = 0
#         total_repls = 0

#         for file_ctx in far_ctx['items']:
#             for item_ctx in file_ctx['items']:
#                 total_matches += 1
#                 total_excludes += item_ctx['excluded']
#                 total_repls += item_ctx['replaced']

#         statusline = 'Files:%d  Matches:%d  Excludes:%d  Time:%s' % \
#             (len(far_ctx['items']), total_matches, total_excludes, far_ctx['search_time'])

#         if far_ctx.get('repl_time'):
#             statusline += ' ~ Replaced:%d  Time:%s' % (total_repls, far_ctx['repl_time'])

#         if len(statusline) < win_params['width']:
#             statusline += ' ' * (win_params['width'] - len(statusline))

#         content.append(statusline)

#         if win_params['highlight_match']:
#             syntaxs.append('syn region FarStatusLine start="\%1l^" end="$"')

    # for file_ctx in far_ctx['items']:
    #     collapse_sign = vars['g:far#expand_sign'] if file_ctx['collapsed'] \
    #         else vars['g:far#collapse_sign']
    #     line_num += 1
    #     num_matches = 0
    #     for item_ctx in file_ctx['items']:
    #         if not item_ctx['excluded'] and not item_ctx['replaced']:
    #             num_matches += 1

        # filestats = ' (%d matches)' % len(file_ctx['items'])
        # maxfilewidth = win_params['width'] - len(filestats) - len(collapse_sign) + 1
        # fileidx = file_ctx['fname'].index(os.sep)
        # # filepath = far#tools#cut_text_middle(file_ctx.fname[:fileidx-1], maxfilewidth/2 - (maxfilewidth % 2? 0 : 1) - 1).
        # #     \ os.sep.far#tools#cut_text_middle(file_ctx.fname[fileidx+1:], maxfilewidth/2)
        # content.append(collapse_sign + filepath + filestats)

        # if win_params['highlight_match']:
        #     if num_matches > 0:
        #         syntaxs.append('syn region FarFilePath start="\%' + line_num +
        #             'l^.."hs=s+' + len(collapse_sign) + ' end=".\{' + len(filepath) + '\}"')
        #         syntaxs.append('syn region FarFileStats start="\%' + line_num + 'l^.\{' +
        #             (len(filepath)+len(collapse_sign)+2) + '\}"hs=e end="$" contains=FarFilePath keepend')
        #     else:
        #         syntaxs.append('syn region FarExcludedItem start="\%' + line_num + 'l^" end="$"')

    # return {'content': content, 'syntaxs': syntaxs}

#         if !file_ctx.collapsed
#             for item_ctx in file_ctx['items']
#                 let line_num += 1
#                 let line_num_text = '  '.item_ctx.lnum
#                 let line_num_col_text = line_num_text.repeat(' ', 8-len(line_num_text))
#                 let match_val = matchstr(item_ctx.text, a:far_ctx.pattern, item_ctx.cnum-1)
#                 let multiline = match(a:far_ctx.pattern, '\\n') >= 0
#                 if multiline
#                     let match_val = item_ctx.text[item_ctx.cnum:]
#                     let match_val = match_val.g:far#multiline_sign
#                 endif

#                 if win_params['result_preview'] && !multiline && !item_ctx.replaced
#                     let max_text_len = win_params['width'] / 2 - len(line_num_col_text)
#                     let max_repl_len = win_params['width'] / 2 - len(g:far#repl_devider)
#                     let repl_val = substitute(match_val, a:far_ctx.pattern, a:far_ctx.replace_with, "")
#                     let repl_text = (item_ctx.cnum == 1? '' : item_ctx.text[0:item_ctx.cnum-2]).
#                         \   repl_val.item_ctx.text[item_ctx.cnum+len(match_val)-1:]
#                     let match_text = far#tools#centrify_text(item_ctx.text, max_text_len, item_ctx.cnum)
#                     let repl_text = far#tools#centrify_text(repl_text, max_repl_len, item_ctx.cnum)
#                     let out = line_num_col_text.match_text.text.g:far#repl_devider.repl_text.text
#                 else
#                     let max_text_len = win_params['width'] - len(line_num_col_text)
#                     let match_text = far#tools#centrify_text((item_ctx.replaced ? item_ctx.repl_text : item_ctx.text),
#                         \   max_text_len, item_ctx.cnum)
#                     if multiline
#                         let match_text.text = match_text.text[:len(match_text.text)-
#                                     \   len(g:far#multiline_sign)-1].g:far#multiline_sign
#                     endif
#                     let out = line_num_col_text.match_text.text
#                 endif

#                 " Syntax
#                 if win_params['highlight_match']
#                     if item_ctx.replaced
#                         let excl_syn = 'syn region FarReplacedItem start="\%'.line_num.'l^" end="$"'
#                         call add(syntaxs, excl_syn)
#                     elseif item_ctx.excluded
#                         let excl_syn = 'syn region FarExcludedItem start="\%'.line_num.'l^" end="$"'
#                         call add(syntaxs, excl_syn)
#                     elseif get(item_ctx, 'broken', 0)
#                         let excl_syn = 'syn region FarBrokenItem start="\%'.line_num.'l^" end="$"'
#                         call add(syntaxs, excl_syn)
#                     else
#                         if win_params['result_preview'] && !multiline && !item_ctx.replaced
#                             let match_col = match_text.val_col
#                             let repl_col_h = len(repl_text.text) - repl_text.val_col - len(repl_val) + 1
#                             let repl_col_e = len(repl_text.text) - repl_text.val_idx + 1
#                             let line_syn = 'syn region FarItem matchgroup=FarSearchVal '.
#                                         \   'start="\%'.line_num.'l\%'.len(line_num_col_text).'c"rs=s+'.
#                                         \   (match_col+len(match_val)).
#                                         \   ',hs=s+'.match_col.' matchgroup=FarReplaceVal end=".*$"re=e-'.
#                                         \   repl_col_e.',he=e-'.repl_col_h.' oneline'
#                             call add(syntaxs, line_syn)
#                         else
#                             let match_col = match_text.val_col
#                             let line_syn = 'syn region FarItem matchgroup=FarSearchVal '.
#                                         \   'start="\%'.line_num.'l\%'.len(line_num_col_text).'c"rs=s+'.
#                                         \   (match_col+len(match_val)).
#                                         \   ',hs=s+'.match_col.' matchgroup=FarReplaceVal end="" oneline'
#                             call add(syntaxs, line_syn)
#                         endif
#                     endif
#                 else
#                     if get(item_ctx, 'broken', 0)
#                         let out = 'B'.out[1:]
#                     elseif item_ctx.replaced
#                         let out = 'R'.out[1:]
#                     elseif item_ctx.excluded
#                         let out = 'X'.out[1:]
#                     endif
#                 endif
#                 call add(content, out)
#             endfor
#         endif
#     endfor

#     return {'content': content, 'syntaxs': syntaxs}
# endfunction "}}}
