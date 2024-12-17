#!/usr/bin/env python3

import util
import operator


part1_example = '2333133121414131402'
part2_example = part1_example


def part1(inp):
    '''
    id = input idx // 2

    12345
    0..111....22222
     ^            ^
     current gap
                  current to replace

    current gap = idx and value
    decrement value until zero, then go to next gap
    replace value = idx and value
    decrement value then go to prior replace val

    termination condition: gap > replace
    '''
    vals = list(map(int, inp))
    idx = 0
    replace_idx = len(vals) - 1
    if len(vals) % 2 == 0:
        replace_idx -= 1

    res = []
    while idx <= replace_idx:
        if idx % 2 == 0:
            res.extend([idx // 2] * vals[idx])
        else:
            for i in range(vals[idx]):
                if vals[replace_idx] == 0:
                    replace_idx -= 2
                if idx > replace_idx:
                    break
                res.append(replace_idx // 2)
                vals[replace_idx] -= 1
        idx += 1

    # checksum
    acc = 0
    for i, v in enumerate(res):
        acc += i * v
    return acc


def part2(inp):
    '''
    similar walk
    if vals[idx] >= vals[replace_idx]: add and decrease vals[idx] by vals[replace_idx]


2333133121414131402

00...111...2...333.44.5555.6666.777.888899
0099.111...2...333.44.5555.6666.777.8888..
0099.1117772...333.44.5555.6666.....8888..
0099.111777244.333....5555.6666.....8888..
00992111777.44.333....5555.6666.....8888..

    {2, 0, not moved}
    {3, -1, not moved}
    {3, 1, not moved}
    {3, -1, not moved}...

    {2, 0, not moved}
    {2, 9, moved}
    {1, 2, moved}...

    convert one list to another until convergence
    convergence when, walking right to left, no more changes can be made
    '''
    class Block():
        def __init__(self, length, ID):
            self.length = length
            self.ID = ID
            self.moved = False
        def __repr__(self):
            return f'({self.length}, {self.ID}, {self.moved})'

    vals = list(map(int, inp))
    blocks = []
    for idx, v in enumerate(vals):
        this_id = -1
        if idx % 2 == 0:
            this_id = idx // 2
        blocks.append(Block(v, this_id))

    max_replace_idx = len(vals) - 1
    if len(vals) % 2 == 0:
        max_replace_idx -= 1

    idx = max_replace_idx
    while idx != 0:
        if blocks[idx].ID != -1 and not blocks[idx].moved:
            # walk from idx backwards to see if it could move anywhere
            for replace_idx in range(idx):
                if blocks[replace_idx].ID != -1:
                    continue
                if blocks[replace_idx].length >= blocks[idx].length:
                    # do move
                    new_b = Block(blocks[idx].length, blocks[idx].ID)
                    blocks[replace_idx].length -= blocks[idx].length
                    blocks[idx].ID = -1
                    blocks = blocks[:replace_idx] + [new_b] + blocks[replace_idx:]
                    break
        idx -= 1

    # checksum
    res = []
    for b in blocks:
        if b.ID == -1:
            res.extend([0] * b.length)
        else:
            res.extend([b.ID] * b.length)
    acc = 0
    for i, v in enumerate(res):
        acc += i * v
    return acc


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str().strip()))
print(part2(part2_example))
print(part2(util.input_str().strip()))
