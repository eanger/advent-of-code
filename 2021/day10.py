#!/usr/bin/env python3

with open('day10.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1

scorecard = {')': 3,
             ']': 57,
             '}': 1197,
             '>': 25137}
matching = {'(': ')',
            '[': ']',
            '{': '}',
            '<': '>'}


def score(line):
    stack = []
    for elem in line:
        if elem in '([{<':
            stack.append(elem)
        elif elem in ')]}>':
            if elem != matching[stack[-1]]:
                return scorecard[elem]
            stack = stack[:-1]
        else:
            print(f"ERROR: Invalid char '{elem}'")
            return -1
    return 0


print(sum(score(x) for x in lines))

# Part 2
scorecard_p2 = {')': 1,
                ']': 2,
                '}': 3,
                '>': 4}


def score2(missing):
    total = 0
    for elem in map(lambda x: matching[x], reversed(missing)):
        total = total * 5 + scorecard_p2[elem]
    return total


def incomplete(line):
    stack = []
    for elem in line:
        if elem in '([{<':
            stack.append(elem)
        elif elem in ')]}>':
            if elem != matching[stack[-1]]:
                # CORRUPTED
                return None
            stack = stack[:-1]
        else:
            print(f"ERROR: Invalid char '{elem}'")
            return None
    return score2(stack) if len(stack) != 0 else None


incompletes = sorted(filter(None, map(incomplete, lines)))
print(incompletes[len(incompletes)//2])
