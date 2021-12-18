#!/usr/bin/env python3

with open('day13.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
split = lines.index('')


def parse_coord(inp):
    x, y = inp.split(',')
    return (int(x), int(y))


def parse_fold(inp):
    _, _, command = inp.split(' ')
    direction, magnitude = command.split('=')
    return (direction, int(magnitude))


coords = {parse_coord(x) for x in lines[:split]}
folds = [parse_fold(x) for x in lines[split + 1:]]


def do_fold(fold, coords):
    direction, magnitude = fold
    result = set()
    for x, y in coords:
        if direction == 'x' and x > magnitude:  # fold LEFT
            x = magnitude - (x - magnitude)
        elif direction == 'y' and y > magnitude:  # fold UP
            y = magnitude - (y - magnitude)
        result.add((x, y))
    return result


p1_coords = do_fold(folds[0], coords)
print(len(p1_coords))

# Part 2
for fold in folds:
    coords = do_fold(fold, coords)

ymax = max(coords, key=lambda x: x[1])[1]
print(ymax)
xmax = max(coords, key=lambda x: x[0])[0]
print(xmax)
for y in range(ymax + 1):
    for x in range(xmax + 1):
        icon = ' '
        if (x, y) in coords:
            icon = '#'
        print(icon, sep='', end='')
    print()
