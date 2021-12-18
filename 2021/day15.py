#!/usr/bin/env python3

with open('day15.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
# pathfinding with djikstra's algo
import math

WIDTH = len(lines[0])
lines = ''.join(lines)


class Node:
    def __init__(self, grid, idx):
        self.visitedp = False
        self.distance = math.inf

        y, x = divmod(idx, WIDTH * 5)
        self.idx = idx

        grid_idx = x % WIDTH + (y % WIDTH) * WIDTH
        calc_cost = int(grid[grid_idx]) + x // WIDTH + y // WIDTH
        self.cost = calc_cost % 10 + calc_cost // 10
        # self.idx = tile_x + i * WIDTH + (tile_y * WIDTH * 5) + (j * WIDTH * WIDTH * 5)
        self.neighbors = [] # list of grid idxs
        if x > 0:
            self.neighbors.append(idx - 1)
        if x < (WIDTH * 5) - 1:
            self.neighbors.append(idx + 1)
        if y > 0:
            self.neighbors.append(idx - (WIDTH * 5))
        if y < (WIDTH * 5) - 1:
            self.neighbors.append(idx + (WIDTH * 5))

    def __repr__(self):
        return f"Node {self.idx}, visited:{self.visitedp}, dist:{self.distance}, cost:{self.cost}, neighbs: {self.neighbors}"

    def __lt__(self, other):
        return self.distance < other.distance


world = []
for idx in range(len(lines)):
    world.append(Node(lines, idx))

world[0].distance = 0
unvisited = [x for x in world]
# import heapq
# heapq.heapify(unvisited)
unvisited.sort()

if False:
    # NOTE: Have to change back the bounds for the Node type, they were changed for part 2
    while True:
        # current = heapq.heappop(unvisited)
        current = unvisited[0]
        unvisited = unvisited[1:]
        for neighb_idx in current.neighbors:
            neighb = world[neighb_idx]
            if neighb.visitedp:
                continue
            candidate = current.distance + neighb.cost
            if candidate < neighb.distance:
                neighb.distance = candidate
        current.visitedp = True
        if world[-1] == current:
            break
        # heapq.heapify(unvisited)
        unvisited.sort()
    print(world[-1])

# Part 2
# need to make bigworld world*5 where we overflow each number at 9
world = []
for idx in range(WIDTH * 5 * WIDTH * 5):
    world.append(Node(lines, idx))
world[0].distance = 0
unvisited = [world[0]]
import heapq
heapq.heapify(unvisited)

while True:
    current = heapq.heappop(unvisited)
    for neighb_idx in current.neighbors:
        neighb = world[neighb_idx]
        if neighb.visitedp:
            continue
        candidate = current.distance + neighb.cost
        if neighb.distance == math.inf:
            unvisited.append(neighb)
        if candidate < neighb.distance:
            neighb.distance = candidate
    current.visitedp = True
    if world[-1] == current:
        break
    heapq.heapify(unvisited)
print(world[-1])
