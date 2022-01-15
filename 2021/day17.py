#!/usr/bin/env python3

# ACTUAL
xmin = 79
xmax = 137
ymin = -176
ymax = -117

# SAMPLE???
# xmin = 20
# xmax = 30
# ymin = -10
# ymax = -5

# Part 1
# each step reduces x vel by 1
# xmin = xvel + (xvel - 1) + (xvel - 2) ... (xvel - xvel)
# xmin = 1/2 * (xvel - 1) * xvel

possible = []
for x in range(100):
    val = int(1 / 2 * (x - 1) * x)
    if xmin <= val <= xmax:
        possible.append(x)

# print(possible)

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


# # for xval in possible:
# positions = 0
# # for xval in range(14, xmax + 2):
# for xval in range(1, xmax + 2):
#     # try y vals, see how high it gets
#     for y in range(1, 1000):
#         pos = Pos(0, 0, xval, y)
#         while pos.y >= ymin:
#             step(pos)
#             if ymin <= pos.y <= ymax and xmin <= pos.x <= xmax:
#                 positions += 1
#                 break
# print(positions)

# smallest x value: such that it reaches 0 velocity
# n + (n - 1) + (n - 2) .. 0
# (n + 0)/2 + (n-1 + 1)/2
# n(n+1)/2, 6=>21
# n(n+1)/2 = xmin

minxvel = 0
while True:
    # s = n*(n+1)/2
    val = int(1 / 2 * (minxvel + 1) * minxvel)
    if val >= xmin:
        break
    minxvel += 1
maxxvel=xmax
print(f"{minxvel=}")
print(f"{maxxvel=}")

# smallest y value: bottom left corner of trench
minyvel=ymin
print(f"{minyvel=}")

maxyvel=None
print(f"{maxyvel=}")

positions = 0
for xval in range(minxvel, maxxvel + 1):
    for y in range(minyvel, 1000):
        pos = Pos(0, 0, xval, y)
        while pos.y >= ymin:
            step(pos)
            if ymin <= pos.y <= ymax and xmin <= pos.x <= xmax:
                positions += 1
                break
print(f"{positions=}")
