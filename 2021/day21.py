#!/usr/bin/env python3

# Part 1
p1_start = 6
p2_start = 1

p1_score = 0
p2_score = 0

class Die:
    def __init__(self, maxval):
        self.maxval = maxval
        self.val = 1
        self.num_rolls = 0

    def roll(self):
        retval = self.val
        self.val += 1
        if self.val > self.maxval:
            self.val = 1
        self.num_rolls += 1
        return retval

def pos(loc, inc):
    return ((loc - 1) + inc) % 10 + 1

die = Die(100)
p1_loc = p1_start
p2_loc = p2_start
while True:
    val = die.roll() + die.roll() + die.roll()
    # print(f"{val=}")
    p1_loc = pos(p1_loc, val)
    p1_score += p1_loc
    # print(f"{p1_score=}")
    if p1_score >= 1000:
        loser = p2_score
        break
    val = die.roll() + die.roll() + die.roll()
    p2_loc = pos(p2_loc, val)
    p2_score += p2_loc
    # print(f"{p2_score=}")
    if p2_score >= 1000:
        loser = p1_score
        break

# print(f"{p1_score=}")
# print(f"{p2_score=}")
# print(die.num_rolls)
print(loser * die.num_rolls)

# Part 2
