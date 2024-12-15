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
part2_example = part1_example


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

    return visited


def part2(inp):
    """
    record direction traveled at each visited site
    what about turns?
    try each visited site:
    walk directions and record them with their traveled direction
    if you visit one you've visited before, abort and flag this as a valid location
    """
    original_grid = util.Grid(inp)
    start = original_grid.find('^')
    spots = part1(inp)
    count = 0
    for spot in spots:
        new_grid = util.Grid(inp)
        new_grid.set('#', spot)

        directions = itertools.cycle([util.Point(0, -1),
                                      util.Point(1, 0),
                                      util.Point(0, 1),
                                      util.Point(-1, 0)])
        direction = next(directions)
        visited = set()
        current = start
        while new_grid.get(current):
            if (current, direction) in visited:
                count += 1
                break
            visited.add((current, direction))
            while new_grid.get(current + direction) == '#':
                direction = next(directions)
            current += direction
    return count


# ------------------------------------------------
print(len(part1(part1_example)))
print(len(part1(util.input_str())))
print(part2(part2_example))
print(part2(util.input_str()))
