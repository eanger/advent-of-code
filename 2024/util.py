def input_str():
    with open("input", 'r') as f:
        return f.read()


class Point():
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return f'Point(x={self.x}, y={self.y})'

    def __add__(self, o):
        return Point(self.x + o.x, self.y + o.y)

    def __sub__(self, o):
        return Point(self.x - o.x, self.y - o.y)

    def __lt__(self, o):
        return self.x < o.x or (self.x == o.x and self.y < o.y)

    def __eq__(self, o):
        return self.x == o.x and self.y == o.y
    
    def __hash__(self):
        """Overrides the default implementation"""
        return hash(repr(self))

class Grid():
    def __init__(self, inp):
        self._grid = [[x for x in y] for y in inp.splitlines()]
        self.length = len(self._grid)
        self.width = len(self._grid[0])

    def __repr__(self):
        return '\n'.join(''.join(y) for y in self._grid)

    def get(self, x, y=None):
        if not y:
            if not isinstance(x, Point):
                raise TypeError
            y = x.y
            x = x.x
        if x < 0 or y < 0:
            return None
        if x >= self.width or y >= self.length:
            return None
        return self._grid[y][x]

    def set(self, val, x, y=None):
        if not y:
            if not isinstance(x, Point):
                raise TypeError
            y = x.y
            x = x.x
        self._grid[y][x] = val

    def find(self, val):
        for y in range(self.length):
            for x in range(self.width):
                if self._grid[y][x] == val:
                    return Point(x, y)
        raise ValueError
