#!/usr/bin/env python3

example = """3   4
4   3
2   5
1   3
3   9
3   3"""

example_result = 11

def part1(inp):
    lines = inp.splitlines()
    left = []
    right = []
    for line in lines:
        b = [int(a) for a in line.split()]
        left.append(b[0])
        right.append(b[1])

    left = sorted(left)
    right = sorted(right)

    res = 0
    for x, y in zip(left, right):
        res += abs(x-y)
    return res

assert(part1(example) == example_result)

with open('input.day1', 'r') as f:
    inp = f.read()
    res = part1(inp)
    print(res)


example2_result = 31

def part2(inp):
    lines = inp.splitlines()
    left = []
    right = []
    for line in lines:
        b = [int(a) for a in line.split()]
        left.append(b[0])
        right.append(b[1])

    occurs = {}
    for v in right:
        try:
            occurs[v] += 1
        except:
            occurs[v] = 1

    res = 0
    for v in left:
        if v in occurs:
            res += v*occurs[v]
    return res

assert(part2(example) == example2_result)

with open('input.day1', 'r') as f:
    inp = f.read()
    res = part2(inp)
    print(res)
