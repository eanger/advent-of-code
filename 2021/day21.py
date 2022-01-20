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
'''
score_counts = {}
for i in [1, 2, 3]:
    for j in [1, 2, 3]:
        for k in [1, 2, 3]:
            count = i + j + k
            if count in score_counts:
                score_counts[count] += 1
            else:
                score_counts[count] = 1
print(score_counts)

# p1_loc = {(p1_start, 0): 1}
# p2_loc = {(p2_start, 0): 1}
locs = {(p1_start, p2_start, 0, 0): 1}
# p1_loc = p1_start
# p2_loc = p2_start
p1_wins = 0
p2_wins = 0
max_score = 8
while locs:
    new_locs = {}
    # print(len(locs))
    for inc, n_univ in score_counts.items():
        for (p1_pos, p2_pos, p1_score, p2_score), univs in locs.items():
            new_pos = pos(p1_pos, inc)
            new_score = p1_pos + new_pos
            print(new_score)
            new_worlds = univs * n_univ
            if new_score >= max_score:
                p1_wins += new_worlds
            else:
                new_locs[(new_pos, p2_pos, new_score, p2_score)] = new_worlds

    locs = {}
    # print(len(new_locs))
    for inc, n_univ in score_counts.items():
        for (p1_pos, p2_pos, p1_score, p2_score), univs in new_locs.items():
            new_pos = pos(p2_pos, inc)
            new_score = p2_pos + new_pos
            new_worlds = univs * n_univ
            if new_score >= max_score:
                p2_wins += new_worlds
            else:
                locs[(p1_pos, new_pos, p1_score, new_score)] = new_worlds

print(f"{p1_wins=}")
print(f"{p2_wins=}")
