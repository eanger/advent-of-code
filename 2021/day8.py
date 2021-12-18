#!/usr/bin/env python3

from pprint import pprint

with open('day8.input', 'r') as inp:
    lines = inp.readlines()

# Part 1
signals = []
outs = []
for line in lines:
    sides = line.split('|')
    sig = sides[0].strip().split(' ')
    signals.append(sig)
    ot = sides[1].strip().split(' ')
    outs.append(ot)

uniqs = [2, 3, 4, 7]
count = 0
for out in outs:
    for elem in out:
        # print(elem)
        if len(elem) in uniqs:
            count += 1
print(count)

# Part 2
# 1: 2
# 7: 3
# 4: 4
# 2: 5
# 3: 5
# 5: 5
# 0: 6
# 6: 6
# 9: 6
# 8: 7
# 1, 4, 7, 8 are identifiable
# 1 and 7 will identify segments a, c, f
# a,c,f present on 5chars identifies 3
# a,c   present on 5chars identifies 2 NOPE
# a,f   present on 5chars identifies 5 NOPE
# 5 chars and 2 similar segs with 4 identifies 2
# 5 chars and 3 similar segs with 5 identifies 5
# 6, 9, 0 left
# a,f   present on 6chars identifies 6
# if all of 4 is present on 6chars, its 9
# else it's 0


def get_mapping(sigs: set[str]) -> dict[frozenset[str], str]:
    def find(pred) -> str:
        return next(filter(pred, sigs))
    one = find(lambda x: len(x) == 2)
    sigs.remove(one)
    seven = find(lambda x: len(x) == 3)
    sigs.remove(seven)
    four = find(lambda x: len(x) == 4)
    sigs.remove(four)
    eight = find(lambda x: len(x) == 7)
    sigs.remove(eight)

    three = find(lambda x: len(x) == 5 and set(seven).issubset(x))
    sigs.remove(three)

    five = find(lambda x: len(x) == 5 and len(set(four) & set(x)) == 3)
    sigs.remove(five)

    two = find(lambda x: len(x) == 5)
    sigs.remove(two)

    nine = find(lambda x: len(x) == 6 and set(four).issubset(x))
    sigs.remove(nine)

    zero = find(lambda x: len(x) == 6 and set(one).issubset(x))
    sigs.remove(zero)

    six = sigs.pop()

    return {frozenset(one): '1', frozenset(two): '2', frozenset(three): '3',
            frozenset(four): '4', frozenset(five): '5', frozenset(six): '6',
            frozenset(seven): '7', frozenset(eight): '8', frozenset(nine): '9',
            frozenset(zero): '0'}


def get_output(signal: list[str], out: list[str]) -> int:
    mapping = get_mapping(set(signal))
    res = int(''.join(mapping[frozenset(x)] for x in out))
    return res

total = sum([get_output(signal, out) for (signal, out) in zip(signals, outs)])
print(total)
