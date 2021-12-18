#!/usr/bin/env python3

from pprint import pprint

with open('day4.input', 'r') as inp:
    lines = inp.read()

blocks = lines.split('\n\n')

# test = """7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\n\n22 13 17 11  0\n8  2 23  4 24\n21  9 14 16  7\n6 10  3 18  5\n1 12 20 15 19\n\n3 15  0  2 22\n9 18 13 17  5\n19  8  7 25 23\n20 11 10 24  4\n14 21 16 12  6\n\n14 21 17 24  4\n10 16 15  9 19\n18  8 23 26 20\n22 11 13  6  5\n2  0 12  3  7"""
# blocks = test.split('\n\n')

# Part 1

draws = [int(x) for x in blocks[0].split(',')]


class Bingo:
    def __init__(self, inp_str):
        # 1 2 3 4 5
        self.rows = []
        self.cols = [set(), set(), set(), set(), set()]
        for row in inp_str.split('\n'):
            vals = [int(x) for x in row.split()]
            self.rows.append(set(vals))
            for col, v in zip(self.cols, vals):
                col.add(v)

    def __repr__(self):
        res = "ROWS:\n"
        for row in self.rows:
            res += ' '.join([str(x) for x in row])
            res += "\n"
        res += "\nCOLS:\n"
        for col in self.cols:
            res += ' '.join([str(x) for x in col])
            res += "\n"
        return res

    def draw(self, num):
        # remove num from all sets in rows and cols
        # if any row or col is empty, it won!
        retval = False
        for row in self.rows:
            row.discard(num)
            if len(row) == 0:
                retval = True
        for col in self.cols:
            col.discard(num)
            if len(col) == 0:
                retval = True
        return retval

    def score(self):
        # return the sum of all unmarked nums
        score = 0
        for row in self.rows:
            for v in row:
                score += v
        return score


cards = [Bingo(x.strip()) for x in blocks[1:]]


def winner(cds, drws):
    for num in drws:
        for card in cds:
            if card.draw(num):
                # print(card)
                return card.score() * num
    return -1


print(winner(cards, draws))

# Part 2

def winner_p2(cards, draws):
    def play(card):
        for i, num in enumerate(draws):
            if card.draw(num):
                return (i, card.score() * num)
        return ()
    wins = [play(x) for x in cards]
    return sorted(wins, key=lambda x: x[0], reverse=True)[0][1]


print(winner_p2(cards, draws))
