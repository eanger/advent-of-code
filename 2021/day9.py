#!/usr/bin/env python3

from pprint import pprint
from operator import mul
from functools import reduce

with open('day9.input', 'r') as inp:
    lines = inp.readlines()

# Part 1
# for each position, consider all neighbors. if its lowest, add it to low points.
# any position < 0 or > SIZE(x or y) has value 10
world = [[int(x) for x in line.strip()] for line in lines] # list of lists

low_points = []
for y, row in enumerate(world):
    for x, val in enumerate(row):
        left = world[y][x - 1] if x - 1 >= 0 else 9
        right = world[y][x + 1] if x + 1 < len(row) else 9
        up = world[y - 1][x] if y - 1 >= 0 else 9
        down = world[y + 1][x] if y + 1 < len(world) else 9
        if all(val < x for x in [left, right, up, down]):
            low_points.append((x, y))

# print(low_points)
print(sum(world[y][x] for (x,y) in low_points) + len(low_points))

# Part 2
# I can get the locations of all low points
# flood fill?
# recursive search to find all locations emanating from a low point
# ie, continue left,right,up,down until you hit 9 or out of bounds


def basin_size(x, y, visited):
    if (x, y) in visited:
        return 0, visited
    v = visited | set([(x, y)])
    if x < 0 or y < 0 or x >= len(world[0]) or y >= len(world):
        return 0, v
    if world[y][x] == 9:
        return 0, v
    left = basin_size(x - 1, y, v)
    right = basin_size(x + 1, y, v | left[1])
    up = basin_size(x, y - 1, v | right[1])
    down = basin_size(x, y + 1, v | up[1])
    return 1 + left[0] + right[0] + up[0] + down[0], down[1]


basin_sizes = []
for low_point in low_points:
    basin_sizes.append(basin_size(*low_point, set())[0])
print(reduce(mul, sorted(basin_sizes, reverse=True)[:3], 1))
