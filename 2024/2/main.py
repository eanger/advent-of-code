#!/usr/bin/env python3

import util
import operator
import itertools


p1_example = """7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"""


def safep(report):
    if report[0] < report[1]:
        sign = operator.lt
    else:
        sign = operator.gt

    def pred(vals):
        diff = abs(vals[1] - vals[0])
        return sign(*vals) and diff >= 1 and diff <= 3

    return all(map(pred, zip(report, report[1:])))


def part1(inp):
    reports = inp.splitlines()
    return len([y for y in filter(safep, map(lambda x: [y for y in map(int, x.split())], reports))])


def part2(inp):
    reports = inp.splitlines()
    candidates = map(lambda x: [y for y in map(int, x.split())], reports)
    res = 0
    for candidate in candidates:
        combs = [candidate]
        combs.extend(itertools.combinations(candidate, len(candidate) - 1))
        if any(filter(safep, combs)):
            res += 1
    return res


# ------------------------------------------------
print(part1(p1_example))
print(part1(util.input_str()))
print(part2(p1_example))
print(part2(util.input_str()))
