#!/usr/bin/env python3

from copy import deepcopy

with open('day11.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
world = [[int(x) for x in line] for line in lines]
ROWS = len(world)
COLS = len(world[0])


def step(world):
    # 1. increase all energies by one, add any flashers to working list
    # 2. while working list isn't empty:
    #    if elem is in flashed set, continue
    #    otherwise, increment neighbors, add to working list if necessary
    # 3. set all > 9 to 0
    work_list = []
    for j in range(ROWS):
        for i in range(COLS):
            val = world[j][i] + 1
            if val > 9:
                work_list.append((i, j))
            world[j][i] = val

    flashed = set()
    while len(work_list) != 0:
        elem = work_list.pop()
        if elem in flashed:
            continue
        flashed.add(elem)
        (x, y) = elem
        for j in range(y - 1, y + 2):
            if j < 0 or j >= ROWS:
                continue
            for i in range(x - 1, x + 2):
                if i < 0 or i >= COLS:
                    continue
                val = world[j][i] + 1
                if val > 9 and (i,j) not in work_list:
                    work_list.append((i, j))
                world[j][i] = val

    for j in range(ROWS):
        for i in range(COLS):
            if world[j][i] > 9:
                world[j][i] = 0
    return world


total_flashes = 0
world_p1 = deepcopy(world)
for _ in range(100):
    world_p1 = step(world_p1)
    total_flashes += sum([sum([1 for x in row if x == 0]) for row in world_p1])

print(total_flashes)

# Part 2
steps = 0
while True:
    world = step(world)
    steps += 1
    total_flashes = sum([sum([1 for x in row if x == 0]) for row in world])
    if total_flashes == ROWS * COLS:
        break
print(steps)
