#lang racket

(module+ test
  (require rackunit)
  (check-equal? (sum-priority-in-both "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw") 157))

(define (sum-priority-in-both rucks-str)
  (apply + (map ruck-priority (string-split rucks-str))))

(define (ruck-priority ruck)
  (let-values ([(left right) (split-at (string->list ruck)
                                       (/ (string-length ruck) 2))])
    (let ([dup (set-first (set-intersect left right))]
          [a-minus-1-val (- (char->integer #\a) 1)])
      (if (char-upper-case? dup)
          (+ 26 (- (char->integer (char-downcase dup)) a-minus-1-val))
          (- (char->integer dup) a-minus-1-val))
    )))

(sum-priority-in-both (file->string "input.day3"))

