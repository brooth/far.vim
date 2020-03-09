#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pathlib
import re
from os.path import expanduser

def proc(rules_origin):
    '''
    input  -> output

    tail
    file: xx
    dir: xx/    -> xxx/**/*
        xx/**  -> xxx/**/*
        xx/**/ -> xxx/**/*

    head
    under root: /xx    -> xx
    anywhere:   xx     -> **/xx, **/xx/**/*
    '''
    rules = []
    for rule_origin in rules_origin:
        rule = rule_origin

        if rule[-1] == '/':
            rule += '**/*'
        elif rule[-3:] == '/**':
            rule += '/*'
        elif rule[-4:] == '/**/':
            rule += '*'

        if rule[0] == '/':
            rule = rule[1:]
        else:
            # Match both, files and directories.
            rule = '**/' + rule
            rules.append(rule + '/**/*')

        if rule != '':
            rules.append(rule)
    return rules

def exception_ignore(ignore_rules_origin):
    ignore_rules = []
    exception_ignore_rules = []
    for rule in ignore_rules_origin:
        if rule[0] == '!':
            exception_ignore_rules.append(rule[1:])
        else:
            ignore_rules.append(rule)
    return ignore_rules, exception_ignore_rules

class GlobError(ValueError):
    pass

def glob_rules(root, rules):
    root = pathlib.Path(root).expanduser()
    try:
        files = {f for rule in rules for f in root.glob(rule) if pathlib.Path.is_file(f)}
    except ValueError as e:
        raise GlobError(e)
    return files

class IgnoreFileError(ValueError):
    pass

def load_ignore_rules(file_path):
    ignore_rules = []
    try:
        with open(expanduser(file_path), 'r') as f:
            for line in f:
                line = line.strip()
                if line == '' or re.search(r'^\s*#', line):
                    continue
                ignore_rules.append(line)
    except FileNotFoundError as e:
        raise IgnoreFileError(e)

    return ignore_rules


def far_glob(root, rules, ignore_rules):
    '''
    root: string
    rules, ignore_rules: list

    root can contain '~'
    rules and ignore_rules:
        xx, yy, is path expression, can contain '/'
        head:
            /xx              directly udner the 'root' dir
            xx               recursively udner the 'root' dir
        tail
            xx               file
            xx/              dir, this function returns all files recursively under the dir
        special
            [[xx]/]**        all dirs recursively under the dir [[xx]/], include [[xx]/] itself,
                             this function returns the same result as input `[[xx]/]`
            [[xx]/]**/yy     yy recursively under [[xx]/]
            *                any >=0 chars except the path separator '/'
            ?                any one chars except the path separator '/'
        only for ignore_rules:
            xx               ignore-rule, to ignores xx
            !xx              exception-rule, to never ignore xx, overrides all ignore-rules

        e.g.
            / or * or **     any file under the 'root' dir
            *.sh             any file with .sh extenstion under the 'root' dir
            *.*              any file with '.' in name under the 'root' dir, including '.xx','xx.','xx.xx'
            /*.sh            any *.sh file under the 'root' dir
            /xxdir/          any file under <root>/xxdir/
    '''

    ignore_rules, exception_ignore_rules = exception_ignore(ignore_rules)

    rules = proc(rules)
    ignore_rules = proc(ignore_rules)
    exception_ignore_rules = proc(exception_ignore_rules)

    files = glob_rules(root, rules)
    ignore_files = glob_rules(root, ignore_rules)
    exception_ignore_files = glob_rules(root, exception_ignore_rules)

    files = [
        str(f.relative_to(root))
        for f in files
        if not (f in ignore_files and f not in exception_ignore_files)
    ]

    return files
