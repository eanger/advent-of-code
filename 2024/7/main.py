#!/usr/bin/env python3

import util
import itertools
import operator


part1_example = """190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""

part2_example = part1_example


def parse(line):
    parts = line.split(': ')
    value = int(parts[0])
    numbers = [int(x) for x in parts[1].split()]
    return value, numbers


def part1(inp):
    """
    190: 10 19
    10 [+,*] 19 -> [[+*]]
    3267: 81 40 27
    81 [+,*] 40 [+,*] 27 -> [[+*], [+*]
    """
    lines = inp.splitlines()
    equations = [parse(x) for x in lines]
    res = 0
    for value, numbers in equations:
        all_ops = itertools.product([operator.add, operator.mul],
                                    repeat=len(numbers) -1)
        for this_op in list(all_ops):
            r = numbers[0]
            for n, o in zip(numbers[1:], this_op):
                r = o(r, n)
            if r == value:
                res += r
                break
    return res


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
