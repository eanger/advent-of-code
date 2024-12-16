#!/usr/bin/env python3

import util
import collections
import itertools


part1_example = """............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"""
part2_example = part1_example


def part1(inp, anodes):
    '''
    make lists of each antenna per frequency
    for each pair in each list:
        calculate their antinodes
        if valid, add to result set
    '''
    grid = util.Grid(inp)
    all_antennas = collections.defaultdict(list)
    for y in range(grid.length):
        for x in range(grid.width):
            val = grid.get(x, y)
            if val != '.':
                all_antennas[val].append(util.Point(x, y))
    res = set()
    for antennas in all_antennas.values():
        for a, b in itertools.combinations(antennas, 2):
            for anode in anodes(grid, a, b):
                res.add(anode)
    return len(res)


def anodes_p1(grid, a, b):
    anode_1 = a + (a - b)
    anode_2 = b + (b - a)
    res = []
    if grid.get(anode_1) != None:
        res.append(anode_1)
    if grid.get(anode_2) != None:
        res.append(anode_2)
    return res


def anodes_p2(grid, a, b):
    '''
    keep adding until out of bounds
    include the points themselves
    '''
    d1 = a - b
    d2 = b - a
    res = []
    cur = a
    while grid.get(cur) != None:
        res.append(cur)
        cur += d1
    cur = b
    while grid.get(cur) != None:
        res.append(cur)
        cur += d2
    return res


# ------------------------------------------------
print(part1(part1_example, anodes_p1))
print(part1(util.input_str(), anodes_p1))
print(part1(part2_example, anodes_p2))
print(part1(util.input_str(), anodes_p2))
