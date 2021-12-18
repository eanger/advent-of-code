#!/usr/bin/env python3

with open('day16.input', 'r') as inp:
    lines = inp.readlines()
lines = [line.strip() for line in lines]

# Part 1
HEX = {'0': '0000',
       '1': '0001',
       '2': '0010',
       '3': '0011',
       '4': '0100',
       '5': '0101',
       '6': '0110',
       '7': '0111',
       '8': '1000',
       '9': '1001',
       'A': '1010',
       'B': '1011',
       'C': '1100',
       'D': '1101',
       'E': '1110',
       'F': '1111'}

bits = ''.join(HEX[x] for x in lines[0])


class Packet:
    def __init__(self, raw):
        self.version = int(raw[:3], 2)
        self.typeid = int(raw[3:6], 2)
        self.subpackets = []
        self.data = None
        if self.typeid == 4:
            new_raw = self.parse_literal(raw[6:])
        else:
            new_raw = self.parse_operator(raw[6:])
        self.length = len(raw) - len(new_raw)

    def __repr__(self):
        return f"(Packet ver {self.version} type {self.typeid} len {self.length} data {self.data} subs {self.subpackets})"

    def eval(self):
        if self.typeid == 0:
            return sum(sub.eval() for sub in self.subpackets)
        elif self.typeid == 1:
            res = 1
            for sub in self.subpackets:
                res *= sub.eval()
            return res
        elif self.typeid == 2:
            return min(sub.eval() for sub in self.subpackets)
        elif self.typeid == 3:
            return max(sub.eval() for sub in self.subpackets)
        elif self.typeid == 4:
            return self.data
        elif self.typeid == 5:
            p1 = self.subpackets[0].eval()
            p2 = self.subpackets[1].eval()
            return 1 if p1 > p2 else 0
        elif self.typeid == 6:
            p1 = self.subpackets[0].eval()
            p2 = self.subpackets[1].eval()
            return 1 if p1 < p2 else 0
        else:  # typeid 7
            p1 = self.subpackets[0].eval()
            p2 = self.subpackets[1].eval()
            return 1 if p1 == p2 else 0

    def parse_literal(self, raw):
        literal_str = ''
        while True:
            word = raw[:5]
            raw = raw[5:]
            literal_str += word[1:]
            if word[0] == '0':
                break
        self.data = int(literal_str, 2)
        return raw

    def parse_operator(self, raw):
        length_typeid = raw[0]
        if length_typeid == '0':
            total_len = int(raw[1:16], 2)
            raw = raw[16:]
            bits_left = total_len
            while bits_left != 0:
                child = Packet(raw)
                self.subpackets.append(child)
                raw = raw[child.length:]
                bits_left -= child.length
            # raw = raw[total_len:]
        else:
            total_subs = int(raw[1:12], 2)
            raw = raw[12:]
            for _ in range(total_subs):
                child = Packet(raw)
                self.subpackets.append(child)
                raw = raw[child.length:]
        return raw

    def versions(self):
        res = [self.version]
        for sub in self.subpackets:
            res += sub.versions()
        return res


# x = Packet('110100101111111000101000') # literal
# x = Packet('11101110000000001101010000001100100000100011000001100000') # num sub packets
# x = Packet('00111000000000000110111101000101001010010001001000000000') # num bits in sub packets
# x = Packet(''.join(HEX[x] for x in 'A0016C880162017C3686B18A3D4780'))

head = Packet(bits)
print(sum(head.versions()))

# Part 2
print(head.eval())
