"""
File: shell.py
Description: shell command source
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

import logging
import subprocess
import re

logger = logging.getLogger('far')


def search(ctx, args, cmdargs):
    logger.debug('search(%s, %s, %s)', str(ctx), str(args), str(cmdargs))

    if not args.get('cmd'):
        return {'error': 'no cmd in args'}

    pattern = ctx['pattern']

    fix_cnum = args.get('fix_cnum')
    fix_cnum_next = fix_cnum == 'next'
    fix_cnum_all = fix_cnum == 'all'
    if fix_cnum:
        cpat = re.compile(pattern)

    limit = int(ctx['limit'])
    cmd = args['cmd'].format(limit=limit,
                             pattern=pattern.replace(' ', '\"'),
                             file_mask=ctx['file_mask'],
                             args=' '.join(cmdargs))
    logger.debug('cmd:' + str(cmd))

    try:
        proc = subprocess.Popen(cmd, shell=True, cwd=ctx['cwd'],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as e:
        return {'error': str(e)}

    err = proc.stderr.readline()
    if err:
        err = err.decode('utf-8')
        logger.debug('error:' + err)
        return {'error': err}

    result = {}
    while limit > 0:
        line = proc.stdout.readline()
        line = line.decode('utf-8').rstrip()

        if not line:
            if proc.poll() is not None:
                logger.debug('end of proc. break')
                break
            continue

        limit -= 1
        logger.debug('line:' + line)
        idx1 = line.find(':')
        if idx1 == -1:
            return {'error': 'broken outout'}

        fname = line[:idx1]

        file_ctx = result.get(fname)
        if not file_ctx:
            file_ctx = {
                'fname': fname,
                'items': []
            }
            result[fname] = file_ctx

        item_ctx = {}
        idx2 = line.index(':', idx1 + 1)
        item_ctx['lnum'] = int(line[idx1 + 1:idx2])

        if not fix_cnum_all:
            idx3 = line.index(':', idx2 + 1)
            item_ctx['cnum'] = int(line[idx2 + 1:idx3])
            item_ctx['text'] = line[idx3 + 1:]
            file_ctx['items'].append(item_ctx)
            nonlocal fix_cnum_idx
            fix_cnum_idx = item_ctx['cnum'] + 1
        else:
            fix_cnum_idx = 0

        if fix_cnum_next:
            for cp in cpat.finditer(item_ctx['text'], fix_cnum_idx):
                next_item_ctx = {}
                next_item_ctx['lnum'] = item_ctx['lnum']
                next_item_ctx['cnum'] = cp.span()[0] + 1
                next_item_ctx['text'] = item_ctx['text']
                file_ctx['items'].append(next_item_ctx)

    try:
        proc.terminate()
    except Exception as e:
        logger.error('failed to terminate proc: ' + str(e))

    return {'items': list(result.values())}
