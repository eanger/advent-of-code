#!/usr/bin/env python3

with open('day20.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1

class Image:
    def __init__(self, string, algo):
        self.grid = string
        self.width = len(self.grid[0])
        self.height = len(self.grid)
        self.oob = '.'
        self.algo = algo

    def __repr__(self):
        return '\n'.join(self.grid)

    def calc_pixel(self, x, y):
        bits = []
        for j in range(y - 1, y + 2):
            for i in range(x - 1, x + 2):
                if i < 0 or j < 0 or i >= self.width or j >= self.height:
                    bits.append(self.oob)
                else:
                    bits.append(self.grid[j][i])
        bits = ''.join(bits)
        bits = bits.replace('#', '1')
        bits = bits.replace('.', '0')
        index = int(bits, 2)
        return self.algo[index]

    def enhance(self):
        # 1. set up new grid
        new_grid = []
        # 2. walk through old grid and update new grid based on values
        for j in range(-1, self.height + 1):
            row = []
            for i in range(-1, self.width + 1):
                row.append(self.calc_pixel(i, j))
            new_grid.append(''.join(row))
        self.grid = new_grid
        self.width = len(self.grid[0])
        self.height = len(self.grid)
        # 3. flip oob
        self.oob = self.calc_pixel(-3, -3) # find arbitrary zone outside of image

    def bits_set(self):
        count = 0
        for row in self.grid:
            for bit in row:
                if bit == '#':
                    count += 1
        return count



image = Image(lines[2:], lines[0])
for i in range(50):
    image.enhance()
print(image.bits_set())


_ = '''
0:   ON
512: OFF

after one flip, assume all out of bounds values are 1s
after two flips, assume all out of bounds values are 0s

for the grid, output image will be 2 wider and 2 taller than input grid
so start by shifting input right and down, filling in border with OOB value
'''
