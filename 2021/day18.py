#!/usr/bin/env python3

with open('day18.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
# numbers = [eval(line) for line in lines]

# a number is a list of digits and an indication of where pairs are
# [[1,2],3] -> 1 2 .... 1 2 3
# [[[[[9,8],1],2],3],4] -> 9 8, 9 8 1, 9 8 1 2, 9 8 1 2 3, 9 8 1 2 3 4
# OR
# ls-le,rs-re: 0-1,1-2 0-2,2-3. 0-1,1-2 0-2,2-3 0-3,3-4 0-4,4-5 0-5,5-6

# make a struct representing a pair
# implicit link?
# each pair knows its own depth
# on cons, increment depth for all children
# explode modifies entries and removes one


class Number:
    def __init__(self, n_str):
        self.numbers = []
        self.depths = []
        depth = 0
        for c in n_str:
            if c == '[':
                depth += 1
            elif c == ']':
                depth -= 1
            elif c == ',':
                pass
            else:
                self.numbers.append(int(c))
                self.depths.append(depth)

    def __repr__(self):
        return f"{self.numbers=} {self.depths=}"

    def is_nested(self):
        return any([x > 4 for x in self.depths])

    def has_ge_ten(self):
        return any([x >= 10 for x in self.numbers])

    def get_deepest(self):
        max_depth = 0
        max_idx = -1
        for idx, (l, r) in enumerate(zip(self.depths[:-1], self.depths[1:])):
            if l == r and l > max_depth:
                max_depth = l
                max_idx = idx
        return max_idx

    def explode(self):
        deepest = self.get_deepest()
        if self.depths[deepest] < 5:
            return

        # print(f'explode!: {deepest}')
        # add l to numbers[deepest - 1] if it exists
        if deepest > 0:
            self.numbers[deepest - 1] += self.numbers[deepest]
        if deepest < (len(self.numbers) - 2):
            self.numbers[deepest + 2] += self.numbers[deepest + 1]
        self.numbers[deepest] = 0
        self.depths[deepest] -= 1
        del self.numbers[deepest + 1]
        del self.depths[deepest + 1]

    def split(self):
        for idx, val in enumerate(self.numbers):
            if val > 9:
                # print(f'split!: {idx}')
                # get values for new pair
                v1 = val // 2
                v2 = (val + 1) // 2
                # replace numbers[idx] with first new val
                self.numbers[idx] = v1
                # insert second new val into numbers[idx + 1]
                self.numbers.insert(idx + 1, v2)
                # depth is depth[idx] + 1 for both in pair
                self.depths[idx] += 1
                self.depths.insert(idx + 1, self.depths[idx])
                break

    def simplify(self):
        # Determine if any pair is nested inside 4 pairs
        # If so, explode and return
        # Else, determine if any number is >= 10
        # If so, split
        while True:
            if self.is_nested():
                self.explode()
                continue
            if self.has_ge_ten():
                self.split()
                continue
            break

    def add(self, other):
        self.numbers.extend(other.numbers)
        self.depths.extend(other.depths)
        self.depths = [x + 1 for x in self.depths]
        self.simplify()

    def magnitude(self):
        # while len(numbers != 1
        # find a pair and reduce, which will shrink list by 1
        nums = self.numbers[:] #  make copies
        depths = self.depths[:]
        while(len(nums) != 1):
            for idx in range(len(nums) - 1):
                l = depths[idx]
                r = depths[idx + 1]
                if l != r:
                    continue
                mag = 3 * nums[idx] + 2 * nums[idx + 1]
                nums[idx] = mag
                del nums[idx + 1]
                depths[idx] -= 1
                del depths[idx + 1]
                break
        return nums[0]


a = Number(lines[0])
for x in lines[1:]:
    a.add(Number(x))
print(a.magnitude())

# Part 2

max_mag = 0
for line in lines:
    for x in lines:
        if x == a:
            continue
        a = Number(line)
        a.add(Number(x))
        mag = a.magnitude()
        if mag > max_mag:
            max_mag = mag
print(f"{max_mag=}")
