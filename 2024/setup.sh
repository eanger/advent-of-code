#!/bin/bash

for x in `seq 1 25`
do
    mkdir -p $x
    cp -n template.py $x/main.py
    ln -s $PWD/util.py $x/util.py
done

curl --compressed -H 'Cookie: session=53616c7465645f5f723ffae7e10b15f29e3014402ae81f768330d6d22f51bb92d50028cb1baf13d170ba06139a2eaa3124dd2393c18a88336b167f21dfba9afc' \
     --parallel -parallel-immediate \
     "https://adventofcode.com/2024/day/1/input" -o 1/input \
     "https://adventofcode.com/2024/day/2/input" -o 2/input \
     "https://adventofcode.com/2024/day/3/input" -o 3/input \
     "https://adventofcode.com/2024/day/4/input" -o 4/input \
     "https://adventofcode.com/2024/day/5/input" -o 5/input \
     "https://adventofcode.com/2024/day/6/input" -o 6/input \
     "https://adventofcode.com/2024/day/7/input" -o 7/input \
     "https://adventofcode.com/2024/day/8/input" -o 8/input \
     "https://adventofcode.com/2024/day/9/input" -o 9/input \
     "https://adventofcode.com/2024/day/10/input" -o 10/input \
     "https://adventofcode.com/2024/day/11/input" -o 11/input \
     "https://adventofcode.com/2024/day/12/input" -o 12/input \
     "https://adventofcode.com/2024/day/13/input" -o 13/input \
     "https://adventofcode.com/2024/day/14/input" -o 14/input \
     "https://adventofcode.com/2024/day/15/input" -o 15/input \
     "https://adventofcode.com/2024/day/16/input" -o 16/input \
     "https://adventofcode.com/2024/day/17/input" -o 17/input \
     "https://adventofcode.com/2024/day/18/input" -o 18/input \
     "https://adventofcode.com/2024/day/19/input" -o 19/input \
     "https://adventofcode.com/2024/day/20/input" -o 20/input \
     "https://adventofcode.com/2024/day/21/input" -o 21/input \
     "https://adventofcode.com/2024/day/22/input" -o 22/input \
     "https://adventofcode.com/2024/day/23/input" -o 23/input \
     "https://adventofcode.com/2024/day/24/input" -o 24/input \
     "https://adventofcode.com/2024/day/25/input" -o 25/input 2>/dev/null
