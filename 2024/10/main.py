#!/usr/bin/env python3

import util


part1_example = """89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""
part2_example = part1_example


def part1(inp):
    '''
    for each trail head (value 0):
    dfs search in each cardinal direction
    counting steps
    return length if location value is 9
    otherwise return none/0

    dfs:
    score = 0
    if our val is 9 return length
    return dfs(left, length +1) + dfs(right, length +1) + ...
    '''
    grid = util.Grid(inp, int)

    def dfs(loc, length, prior):
        val = grid.get(loc)
        if val is None:
            return set()
        if val != prior + 1:
            return set()
        if val == 9:
            return set((loc,))

        length += 1
        return dfs(loc + util.Point(-1, 0), length, val) | \
            dfs(loc + util.Point(1, 0), length, val) | \
            dfs(loc + util.Point(0, -1), length, val) | \
            dfs(loc + util.Point(0, 1), length, val)

    trailheads = grid.find_all(0)
    res = [dfs(t, 0, -1) for t in trailheads]
    return sum([len(x) for x in res])


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
