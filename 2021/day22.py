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
(a.minx, b.minx), (a.miny, b.miny)
(b.minx, a.maxx), (a.miny, b.miny)
(a.minx, b.minx), (b.miny, a.maxy)
if left>=right for any dimension above, that cuboid is contained

'''
from dataclasses import dataclass

@dataclass(frozen=True)
class Cuboid:
    xmin: int
    xmax: int
    ymin: int
    ymax: int
    zmin: int
    zmax: int

    def num_on(self):
        return (self.xmax - self.xmin) * \
            (self.ymax - self.ymin) * \
            (self.zmax - self.zmin)

    def intersections(self, other):
        if (other.xmin <= self.xmax and other.xmax >= self.xmin and
            other.ymin <= self.ymax and other.ymax >= self.ymin and
            other.zmin <= self.zmax and other.zmax >= self.zmin):
            pass


cuboids: list[Cuboid] = []
for (direction, xmin, xmax, ymin, ymax, zmin, zmax) in steps:
    step_cuboid = Cuboid(xmin, xmax, ymin, ymax, zmin, zmax)
    new_cuboids = []
    for cuboid in cuboids:
        if to_add := step_cuboid.intersections(cuboid):
            new_cuboids.extend(to_add)
        else:
            new_cuboids.append(cuboid)

    if direction == 'on':
        new_cuboids.append(step_cuboid)
    cuboids = new_cuboids

print(sum([cuboid.num_on() for cuboid in cuboids]))
