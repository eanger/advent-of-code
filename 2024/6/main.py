#!/usr/bin/env python3

import util
import itertools


part1_example = """....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."""
part2_example = ''


def part1(inp):
    '''
    direction starts up
    visited starts with start location
    while current location is on the map:
        add current to visited
        while next stop  == '#':
            turn
        cur = next stop
    '''
    grid = util.Grid(inp)
    start = grid.find('^')

    directions = itertools.cycle([util.Point(0, -1),
                                  util.Point(1, 0),
                                  util.Point(0, 1),
                                  util.Point(-1, 0)])
    direction = next(directions)
    visited = set()
    current = start
    while grid.get(current):
        visited.add(current)
        while grid.get(current + direction) == '#':
            direction = next(directions)
        current += direction

    return len(visited)


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
