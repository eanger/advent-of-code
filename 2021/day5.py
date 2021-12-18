#!/usr/bin/env python3

from pprint import pprint
import re

with open('day5.input', 'r') as inp:
    lines = inp.readlines()

# Part 1
# x1 = x2 or y1 = y2

allsegs = []
MAXDIM = 1000
for line in lines:
    mtch = re.match(r"(\d+),(\d+) -> (\d+),(\d+)", line)
    allsegs.append([int(x) for x in mtch.groups()])


def part1(segs):
    world = [[0 for _ in range(MAXDIM)] for _ in range(MAXDIM)]

    for seg in segs:
        if seg[0] == seg[2]:
            for y in range(seg[1], seg[3] + 1) if seg[1] < seg[3] \
                else range(seg[3], seg[1] + 1):
                world[y][seg[0]] += 1
        else:
            for x in range(seg[0], seg[2] + 1) if seg[0] < seg[2] \
                else range(seg[2], seg[0] + 1):
                world[seg[1]][x] += 1

    count = 0
    for y in world:
        for x in y:
            if x > 1:
                count += 1
    return count


subset = [x for x in allsegs if x[0] == x[2] or x[1] == x[3]]
p1 = part1(subset)
print(p1)

# Part 2

def part2(segs):
    def gen_n(num):
        while True:
            yield num


    world = [[0 for _ in range(MAXDIM)] for _ in range(MAXDIM)]
    for seg in segs:
        if seg[0] < seg[2]:
            r1 = range(seg[0], seg[2] + 1)
        elif seg[2] < seg[0]:
            r1 = range(seg[0], seg[2] - 1, -1)
        else:
            r1 = gen_n(seg[0])
        if seg[1] < seg[3]:
            r2 = range(seg[1], seg[3] + 1)
        elif seg[3] < seg[1]:
            r2 = range(seg[1], seg[3] - 1, -1)
        else:
            r2 = gen_n(seg[1])
        for i, j in zip(r1, r2):
            # print(f"{i},{j}")
            world[j][i] += 1

    count = 0
    for y in world:
        for x in y:
            if x > 1:
                count += 1

    return count


p2 = part2(allsegs)
print(p2)
