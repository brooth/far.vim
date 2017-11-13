"""
File: shell.py
Description: shell command source
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

import logging
import subprocess
import re
import tempfile
import json

logger = logging.getLogger('far')


def search(ctx, args, cmdargs):
    logger.debug('search(%s, %s, %s)', str(ctx), str(args), str(cmdargs))

    if not args.get('cmd'):
        return {'error': 'no cmd in args'}

    pattern = ctx['pattern']
    limit = int(ctx['limit'])
    file_mask = ctx['file_mask']
    fix_cnum = args.get('fix_cnum')
    if fix_cnum:
        try:
            cpat = re.compile(pattern)
        except Exception as e:
            return {'error': 'invalid pattern: ' + str(e) }

    cmd = []
    for c in args['cmd']:
        cmd.append(c.format(limit=limit,
                        pattern=pattern,
                        file_mask=file_mask))

    if args.get('expand_cmdargs', '0') != '0':
        cmd += cmdargs

    logger.debug('cmd:' + str(cmd))
    try:
        proc = subprocess.Popen(cmd, cwd=ctx['cwd'],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as e:
        return {'error': str(e)}

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
            return {'error': 'broken output'}

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
            if fix_cnum:
                fix_cnum_idx = item_ctx['cnum'] + 1

        if fix_cnum:
            for cp in cpat.finditer(text, fix_cnum_idx):
                next_item_ctx = {}
                next_item_ctx['text'] = text
                next_item_ctx['lnum'] = int(lnum)
                next_item_ctx['cnum'] = cp.span()[0] + 1
                file_ctx['items'].append(next_item_ctx)
                limit -= 1
                if limit == 0:
                    break

    try:
        proc.terminate()
    except Exception as e:
        logger.error('failed to terminate proc: ' + str(e))

    if int(ctx['limit']) - limit >= args.get('items_file_min', 250):
        with tempfile.NamedTemporaryFile(mode='w', delete=False) as fp:
            for file_ctx in result.values():
                json.dump(file_ctx, fp, ensure_ascii=False)
                fp.write('\n')

        logger.debug('items_file:' + fp.name)
        return {'items_file': fp.name}
    else:
        return {'items': list(result.values())}
