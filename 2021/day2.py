#!/usr/bin/env python3

with open('day2.input', 'r') as inp:
    lines = inp.readlines()

# Part 1
horiz = 0
depth = 0
for l in lines:
    (direction, mag) = l.split()
    if direction == 'forward':
        horiz = horiz + int(mag)
    elif direction == 'down':
        depth = depth + int(mag)
    elif direction == 'up':
        depth = depth - int(mag)
    else:
        print('ERROR: Invalid direction')

horiz * depth

# Part 2

horiz = 0
depth = 0
aim = 0
for l in lines:
    (direction, mag) = l.split()
    if direction == 'forward':
        horiz = horiz + int(mag)
        depth = depth + aim * int(mag)
    elif direction == 'down':
        aim = aim + int(mag)
    elif direction == 'up':
        aim = aim - int(mag)
    else:
        print('ERROR: Invalid direction')

horiz * depth
