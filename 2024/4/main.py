#!/usr/bin/env python3

import util


part1_example = """MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"""

part2_example = ''


class World():
    def __init__(self, inp):
        self._grid = [x for x in inp.splitlines()]
        self.length = len(self._grid)
        self.width = len(self._grid[0])

    def get(self, x, y):
        if x < 0 or y < 0:
            return None
        if x >= self.width or y >= self.length:
            return None
        return self._grid[y][x]


def num_xmas(world, x, y):
    res = 0
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            if world.get(x, y) == 'X' and \
               world.get(x + dx, y + dy) == 'M' and \
               world.get(x + 2 * dx, y + 2 * dy) == 'A' and \
               world.get(x + 3 * dx, y + 3 * dy) == 'S':
                res += 1
    return res


def part1(inp):
    # walk through each location
    # if it starts with X, walk in each cardinal direction until the edge or until the string doesn't match
    world = World(inp)
    res = 0
    for y in range(world.length):
        for x in range(world.width):
            res += num_xmas(world, x, y)
    return res


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
