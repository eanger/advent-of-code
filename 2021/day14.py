#!/usr/bin/env python3

with open('day14.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
template = lines[0]
rules = lines[2:]
print(template)
print(rules[0])


def parse_rule(rule):
    parts = rule.split(' ')
    return (parts[0], parts[2])


rules = dict(parse_rule(rule) for rule in rules)
# 1. walk through each pair and identify the matching rule, if there is one
# 2. keep a list of updates location/char to perform per rule match
# 3. apply all updates


def step(template):
    updates = []
    # for start in range(len(template) - 1):
    for i, j in zip(template, template[1:]):
        target = i + j
        sub = rules.get(target, '')
        updates.append(i)
        updates.append(sub)
    retval = ''.join(updates + [template[-1]])
    return retval


for _ in range(10):
    template = step(template)

counts = {}
for x in template:
    val = counts.get(x, 0)
    counts[x] = val + 1

maxval = max(counts.items(), key=lambda x: x[1])[1]
minval = min(counts.items(), key=lambda x: x[1])[1]
print(maxval - minval)

# Part 2
# keep dict of count of char pairs
# step: make new dict of substitutions
from collections import defaultdict
template = lines[0]


def step_p2(template, counts):
    updates = defaultdict(lambda: 0)
    for key, val in template.items():
        try:
            sub = rules[key]
            counts[sub] += val
            updates[key[0] + sub] += val
            updates[sub + key[1]] += val
        except KeyError:
            updates[key] += 1
    return updates, counts

counts = defaultdict(lambda: 0)
for c in template:
    counts[c] += 1
template_dict = defaultdict(lambda: 0)
for idx in range(len(template) - 1):
    elem = template[idx:idx + 2]
    template_dict[elem] += 1
print(template)
print(template_dict)
for _ in range(40):
    template_dict, counts = step_p2(template_dict, counts)
print(max(counts.values()) - min(counts.values()))
