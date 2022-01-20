#!/usr/bin/env python3

with open('day20a.input', 'r') as inp:
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
        # 1. extend grid
        self.grid.insert(0, self.oob * self.width)
        self.grid.append(self.oob * self.width)
        self.grid = [''.join([self.oob, row, self.oob]) for row in self.grid]
        self.width += 2
        self.height += 2
        # 2. set up new grid
        new_grid = []
        # 3. walk through old grid and update new grid based on values
        for j in range(self.height):
            row = []
            for i in range(self.width):
                row.append(self.calc_pixel(i, j))
            new_grid.append(''.join(row))
        self.grid = new_grid
        # 4. flip oob
        self.oob = '#' if self.oob == '.' else '#'



image = Image(lines[2:], lines[0])
image.enhance()
image.enhance()
print(image)


_ = '''
0:   ON
512: OFF

after one flip, assume all out of bounds values are 1s
after two flips, assume all out of bounds values are 0s

for the grid, output image will be 2 wider and 2 taller than input grid
so start by shifting input right and down, filling in border with OOB value
'''
