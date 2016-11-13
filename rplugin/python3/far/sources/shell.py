"""
File: shell.py
Description: shell command source
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

import logging
import subprocess

logger = logging.getLogger('far')


def search(ctx, args):
    logger.debug('search(%s, %s)', str(ctx), str(args))

    if not args.get('cmd'):
        return {'error': 'no cmd in args'}

    limit = int(ctx['limit'])
    cmd = args['cmd'].format(limit=limit,
                             pattern=ctx['pattern'].replace(' ', '\"'),
                             file_mask=ctx['file_mask'],
                             args='')
    logger.debug('cmd:' + str(cmd))

    try:
        proc = subprocess.Popen(cmd, shell=True, cwd=ctx['cwd'],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as e:
        return {'error': str(e)}

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

        idx2 = line.index(':', idx1 + 1)
        idx3 = line.index(':', idx2 + 1)
        item_ctx = {}
        item_ctx['lnum'] = int(line[idx1 + 1:idx2])
        item_ctx['cnum'] = int(line[idx2 + 1:idx3])
        item_ctx['text'] = line[idx3 + 1:]
        file_ctx['items'].append(item_ctx)

    try:
        proc.terminate()
    except Exception as e:
        logger.error('failed to terminate proc: ' + str(e))

    return {'items': list(result.values())}
