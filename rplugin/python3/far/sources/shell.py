"""
File: shell.py
Description: shell command source
Author: Oleg Khalidov <brooth@gmail.com>
License: MIT
"""

from pprint import pprint

from .far_glob import load_ignore_rules, far_glob, GlobError, IgnoreFileError
import logging
import subprocess
import re
import tempfile
import pathlib
import json
from json import JSONDecodeError

logger = logging.getLogger("far")


def search(ctx, args, cmdargs):
    logger.debug("search(%s, %s, %s)", str(ctx), str(args), str(cmdargs))

    final_result = {"warning": ""}

    if not args.get("cmd"):
        return {"error": "no cmd in args"}

    source = ctx["source"]
    pattern = ctx["pattern"]
    regex = ctx["regex"]
    case_sensitive = ctx["case_sensitive"]

    file_mask = ctx["file_mask"]
    submatch_type = args.get("submatch")
    root = ctx["cwd"]

    limit = int(ctx["limit"])
    max_columns = args.get("max_columns")
    ignore_files = args.get("ignore_files")

    rules = file_mask.split(",")

    cmd = []
    for c in args["cmd"]:
        cmd.append(c.format(limit=limit, pattern=pattern, file_mask=file_mask))

    if args.get("expand_cmdargs", "0") != "0":
        cmd += cmdargs

    logger.debug("cmd:" + str(cmd))

    try:
        proc = subprocess.Popen(
            cmd, cwd=ctx["cwd"], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
    except Exception as e:
        return {"error": str(e)}

    logger.debug("type(proc) = " + str(type(proc)))
    logger.debug("type(proc) = " + str(type(proc)))

    range = tuple(ctx["range"])
    result = {}

    if source == "rg" or source == "rgnvim":

        while limit > 0:
            line = proc.stdout.readline()

            try:
                line = line.decode("utf-8").rstrip()
            except UnicodeDecodeError:
                logger.debug(
                    "UnicodeDecodeError: line = line.decode('utf-8').rstrip() failed, line:"
                )
                continue

            if not line:
                if len(result) == 0:
                    err = proc.stderr.readline()
                    if err:
                        err = err.decode("utf-8")
                        logger.debug("error:" + err)
                        return {"error": err}

                if proc.poll() is not None:
                    logger.debug("end of proc. break")
                    break
                continue

            try:
                item = json.loads(line)
            except JSONDecodeError as err:
                logger.debug("json error: ", err)
                continue

            if type(item) != dict or "type" not in item:
                logger.debug(
                    'json error: item is not dict or item has no key "type". item ='
                    + str(item)
                )
                continue

            if item["type"] == "match":
                data = item["data"]
                file_name = data["path"]["text"]
                lnum = data["line_number"]

                try:
                    text = data["lines"]["text"]
                except KeyError:
                    text = data["lines"]["bytes"]
                except:
                    logger.debug(
                        "item['data']['lines'] has neigher key 'test' nor key 'bytes'. item ="
                        + str(item)
                    )
                    continue
                if len(text) > max_columns:
                    logger.debug(
                        "File '{file_name}' line {lnum} is too long, longer than max_column {max_columns}.".format(
                            file_name=file_name, lnum=lnum, max_columns=max_columns
                        )
                    )
                    continue
                text = text.split("\n")[0]
                text = text.rstrip()

                for submatch in data["submatches"]:
                    match = submatch["match"]["text"]
                    cnum = submatch["start"] + 1

                    item_idx = (file_name, lnum, cnum)

                    if "one_file_result" in locals() or "one_file_result" in globals():
                        if item_idx in one_file_result:
                            continue
                        else:
                            one_file_result.append(item_idx)

                    if (range[0] != -1 and range[0] > lnum) or (
                        range[1] != -1 and range[1] < lnum
                    ):
                        continue

                    if not file_name in result:
                        result[file_name] = {"fname": file_name, "items": []}

                    item_ctx = {
                        "lnum": lnum,
                        "cnum": cnum,
                        "text": text,
                        "match": match,
                    }
                    result[file_name]["items"].append(item_ctx)

                    limit -= 1

    else:
        if submatch_type == "first":
            if regex != "0":
                try:
                    if case_sensitive == "0":
                        cpat = re.compile(pattern, re.IGNORECASE)
                    else:
                        cpat = re.compile(pattern)
                except Exception as e:
                    return {"error": "invalid pattern: " + str(e)}

        while limit > 0:
            line = proc.stdout.readline()

            try:
                line = line.decode("utf-8").rstrip()
            except UnicodeDecodeError:
                logger.debug(
                    "UnicodeDecodeError: line = line.decode('utf-8').rstrip() failed, line:"
                )
                continue

            if not line:
                if len(result) == 0:
                    err = proc.stderr.readline()
                    if err:
                        err = err.decode("utf-8")
                        logger.debug("error:" + err)
                        return {"error": err}

                if proc.poll() is not None:
                    logger.debug("end of proc. break")
                    break
                continue

            items = re.split(":", line, 3)
            if len(items) != 4:
                logger.error("broken line:" + line)
                continue

            file_name = items[0]
            lnum = int(items[1])
            cnum = int(items[2])
            text = items[3]

            if (range[0] != -1 and range[0] > lnum) or (
                range[1] != -1 and range[1] < lnum
            ):
                continue

            if len(text) > max_columns:
                logger.debug(
                    "File '{file_name}' line {lnum} is too long, longer than max_column {max_columns}.".format(
                        file_name=file_name, lnum=lnum, max_columns=max_columns
                    )
                )
                continue

            item_idx = (file_name, lnum, cnum)
            if "one_file_result" in locals() or "one_file_result" in globals():
                if item_idx in one_file_result:
                    continue
                else:
                    one_file_result.append(item_idx)

            if not file_name in result:
                file_ctx = {"fname": file_name, "items": []}
                result[file_name] = file_ctx
            file_ctx = result[file_name]

            item_ctx = {}
            item_ctx["text"] = text
            item_ctx["lnum"] = lnum
            item_ctx["cnum"] = cnum
            file_ctx["items"].append(item_ctx)
            limit -= 1

            if submatch_type == "first":
                byte_num = item_ctx["cnum"]
                char_num = len(text.encode("utf-8")[: byte_num - 1].decode("utf-8"))
                move_cnum = char_num + 1

                if regex == "0":
                    while True:
                        next_item_ctx = {}
                        next_item_ctx["text"] = text
                        next_item_ctx["lnum"] = int(lnum)
                        if case_sensitive == "0":
                            next_char_num = text.lower().find(
                                pattern.lower(), move_cnum
                            )
                        else:
                            next_char_num = text.find(pattern, move_cnum)
                        if next_char_num == -1:
                            break
                        move_cnum = next_char_num + 1
                        prefix = text[:next_char_num]
                        next_item_ctx["cnum"] = len(prefix.encode("utf-8")) + 1
                        file_ctx["items"].append(next_item_ctx)
                        limit -= 1
                        if limit <= 0:
                            break
                else:
                    for cp in cpat.finditer(text, move_cnum):
                        next_item_ctx = {}
                        next_item_ctx["text"] = text
                        next_item_ctx["lnum"] = int(lnum)
                        prefix = text[: cp.span()[0]]
                        next_item_ctx["cnum"] = len(prefix.encode("utf-8")) + 1
                        file_ctx["items"].append(next_item_ctx)
                        limit -= 1
                        if limit <= 0:
                            break

    try:
        proc.terminate()
    except Exception as e:
        logger.error("failed to terminate proc: " + str(e))

    if int(ctx["limit"]) - limit >= args.get("items_file_min", 250):
        with tempfile.NamedTemporaryFile(
            mode="w", delete=False, encoding="utf-8"
        ) as fp:
            for file_ctx in result.values():
                json.dump(file_ctx, fp, ensure_ascii=False)
                fp.write("\n")

        logger.debug("items_file:" + fp.name)
        final_result["items_file"] = fp.name
    else:
        final_result["items"] = list(result.values())

    return final_result
