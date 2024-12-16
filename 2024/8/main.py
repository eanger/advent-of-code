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
part2_example = ''


def part1(inp):
    '''
    make lists of each antenna per frequency
    for each pair in each list:
        calculate their antinodes
        if valid, add to result set

  012345678901
0 ......#....#
1 ...#....0...
2 ....#0....#.
3 ..#....0....
4 ....0....#..
5 .#....A.....
6 ...#........
7 #......#....
8 ........A...
9 .........A..
0 ..........#.
1 ..........#.


    min_x - dx, min_y - dy
    max_x + dx, max_y + dy
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


def anodes(grid, a, b):
    anode_1 = a + (a - b)
    anode_2 = b + (b - a)
    res = []
    if grid.get(anode_1) != None:
        res.append(anode_1)
    if grid.get(anode_2) != None:
        res.append(anode_2)
    return res


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
