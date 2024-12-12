#!/usr/bin/env python3

import util


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
part2_example = ''


def parse(inp):
    parts = inp.split('\n\n')
    raw_rules = [[int(y) for y in x.split('|')] for x in parts[0].split()]
    rules = {x[0]: [] for x in raw_rules}
    for rule in raw_rules:
        rules[rule[0]].append(rule[1])
    updates = [[int(y) for y in x.split(',')] for x in parts[1].split()]
    return rules, updates


def update_value(update, rules):
    for i in range(len(update)):
        candidate = update[i]
        left = set(update[:i])
        if any(x in left for x in rules.get(candidate, set())):
            return 0
    return update[len(update) // 2]


def part1(inp):
    # to parse rules:
    # each number on left has list of things that must follow it
    # eg 97: [13,61,...]
    # then, when walking through the updates, partition on the element, and
    # if the element is in the list of rules, all elements in the list must be in the right partition
    rules, updates = parse(inp)
    return sum(update_value(x, rules) for x in updates)


def part2(inp):
    pass


# ------------------------------------------------
print(part1(part1_example))
print(part1(util.input_str()))
print(part2(part2_example))
