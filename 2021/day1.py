#!/usr/bin/env python3

with open('day1.input', 'r') as inp:
    lines = [int(x) for x in inp.readlines()]

# Part 1

prev = lines[0]
count = 0
for l in lines:
    if l > prev:
        count = count + 1
    prev = l

count

# Part 2

prev = lines[:3]
count = 0
for l in lines:
    prev_sum = sum(prev)
    cur_sum = sum(prev[1:] + [l])
    if cur_sum > prev_sum:
        count = count + 1
    prev = prev[1:] + [l]

count
