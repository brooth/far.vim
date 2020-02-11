"""
File: shell.py
Description: shell command source
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

from pprint import pprint

from .far_glob import load_ignore_rules,far_glob
import logging
import subprocess
import re
import tempfile
import pathlib
import json

logger = logging.getLogger('far')


def search(ctx, args, cmdargs):
    logger.debug('search(%s, %s, %s)', str(ctx), str(args), str(cmdargs))


    with open('/Users/mac/far.vim.py.log', 'a') as f:
        pprint(args, f)
        pprint(cmdargs, f)
        pprint(ctx,f)


    if not args.get('cmd'):
        return {'error': 'no cmd in args'}

    source = args['cmd'][0]
    pattern = ctx['pattern']
    regex = ctx['regex']
    case_sensitive = ctx['case_sensitive']
    limit = int(ctx['limit'])
    file_mask = ctx['file_mask']
    fix_cnum = args.get('fix_cnum')
    root = ctx['cwd']

    if source != 'vimgrep':
    # if source == 'rg' or source == 'rgnvim' or source == 'ack' or source == 'acknvim':
        rules = file_mask.split(',')
        ignore_rules = load_ignore_rules('/Users/mac/farignore')
        files = far_glob(root, rules, ignore_rules)
        # files = [str(f.relative_to(root)) for f in pathlib.Path(root).glob(file_mask) if pathlib.Path.is_file(f)]

        if len(files):
            files = [" "] + files
        with open('/Users/mac/far.vim.py.log', 'a') as f:
            print('files', file=f)
            pprint(files, f)
        cmd = []
        for c in args['cmd']:
            if c == '{file_mask}':
                cmd += files
            else:
                cmd.append(c.format(limit=limit,
                                pattern=pattern))

    else:
        cmd = []
        for c in args['cmd']:
            cmd.append(c.format(limit=limit,
                            pattern=pattern,
                            file_mask=file_mask))

    if args.get('expand_cmdargs', '0') != '0':
        cmd += cmdargs

    with open('/Users/mac/far.vim.py.log', 'a') as f:
        pprint(' '.join(cmd), f)

    logger.debug('cmd:' + str(cmd))
    try:
        proc = subprocess.Popen(cmd, cwd=ctx['cwd'],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as e:
        return {'error': str(e)}


    if source == 'rg' or source == 'rgnvim' :
        cmd_only_match = cmd + ['-o']
        try:
            proc_only_match = subprocess.Popen(cmd_only_match, cwd=ctx['cwd'],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except Exception as e:
            return {'error': str(e)}


        with open('/Users/mac/far.vim.py.log','a') as f:
            pprint(cmd, f)
        with open('/Users/mac/far.vim.py.log','a') as f:
            pprint(cmd_only_match, f)

        split_amount = 2 if fix_cnum == 'all' else 3
        range = tuple(ctx['range'])
        result_dict = {}

        while limit > 0:
            line = proc.stdout.readline()
            line = line.decode('utf-8').rstrip()

            if not line:
                if len(result_dict) == 0:
                    err = proc.stderr.readline()
                    if err:
                        err = err.decode('utf-8')
                        logger.debug('error:' + err)
                        return {'error': err}

                if proc.poll() is not None:
                    logger.debug('end of proc. break')
                    break
                continue

            # with open('/Users/mac/far.vim.py.log','a') as f:
            #     pprint(line, f)
            items = re.split(':', line, split_amount)
            # with open('/Users/mac/far.vim.py.log','a') as f:
            #     pprint(items, f)

            if len(items) != split_amount + 1:
                logger.error('broken line:' + line)
                continue
                # return {'error': 'broken output: '+line }

            file_name = items[0]
            lnum = int(items[1])
            text = items[split_amount]
            cnum = int(items[2])
            item = (file_name,lnum,cnum)

            if (range[0] != -1 and range[0] > lnum) or (range[1] != -1 and range[1] < lnum):
                continue

            if not item in result_dict:
                result_dict[item] = {}
            result_dict[item]['text'] = text
            limit -= 1

        with open('/Users/mac/far.vim.py.log', 'a') as f:
            print('result_dict1', file=f)
            pprint(result_dict, f)

        limit = int(ctx['limit'])
        while limit > 0:
            line = proc_only_match.stdout.readline()
            line = line.decode('utf-8').rstrip()

            with open('/Users/mac/far.vim.py.log', 'a') as f:
                print('proc_only_match line', line, file=f)
                pprint(line, f)

            if not line:
                if len(result_dict) == 0:
                    err = proc.stderr.readline()
                    if err:
                        err = err.decode('utf-8')
                        logger.debug('error:' + err)
                        return {'error': err}

                if proc.poll() is not None:
                    logger.debug('end of proc. break')
                    break
                continue

            items = re.split(':', line, split_amount)
            if len(items) != split_amount + 1:
                logger.error('broken line:' + line)
                continue
                # return {'error': 'broken output'}

            file_name = items[0]
            lnum = int(items[1])
            match = items[split_amount]
            cnum = int(items[2])
            item = (file_name,lnum,cnum)


            if (range[0] != -1 and range[0] > lnum) or (range[1] != -1 and range[1] < lnum):
                continue

            if not item in result_dict:
                result_dict[item] = {}
            result_dict[item]['match'] = match
            limit -= 1

        # with open('/Users/mac/far.vim.py.log', 'a') as f:
        #     print('result_dict2', file=f)
        #     pprint(result_dict, f)

        result = {}
        for key, value in result_dict.items():
            file_name, lnum, cnum = key
            if not ('match' in value and 'text' in value):
                continue
            match = value['match']
            text = value['text']

            if not file_name in result:
                result[file_name] = {
                    'fname': file_name,
                    'items': []
                }

            file_ctx = result.get(items[0])

            item_ctx = {
                'lnum': lnum,
                'cnum': cnum,
                'text': text,
                'match': match
                }
            result[file_name]['items'].append(item_ctx)

    else:
        if fix_cnum == 'first-in-line':
            if regex != '0':
                try:
                    if case_sensitive == '0':
                        cpat = re.compile(pattern, re.IGNORECASE)
                    else:
                        cpat = re.compile(pattern)
                except Exception as e:
                    return {'error': 'invalid pattern: ' + str(e) }

        split_amount = 2 if fix_cnum == 'all' else 3
        range = tuple(ctx['range'])


        result = {}
        while limit > 0:
            line = proc.stdout.readline()
            line = line.decode('utf-8').rstrip()

            if not line:
                if len(result) == 0:
                    err = proc.stderr.readline()
                    if err:
                        err = err.decode('utf-8')
                        logger.debug('error:' + err)
                        return {'error': err}

                if proc.poll() is not None:
                    logger.debug('end of proc. break')
                    break
                continue

            items = re.split(':', line, split_amount)
            if len(items) != split_amount + 1:
                logger.error('broken line:' + line)
                # return {'error': 'broken output'}
                continue

            lnum = int(items[1])
            if (range[0] != -1 and range[0] > lnum) or (range[1] != -1 and range[1] < lnum):
                continue

            file_ctx = result.get(items[0])
            if not file_ctx:
                file_ctx = {
                    'fname': items[0],
                    'items': []
                }
                result[items[0]] = file_ctx

            text = items[split_amount]

            fix_cnum_idx = 0
            if split_amount == 3:
                item_ctx = {}
                item_ctx['text'] = text
                item_ctx['lnum'] = lnum
                item_ctx['cnum'] = int(items[2])
                file_ctx['items'].append(item_ctx)
                limit -= 1
                if fix_cnum == 'first-in-line':
                    byte_num = item_ctx['cnum']
                    char_num = len( text.encode('utf-8')[:byte_num].decode('utf-8') )
                    fix_cnum_idx = char_num

            if fix_cnum == 'first-in-line':
                if regex == '0':
                    while True:
                        next_item_ctx = {}
                        next_item_ctx['text'] = text
                        next_item_ctx['lnum'] = int(lnum)
                        if case_sensitive == '0':
                            next_char_num = text.lower().find(pattern.lower(), fix_cnum_idx)
                        else:
                            next_char_num = text.find(pattern, fix_cnum_idx)
                        if next_char_num == -1:
                            break
                        fix_cnum_idx = next_char_num + 1
                        prefix = text[:next_char_num]
                        next_item_ctx['cnum'] = len(prefix.encode('utf-8')) + 1
                        file_ctx['items'].append(next_item_ctx)
                        limit -= 1
                        if limit == 0:
                            break
                else:
                    for cp in cpat.finditer(text, fix_cnum_idx):
                        next_item_ctx = {}
                        next_item_ctx['text'] = text
                        next_item_ctx['lnum'] = int(lnum)
                        prefix = text[:cp.span()[0]]
                        next_item_ctx['cnum'] = len(prefix.encode('utf-8')) + 1
                        file_ctx['items'].append(next_item_ctx)
                        limit -= 1
                        if limit == 0:
                            break

        # with open('/Users/mac/far.vim.py.log','a') as f:
        #     print(cmd, line, items, text, file=f)

    try:
        proc.terminate()
    except Exception as e:
        logger.error('failed to terminate proc: ' + str(e))

    with open('/Users/mac/far.vim.py.log', 'a') as f:
        pprint(result, f)


    if int(ctx['limit']) - limit >= args.get('items_file_min', 250):
        with tempfile.NamedTemporaryFile(mode='w', delete=False, encoding='utf-8') as fp:
            for file_ctx in result.values():
                json.dump(file_ctx, fp, ensure_ascii=False)
                fp.write('\n')

        logger.debug('items_file:' + fp.name)
        return {'items_file': fp.name}
    else:
        return {'items': list(result.values())}
