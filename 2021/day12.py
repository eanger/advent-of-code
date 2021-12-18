#!/usr/bin/env python3

with open('day12.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1

from pprint import pprint

links = [x.split('-') for x in lines]


class Node:
    def __init__(self, name):
        self.name = name
        self.smallp = True
        if name.isupper():
            self.smallp = False
        self.connections = []

    def __repr__(self):
        return f"Node({'small' if self.smallp else 'big'}) '{self.name}'"

    def connect(self, conn):
        self.connections.append(conn)

    def find_to_end(self, visited):
        # 1. if this is end, return 1
        # 2. if self.smallp and in visited, return 0
        # 3. visited += self if not smallp
        # 4. return sum(e.count_to_end(visited) for e in self.connections)
        if self.name == 'end':
            return [['end']]
        if self.smallp and self in visited:
            return []
        new_visited = visited | frozenset([self])
        all_paths = []
        for conn in self.connections:
            # this should be a list of lists, which could be an empty list
            paths = conn.find_to_end(new_visited)
            for p in paths:
                if p != []:
                    p.append(self.name)
                    all_paths.append(p)
        return all_paths

    def find_to_end_p2(self, visited, twice):
        # 1. if this is end, return 1
        # 2. if self.smallp and in visited, return 0
        # 3. visited += self if not smallp
        # 4. return sum(e.count_to_end(visited) for e in self.connections)
        if self.name == 'end':
            return [['end']]
        if self.smallp and self in visited:
            return []
        if self == twice:
            twice = None
            new_visited = visited
        else:
            new_visited = visited | frozenset([self])
        all_paths = []
        for conn in self.connections:
            # this should be a list of lists, which could be an empty list
            paths = conn.find_to_end_p2(new_visited, twice)
            for p in paths:
                if p != []:
                    p.append(self.name)
                    all_paths.append(p)
        return all_paths


nodes: dict[str, Node] = {}
for (left, right) in links:
    lnode = nodes.get(left, Node(left))
    rnode = nodes.get(right, Node(right))
    lnode.connect(rnode)
    rnode.connect(lnode)
    nodes[left] = lnode
    nodes[right] = rnode

x = nodes['start'].find_to_end(frozenset())
uniqs = set([','.join(y) for y in x])
print(len(uniqs))

# Part 2
# Consider having a global double-entry node that we loop through
# then combine all the searches for all double-entry options

for name, node in nodes.items():
    if node.smallp and node.name not in ['start', 'end']:
        pths = nodes['start'].find_to_end_p2(frozenset(), node)
        pths = set([','.join(y) for y in pths])
        uniqs.update(pths)

print(len(uniqs))
