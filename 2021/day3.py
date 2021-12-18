#!/usr/bin/env python3

with open('day3.input', 'r') as inp:
    lines = inp.readlines()

# Part 1
# There are 12 bits in each number

counts = [0] * 12
for l in lines:
    num = int(l, 2)
    # print(l)
    for i in range(12):
        # print("ITER")
        # print(bin(num))
        # print(num & 1)
        counts[i] = counts[i] + (num & 1)
        num = num >> 1

half = len(lines) / 2
# print(half)
gamma = 0
epsilon = 0
for i, c in enumerate(counts):
    if c > half:
        gamma += 1 << i
    else:
        epsilon += 1 << i

# print([x > half for x in counts])
# print(bin(gamma))
# print(bin(epsilon))
gamma * epsilon

# Part 2

import operator


def count_rating(vals, idx, op):
    # print(vals)
    total_vals = len(vals)
    if total_vals == 1:
        # print(vals[0])
        return vals[0]

    ones = []
    zeroes = []
    for v in vals:
        if (v >> idx) & 1 == 1:  # bit set at idx
            ones.append(v)
        else:
            zeroes.append(v)
    # print(f"ones: {len(ones)} zeroes: {len(zeroes)}")
    if op(len(ones), len(zeroes)):
        return count_rating(ones, idx - 1, op)
    return count_rating(zeroes, idx - 1, op)


numbers = [int(x, 2) for x in lines]
o2 = count_rating(numbers, 11, operator.ge)
co2 = count_rating(numbers, 11, operator.lt)
o2 * co2
