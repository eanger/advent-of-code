#!/usr/bin/env python3

with open('day22.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
import re
steps = []
for line in lines:
    m = re.match(r"(on|off) x=(.*)\.\.(.*),y=(.*)\.\.(.*),z=(.*)\.\.(.*)", line)
    if m:
        steps.append((m[1],
                      int(m[2]), int(m[3]),
                      int(m[4]), int(m[5]),
                      int(m[6]), int(m[7])))

do_part_1 = False
if do_part_1:
    world = set()
    for (direction, xmin, xmax, ymin, ymax, zmin, zmax) in steps[:20]:
        for x in range(xmin, xmax + 1):
            for y in range(ymin, ymax + 1):
                for z in range(zmin, zmax + 1):
                    if -50 <= x <= 50 and \
                        -50 <= y <= 50 and \
                        -50 <= z <= 50:
                        if direction == 'on':
                            # add elements to world
                            world.add((x, y, z))
                        else:
                            # remove elements from world
                            world.discard((x, y, z))

    print(len(world))

# part 2
_ = '''
maybe region intersections break down cuboids into smaller cuboids?
then all we have to do is keep record of cuboids?

when inserting cuboid, just add to collection

when removing, have to do a collision check with each cuboid
collision:
true for each dimension:
self = b, other = a
return (a.minX <= b.maxX && a.maxX >= b.minX) &&
       (a.minY <= b.maxY && a.maxY >= b.minY) &&
       (a.minZ <= b.maxZ && a.maxZ >= b.minZ)
if they collide, need to remove colliding cuboid and recreate cuboids in void

in three dimensions, there are up to 27 subdivisions of a cuboid on intersection
one of those will by necessity be the intersected cuboid (self)
so up to 26 new cuboids will be made

for 1 dimension, assuming collision:
1 amin bmin: amin <= bmin
2 max(amin, bmin) min(amax, bmax)
3 bmax amax: bmax <= amax

for 2 dimensions, if we assume collision(could be reduced?):
collision:
if axmin <= bxmin:
1 (axmin, aymin) (bxmin, bymin): aymin <= bymin
2 (axmin, max(bymin, aymin)) (bxmin, min(bymax, aymax))
3 (axmin, bymax) (bxmin, aymax): aymax >= bymax

4 (bxmin, aymin) (bxmax, bymin): bymin >= aymin
5 (max(axmin, bxmin), max(aymin, bymin)) (min(axmax, bxmax), min(aymax, bymax))
6 (bxmin, bymax) (bxmax, aymax): aymax >= bymax

if bxmax <= axmax:
7 (bxmax, aymin) (axmax, bymin): aymin <= bymin
8 (bxmax, max(bymin, aymin)) (axmax, min(bymax, aymax))
9 (bxmax, bymax) (axmax, aymax): aymax >= bymax


for dim in [x, y, z]:
rules ^ (num dimension)
rules = [lambda a, b: (a.min, b.min) if a.min <= b.min else False,
         lambda _, _: (max(a.min, b.min), min(a.max, b.max)),
         lambda a, b: (b.max, a.max) if a.max <= b.max else False]
for xrule in rules:
  for yrule in rules:
    for zrule in rules:
      if vals := all(xrule(a.x, b.x), yrule(a.y, b.y), zrule(a.z, b.z)):
        new_cuboid(vals[0], vals[1], vals[2]) vals[i] is pair of min, max for that dim

if a[dim].min <= b[dim].min: (a[dim].min, b[dim].min)
(max(a[dim].min, b[dim].min), min(a[dim].max, b[dim].max))
if b[dim].max <= a[dim].max: (b[dim].max, a[dim].max)

ALL DIMENSIONS ARE INCLUSIVE
'''
from dataclasses import dataclass


rules = [lambda amin, amax, bmin, bmax: (amin, bmin) if amin <= bmin else False,
         lambda amin, amax, bmin, bmax: (max(amin, bmin), min(amax, bmax)),
         lambda amin, amax, bmin, bmax: (bmax, amax) if bmax <= amax else False]


@dataclass(frozen=True)
class Cuboid:
    xmin: int
    xmax: int
    ymin: int
    ymax: int
    zmin: int
    zmax: int

    def num_on(self):
        return ((self.xmax - self.xmin) *
                (self.ymax - self.ymin) *
                (self.zmax - self.zmin))

    def differences(self, other):
        '''
        Returns a list of all cuboids contained by other that aren't
        part of self.
        '''
        res = []
        if (other.xmin <= self.xmax and other.xmax >= self.xmin and
            other.ymin <= self.ymax and other.ymax >= self.ymin and
            other.zmin <= self.zmax and other.zmax >= self.zmin):
            for xidx, xrule in enumerate(rules):
                if xvals := xrule(self.xmin, self.xmax, other.xmin, other.xmax):
                    for yidx, yrule in enumerate(rules):
                        if yvals := yrule(self.ymin, self.ymax, other.ymin, other.ymax):
                            for zidx, zrule in enumerate(rules):
                                if xidx == yidx == zidx == 1:
                                    continue  # we really don't want the middle
                                if zvals := zrule(self.zmin, self.zmax, other.zmin, other.zmax):
                                    res.append(Cuboid(*xvals, *yvals, *zvals))
        return res


cuboids: list[Cuboid] = []
for (direction, xmin, xmax, ymin, ymax, zmin, zmax) in steps:
    step_cuboid = Cuboid(xmin, xmax, ymin, ymax, zmin, zmax)
    new_cuboids = []
    for cuboid in cuboids:
        if to_add := step_cuboid.differences(cuboid):
            new_cuboids.extend(to_add)
        else:
            new_cuboids.append(cuboid)

    if direction == 'on':
        new_cuboids.append(step_cuboid)
    cuboids = new_cuboids

print(sum([cuboid.num_on() for cuboid in cuboids]))
