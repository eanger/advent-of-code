#!/usr/bin/env python3

xmin = 79
xmax = 137
ymin = -176
ymax = -117

xmin = 20
xmax = 30
ymin = -10
ymax = -5

# Part 1
# each step reduces x vel by 1
# xmin = xvel + (xvel - 1) + (xvel - 2) ... (xvel - xvel)
# xmin = 1/2 * (xvel - 1) * xvel

possible = []
for x in range(100):
    val = int(1 / 2 * (x - 1) * x)
    if xmin <= val <= xmax:
        possible.append(x)

print(possible)

# y vel decreases by 1 each step


class Pos:
    def __init__(self, x, y, xvel, yvel):
        self.x = x
        self.y = y
        self.xvel = xvel
        self.yvel = yvel


def step(pos):
    pos.x += pos.xvel
    pos.y += pos.yvel
    pos.xvel = pos.xvel - 1 if pos.xvel != 0 else 0
    pos.yvel -= 1


# highest = -1
# # for xval in possible:
# for xval in range(14, 100):
#     # try y gals, see how high it gets
#     for y in range(500):
#         positions = []
#         pos = Pos(0, 0, xval, y)
#         success = False
#         while pos.y >= ymin:
#             positions.append(pos.y)
#             step(pos)
#             if ymin <= pos.y <= ymax:
#                 success = True
#                 break
#         if success:
#             cand = max(positions)
#             if cand > highest:
#                 highest = cand
# print(highest)

# Part 2
# can find all pairs (xvel,t) that land in xmin--xmax
# way to calc pairs of (yvel,t) that land in ymin--ymax??


# for xval in possible:
positions = 0
# for xval in range(14, xmax + 2):
for xval in range(1, xmax + 2):
    # try y gals, see how high it gets
    for y in range(1, 1000):
        pos = Pos(0, 0, xval, y)
        while pos.y >= ymin:
            step(pos)
            if ymin <= pos.y <= ymax and xmin <= pos.x <= xmax:
                positions += 1
                break
print(positions)
