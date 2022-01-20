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

_ = '''
each roll can be 1, 2, or 3
3^3 options for scores for each roll
there are however a limited number of unique rolls in this set
keep map of position+score -> num universes?
on each round, create new set of position+score -> num universes
after calcing new scores, pull out those where that player won
keep going until there are no more positions left to calc


should i just do this recursively
def round():
    for inc, n_univ in score_counts.items():
        x = round(+inc) * 



I feel like an idiot for cheating and using this as a guide:
https://github.com/jonathanpaulson/AdventOfCode/blob/master/2021/21.py
'''
maxscore = 21
seen = {}
def winner(p1_loc, p2_loc, p1_score, p2_score):
    if p1_score >= maxscore:
        return (1, 0)
    if p2_score >= maxscore:
        return (0, 1)
    try:
        return seen[(p1_loc, p2_loc, p1_score, p2_score)]
    except KeyError:
        pass

    p1_sum = 0
    p2_sum = 0
    for i in [1, 2, 3]:
        for j in [1, 2, 3]:
            for k in [1, 2, 3]:
                new_loc = pos(p1_loc, i + j + k)
                new_score = p1_score + new_loc
                p1, p2 = winner(p2_loc, new_loc, p2_score, new_score)
                p1_sum += p2
                p2_sum += p1
    seen[(p1_loc, p2_loc, p1_score, p2_score)] = (p1_sum, p2_sum)
    return (p1_sum, p2_sum)

print(max(winner(p1_start, p2_start, 0, 0)))
