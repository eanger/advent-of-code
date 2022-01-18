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
            m = matches[1]
            this_vec = self.beacons[m[1]] - self.beacons[m[0]]
            other_vec = other.beacons[m[3]] - other.beacons[m[2]]
            for i, lam in enumerate(ROTATIONS):
                if this_vec == lam(other_vec):
                    return i, self.beacons[m[1]] - lam(other.beacons[m[3]]), [lam(v) for v in other.beacons]
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

cur_scanner = scanners[0]
rest_scanners = scanners[1:]
# This is relative to the prior scanner, not scanner 0!
scanner_positions = [Pos(0, 0, 0)]
basis = Pos(0, 0, 0)
beacon_positions = set(cur_scanner.beacons)
while rest_scanners:
    success = False
    for idx, candidate in enumerate(rest_scanners):
        overlaps = cur_scanner.relative_distance_to(candidate)
        if overlaps:
            success = True
            print('a')
            # print(overlaps)
    if success:
        print('b')
        cur_scanner = candidate
        del rest_scanners[idx]
    else:
        print('aaaaa')
        break
            # rot, pos, beacs = overlaps
            # scanner_positions.append(pos)
            # for beacon in beacs:
            #     beacon_positions.add(beacon + basis)
            # cur_scanner = candidate
            # basis = basis + pos
            # rest_scanners.remove(candidate)
            # break
# print(len(beacon_positions))
