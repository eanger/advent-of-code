#!/usr/bin/env python3

import util
import itertools


part1_example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"


def parse_text(inp, text):
    if inp.startswith(text):
        return text
    return None


def parse_num(inp):
    res = [x for x in itertools.takewhile(str.isdigit, inp[:3])]
    return ''.join(res) if res != [] else None


def parse(inp, res):
    if inp == '':
        return res

    idx = 0
    if parse_text(inp, "mul(") != "mul(":
        parse(inp[1:], res)
    idx += 4
    n1 = parse_num(inp[idx:])
    if not n1:
        parse(inp[1:], res)
    idx += len(n1)
    if parse_text(inp[idx:], ",") != ",":
        parse(inp[1:], res)
    idx += 1
    n2 = parse_num(inp[idx:])
    if not n2:
        parse(inp[1:], res)
    idx += len(n2)
    if parse_text(inp[idx:], ")") != ")":
        parse(inp[1:], res)
    idx += 1

    res.append((int(n1), int(n2)))
    parse(inp[idx:], res)


print(parse("mul(1,4)", []))


def part1(inp):
    # recursive descent parsing?
    # given string and index, parse expectations or abort

    #
    pass

def part2(inp):
    pass


# ------------------------------------------------
part1(part1_example)
part2(part1_example)
