#!/usr/bin/env python3

with open('day19.input', 'r') as inp:
    lines = inp.read()
chunks = lines.strip().split('\n\n')
chunk_lines = [chunk.split('\n')[1:] for chunk in chunks]
scanners = []
for chunk_line in chunk_lines:
    scanner = []
    for line in chunk_line:
        coords = line.split(',')
        scanner.append([int(x) for x in coords])
    scanners.append(scanner)

# Part 1
