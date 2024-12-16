#!/usr/bin/env python3

import util
import operator


part1_example = '2333133121414131402'
part2_example = ''


def part1(inp):
    '''
    id = input idx // 2

    12345
    0..111....22222
     ^            ^
     current gap
                  current to replace

    current gap = idx and value
    decrement value until zero, then go to next gap
    replace value = idx and value
    decrement value then go to prior replace val

    termination condition: gap > replace
    '''
    vals = list(map(int, inp))
    idx = 0
    replace_idx = len(vals) - 1
    if len(vals) % 2 == 0:
        replace_idx -= 1

    res = []
    while idx <= replace_idx:
        if idx % 2 == 0:
            res.extend([idx // 2] * vals[idx])
        else:
            for i in range(vals[idx]):
                if vals[replace_idx] == 0:
                    replace_idx -= 2
                if idx > replace_idx:
                    break
                res.append(replace_idx // 2)
                vals[replace_idx] -= 1
        idx += 1

    # checksum
    acc = 0
    for i, v in enumerate(res):
        acc += i * v
    return acc


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str().strip()))
print(part2(part2_example))
