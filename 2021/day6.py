#!/usr/bin/env python3

from pprint import pprint

with open('day6.input', 'r') as inp:
    lines = inp.readlines()

init = [int(x) for x in lines[0].split(',')]


def lanternfish(days):
    fishes = [0] * 9
    for i in init:
        fishes[i] += 1

    for _ in range(days):
        # print(fishes)
        new_fishes = fishes[0]
        fishes = fishes[1:] + [new_fishes]
        fishes[6] += new_fishes
    return sum(fishes)

print(lanternfish(80))
print(lanternfish(256))
