#!/usr/bin/env python3

import util
import itertools


part1_example = """47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"""
part2_example = part1_example


def parse(inp):
    parts = inp.split('\n\n')
    raw_rules = [[int(y) for y in x.split('|')] for x in parts[0].split()]
    rules = {x[0]: [] for x in raw_rules}
    for rule in raw_rules:
        rules[rule[0]].append(rule[1])
    updates = [[int(y) for y in x.split(',')] for x in parts[1].split()]
    return rules, updates


def check_value(update, rules):
    for i in range(len(update)):
        candidate = update[i]
        left = set(update[:i])
        if any(x in left for x in rules.get(candidate, [])):
            return False
    return True


def update_value(update, rules):
    if check_value(update, rules):
        return update[len(update) // 2]
    return 0


def part1(inp):
    # to parse rules:
    # each number on left has list of things that must follow it
    # eg 97: [13,61,...]
    # then, when walking through the updates, partition on the element, and
    # if the element is in the list of rules, all elements in the list must be in the right partition
    rules, updates = parse(inp)
    return sum(update_value(x, rules) for x in updates)


def fix_update(update, rules):
    """
    if something is in left that shouldn't be, remove it and place it just to the right

    75,97,47,61,53
       ^ should have 75 come after it

    would become
    97,75,47,61,53

    """
    i = 0
    while i < len(update):
        candidate = update[i]
        left = update[:i]
        to_swap = -1
        for rule in rules.get(candidate, []):
            try:
                to_swap = left.index(rule)
                break
            except ValueError:
                pass
        if to_swap != -1:
            update = update[:to_swap] + update[to_swap+1:i] + [candidate, update[to_swap]] + update[i+1:]
            i -= 1
        else:
            i += 1

    return update[len(update) // 2]

def part2(inp):
    rules, updates = parse(inp)
    values = [update_value(x, rules) for x in updates]
    to_fix = [a for a, b in zip(updates, values) if b == 0]
    return sum(fix_update(x, rules) for x in to_fix)


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
print(part2(util.input_str()))
