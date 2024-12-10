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


def parse_exp(inp):
    if inp == '':
        return None, 1

    idx = 0
    if parse_text(inp, "mul(") != "mul(":
        return None, 1
    idx += 4
    n1 = parse_num(inp[idx:])
    if not n1:
        return None, 1
    idx += len(n1)
    if parse_text(inp[idx:], ",") != ",":
        return None, 1
    idx += 1
    n2 = parse_num(inp[idx:])
    if not n2:
        return None, 1
    idx += len(n2)
    if parse_text(inp[idx:], ")") != ")":
        return None, 1
    idx += 1

    return (int(n1), int(n2)), idx


def parse(inp):
    idx = 0
    length = len(inp)
    res = []
    while idx < length:
        p, n = parse_exp(inp[idx:])
        if p:
            res.append(p)
        idx += n
    return res


def part1(inp):
    # recursive descent parsing?
    # given string and index, parse expectations or abort
    res = parse(inp)
    return sum(x * y for (x, y) in res)


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
part2(part1_example)
