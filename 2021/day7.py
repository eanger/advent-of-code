#!/usr/bin/env python3

from pprint import pprint

with open('day7.input', 'r') as inp:
    line = inp.read().strip()

positions = [int(x) for x in line.split(',')]

# Part 1
# from min to max, sub each number by x, find min


def fuel_p1(n):
    return sum([abs(x - n) for x in positions])


fuel_options = [(x, fuel_p1(x)) for x in range(min(positions), max(positions) + 1)]
part1 = min(fuel_options, key=lambda x: x[1])[1]
print(part1)


def fuel_p2(n):
    # x -> n: (abs(x - n)*(x + n))/2
    def fuel(n, x):
        diff = abs(x - n) + 1
        return int((diff * (diff - 1)) / 2)
    a = [fuel(n, x) for x in positions]
    return sum([fuel(n, x) for x in positions])


fuel_options = [(x, fuel_p2(x)) for x in range(min(positions), max(positions) + 1)]
part2 = min(fuel_options, key=lambda x: x[1])[1]
print(part2)
