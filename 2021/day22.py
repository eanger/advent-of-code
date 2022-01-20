#!/usr/bin/env python3

with open('day22.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
import re
steps = []
for line in lines:
    m = re.match(r"(on|off) x=(.*)\.\.(.*),y=(.*)\.\.(.*),z=(.*)\.\.(.*)", line)
    if m:
        steps.append((m[1],
                      int(m[2]), int(m[3]),
                      int(m[4]), int(m[5]),
                      int(m[6]), int(m[7])))

world = set()
for (direction, xmin, xmax, ymin, ymax, zmin, zmax) in steps[:20]:
    for x in range(xmin, xmax + 1):
        for y in range(ymin, ymax + 1):
            for z in range(zmin, zmax + 1):
                if -50 <= x <= 50 and \
                    -50 <= y <= 50 and \
                    -50 <= z <= 50:
                    if direction == 'on':
                        # add elements to world
                        world.add((x, y, z))
                    else:
                        # remove elements from world
                        world.discard((x, y, z))

print(len(world))
