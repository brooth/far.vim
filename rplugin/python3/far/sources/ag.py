"""
File: ag.py
Description: Ag (silver searcher) source for far.vim
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

import logging
import subprocess

logger = logging.getLogger('far')


def search(ctx):
    logger.debug('search(%s)', str(ctx))

    cmd = 'ag --nogroup --column --nocolor "' + \
        ctx['pattern'].replace(' ', '\"') + '" ' + ctx['file_mask']
    logger.debug('ag cmd:' + str(cmd))

    proc = subprocess.Popen(cmd, shell=True, cwd=ctx['cwd'],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for line in iter(proc.stderr.readline, b''):
        line = line.decode('utf-8').rstrip()
        logger.error('ag error:' + line)
        return {'error': line}

    result = {}
    for line in iter(proc.stdout.readline, b''):
        if not line:
            continue

        line = line.decode('utf-8').rstrip()
        logger.debug('ag line:' + line)

        idx1 = line.index(':')
        fname = line[:idx1]

        file_ctx = result.get(fname)
        if not file_ctx:
            file_ctx = {
                'fname': fname,
                'items': []
            }
            result[fname] = file_ctx

        idx2 = line.index(':', idx1+1)
        idx3 = line.index(':', idx2+1)
        item_ctx = {}
        item_ctx['lnum'] = int(line[idx1+1:idx2])
        item_ctx['cnum'] = int(line[idx2+1:idx3])
        item_ctx['text'] = line[idx3+1:]
        file_ctx['items'].append(item_ctx)

    return {'items': list(result.values())}


def test(pattern='number'):
    import sys
    import json

    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

    far_ctx = json.loads('{"pattern": "' + pattern + '", "file_mask": "**/*.py", \
                         "replace_with": "num", "cwd": "/home/brooth/Projects/far.vim"}')
    res = search(far_ctx)
    logger.debug('search res:' + str(res))
    return res

