#!/usr/bin/env python3

with open('day19a.input', 'r') as inp:
    lines = inp.read()
chunks = lines.strip().split('\n\n')
chunk_lines = [chunk.split('\n')[1:] for chunk in chunks]

# Part 1
from dataclasses import dataclass

# See https://www.euclideanspace.com/maths/algebra/matrix/transforms/examples/index.htm
ROTATIONS = [
    lambda pos: Pos(pos.x, pos.y, pos.z),
    lambda pos: Pos(pos.x, -pos.z, pos.y),
    lambda pos: Pos(pos.x, -pos.y, -pos.z),
    lambda pos: Pos(pos.x, pos.z, -pos.y),
    lambda pos: Pos(-pos.y, pos.x, pos.z),
    lambda pos: Pos(pos.z, pos.x, pos.y),
    lambda pos: Pos(pos.y, pos.x, -pos.z),
    lambda pos: Pos(-pos.z, pos.x, -pos.y),
    lambda pos: Pos(-pos.x, -pos.y, pos.z),
    lambda pos: Pos(-pos.x, -pos.z, -pos.y),
    lambda pos: Pos(-pos.x, pos.y, -pos.z),
    lambda pos: Pos(-pos.x, pos.z, pos.y),
    lambda pos: Pos(pos.y, -pos.x, pos.z),
    lambda pos: Pos(pos.z, -pos.x, -pos.y),
    lambda pos: Pos(-pos.y, -pos.x, -pos.z),
    lambda pos: Pos(-pos.z, -pos.x, pos.y),
    lambda pos: Pos(-pos.z, pos.y, pos.x),
    lambda pos: Pos(pos.y, pos.z, pos.x),
    lambda pos: Pos(pos.z, -pos.y, pos.x),
    lambda pos: Pos(-pos.y, -pos.z, pos.x),
    lambda pos: Pos(-pos.z, -pos.y, -pos.x),
    lambda pos: Pos(-pos.y, pos.z, -pos.x),
    lambda pos: Pos(pos.z, pos.y, -pos.x),
    lambda pos: Pos(pos.y, -pos.z, -pos.x)]
# ROTATIONS = [
#     lambda pos: Pos(pos.x, pos.y, pos.z),
#     lambda pos: Pos(pos.x, pos.y, -pos.z),
#     lambda pos: Pos(pos.x, -pos.y, pos.z),
#     lambda pos: Pos(pos.x, -pos.y, -pos.z),
#     lambda pos: Pos(-pos.x, pos.y, pos.z),
#     lambda pos: Pos(-pos.x, pos.y, -pos.z),
#     lambda pos: Pos(-pos.x, -pos.y, pos.z),
#     lambda pos: Pos(-pos.x, -pos.y, -pos.z),
#     lambda pos: Pos(pos.z, pos.x, pos.y),
#     lambda pos: Pos(pos.z, pos.x, -pos.y),
#     lambda pos: Pos(pos.z, -pos.x, pos.y),
#     lambda pos: Pos(pos.z, -pos.x, -pos.y),
#     lambda pos: Pos(-pos.z, pos.x, pos.y),
#     lambda pos: Pos(-pos.z, pos.x, -pos.y),
#     lambda pos: Pos(-pos.z, -pos.x, pos.y),
#     lambda pos: Pos(-pos.z, -pos.x, -pos.y),
#     lambda pos: Pos(pos.y, pos.z, pos.x),
#     lambda pos: Pos(pos.y, pos.z, -pos.x),
#     lambda pos: Pos(pos.y, -pos.z, pos.x),
#     lambda pos: Pos(pos.y, -pos.z, -pos.x),
#     lambda pos: Pos(-pos.y, pos.z, pos.x),
#     lambda pos: Pos(-pos.y, pos.z, -pos.x),
#     lambda pos: Pos(-pos.y, -pos.z, pos.x),
#     lambda pos: Pos(-pos.y, -pos.z, -pos.x),
#     lambda pos: Pos(pos.x, pos.z, pos.y),
#     lambda pos: Pos(pos.x, pos.z, -pos.y),
#     lambda pos: Pos(pos.x, -pos.z, pos.y),
#     lambda pos: Pos(pos.x, -pos.z, -pos.y),
#     lambda pos: Pos(-pos.x, pos.z, pos.y),
#     lambda pos: Pos(-pos.x, pos.z, -pos.y),
#     lambda pos: Pos(-pos.x, -pos.z, pos.y),
#     lambda pos: Pos(-pos.x, -pos.z, -pos.y),
#     lambda pos: Pos(pos.y, pos.x, pos.z),
#     lambda pos: Pos(pos.y, pos.x, -pos.z),
#     lambda pos: Pos(pos.y, -pos.x, pos.z),
#     lambda pos: Pos(pos.y, -pos.x, -pos.z),
#     lambda pos: Pos(-pos.y, pos.x, pos.z),
#     lambda pos: Pos(-pos.y, pos.x, -pos.z),
#     lambda pos: Pos(-pos.y, -pos.x, pos.z),
#     lambda pos: Pos(-pos.y, -pos.x, -pos.z),
#     lambda pos: Pos(pos.z, pos.y, pos.x),
#     lambda pos: Pos(pos.z, pos.y, -pos.x),
#     lambda pos: Pos(pos.z, -pos.y, pos.x),
#     lambda pos: Pos(pos.z, -pos.y, -pos.x),
#     lambda pos: Pos(-pos.z, pos.y, pos.x),
#     lambda pos: Pos(-pos.z, pos.y, -pos.x),
#     lambda pos: Pos(-pos.z, -pos.y, pos.x),
#     lambda pos: Pos(-pos.z, -pos.y, -pos.x)
# ]

@dataclass(frozen=True)
class Pos:
    x: int
    y: int
    z: int
    def sq_distance(self, other):
        return (self.x - other.x) ** 2 + (self.y - other.y) ** 2 +\
            (self.z - other.z) ** 2

    def manhattan_distance(self, other):
        return abs(self.x - other.x) + abs(self.y - other.y) + abs(self.z - other.z)

    def __sub__(self, other):
        return Pos(self.x - other.x, self.y - other.y, self.z - other.z)

    def __add__(self, other):
        return Pos(self.x + other.x, self.y + other.y, self.z + other.z)

    def cross(self, other):
        '''
        cx = aybz − azby
        cy = azbx − axbz
        cz = axby − aybx
        '''
        return Pos(self.y * other.z - self.z * other.y,
                   self.z * other.x - self.x * other.z,
                   self.x * other.y - self.y * other.x)


class Scanner:
    def __init__(self, beacon_list: list[str]):
        self.beacons = []
        for line in beacon_list:
            coords = [int(x) for x in line.split(',')]
            pos = Pos(*coords)
            self.beacons.append(pos)
        self.distances = [] # euclidian distances for each point
        for i in range(len(self.beacons)):
            for j in range(i + 1, len(self.beacons)):
                dist = self.beacons[i].manhattan_distance(self.beacons[j])
                self.distances.append((dist, (i, j)))
        # this maps a distance to the pair of beacons
        self.distances = sorted(self.distances, key=lambda x: x[0])

    def __repr__(self):
        return f"{self.beacons=}"

    def relative_distance_to(self, other):
        '''
        if these overlap, return the relative distance and rotation
        how to calculate the relative distance:
        for one of the matching points, other rel to self = self - other
        find two beacons with unique distance that overlap
        can this help us determine rotation?
        normalize to a single direction, then we can calculate the rotation from self to other

        returns: rotation index, rel position, beacons rel to self
        '''
        that = other.distances[:]
        matches = []
        for dist, (a, b) in self.distances:
            for i, (cand, (c, d)) in enumerate(that):
                if cand == dist:
                    matches.append((a, b, c, d))
                    del that[i]
                    break
        if len(matches) >= 66:
            for m in matches:
                this_vec = self.beacons[m[1]] - self.beacons[m[0]]
                other_vec = other.beacons[m[3]] - other.beacons[m[2]]
                for i, rot in enumerate(ROTATIONS):
                    if this_vec == rot(other_vec):
                        return i, self.beacons[m[1]] - rot(other.beacons[m[3]]), [rot(v) for v in other.beacons]
            print("ERROR: unreachable")
            print(this_vec)
            print(other_vec)
            return None
        # no match
        return None

scanners = [Scanner(x) for x in chunk_lines]

_ = '''
each scanner has several beacons it can sense
if we call scanner0 the origin,
all other scanners are relative to scanner0
which means all beacons are indirectly relative

start with cur_scanner = scanner0
for each scanner left, find one with at least 12 overlapping sensors to cur_scanner
this scanner then becomes cur_scanner, continue loop

we need the union of all beacons
when we find a matching scanner, we mark down it's position relative to scanner0
as well, we determine each beacon's position relative to scanner0 and add it to the set of beacons

determining overlap:
euclidian squared distance is orientation-independent
squared distance from each point to every other point
if at least 12 choose 2 (66) are the same value, these overlap
'''


# for j, cur in enumerate(scanners):
#     links = []
#     for idx, candidate in enumerate(scanners):
#         overlaps = cur.relative_distance_to(candidate)
#         if overlaps:
#             links.append(idx)
#     print(f'{j}: {links}')

'''
build a graph starting from scanner0 of connections
maybe map scanner->position rel to scanner0
worklist = [scanner0]
while rest_scanners:
    pop item work_item off worklist
    for candidate in rest_scanners:
        if work_item overlaps candidate:
            determine beacon positions
            add candidate to worklist
            remove from rest_scanners
'''
rest_scanners = scanners[1:]
world = {scanners[0]: Pos(0, 0, 0)}
beacon_positions = set(scanners[0].beacons)
worklist = [scanners[0]]
while rest_scanners:
    work_item = worklist.pop()
    new_worklist_items = []
    for cand in rest_scanners:
        overlaps = work_item.relative_distance_to(cand)
        if overlaps:
            # print('found overlap')
            # returns: rotation index, rel position, beacons rel to self
            rot, pos, beacs = overlaps
            world[cand] = world[work_item] + pos
            new_worklist_items.append(cand)
            for beac in beacs:
                beacon_positions.add(beac + world[work_item])
    for e in new_worklist_items:
        worklist.append(e)
        rest_scanners.remove(e)

a, b, c = scanners[0].relative_distance_to(scanners[1])
print(b)
'''
b is scanner1 position in scanner0's frame of reference
a is how to rotate scanner1 to get to scanner 0
e is scanner4 position in scanner1's frame of reference
d is how to rotate scanner4 to get to scanner 1
rot_a(e) is scanner4's position rel to scanner 0
h is scanner2 position in scanner4's frame of reference
g is how to rotate scanner2 to get to scanner 4


affine transformations?
rot_a(rot_b(x)) commutative? nope



a(d(g(x)))
'''
# rot0 = ROTATIONS[a]
d, e, f = scanners[1].relative_distance_to(scanners[4])
# print(e)
# rot1 = ROTATIONS[d]
# print(ROTATIONS[a](e) + b)
g, h, i = scanners[4].relative_distance_to(scanners[2])


# rot4 = ROTATIONS[g]
# print(rot1(rot0(h)) + e)
# print(h)
# print(ROTATIONS[d](h) + e)
# print(len(beacon_positions))
# pprint(world.values())
# for w in world.values():
#     print(w)
# # pprint(beacon_positions)





# This is relative to the prior scanner, not scanner 0!
# scanner_positions = [Pos(0, 0, 0)]
# basis = Pos(0, 0, 0)
# beacon_positions = set(cur_scanner.beacons)
# while rest_scanners:
#     print(f"finding next scanner out of {len(rest_scanners)}")
#     found = False
#     for idx, candidate in enumerate(rest_scanners):
#         print(f'check {idx}')
#         overlaps = cur_scanner.relative_distance_to(candidate)
#         if overlaps:
#             print('found overlap')
#             found = True
#             rot, pos, beacs = overlaps
#             scanner_positions.append(pos)
#             for beacon in beacs:
#                 beacon_positions.add(beacon + basis)
#             cur_scanner = candidate
#             basis = basis + pos
#             # rest_scanners.remove(candidate)
#             del rest_scanners[idx]
#             break
#     if not found:
#         print("ERROR, none found")
#         break

# print(len(beacon_positions))

# test should be 0, 1, 4, 2, 3
# ie,          (0), 0, 2, 0, 0
# can get list of how everything overlaps
# is it always a single chain? ie 0 overlaps a single other
# but the rest overlap at least 2 except for one?
# nope, just have to add on to known space
