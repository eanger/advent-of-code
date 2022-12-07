#lang racket

(module+ test
  (require rackunit)
  (check-equal? (sum-priority-in-both "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw") 157)
  (check-equal? (sum-priority-groups "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw") 70))

(define (sum-priority-in-both rucks-str)
  (apply + (map ruck-priority (string-split rucks-str))))

(define (ruck-priority ruck)
  (let-values ([(left right) (split-at (string->list ruck)
                                       (/ (string-length ruck) 2))])
    (to-priority (set-first (set-intersect left right)))))

(define (to-priority letter)
  (let ([a-minus-1-val (- (char->integer #\a) 1)])
    (if (char-upper-case? letter)
        (+ 26 (- (char->integer (char-downcase letter)) a-minus-1-val))
        (- (char->integer letter) a-minus-1-val))))

(sum-priority-in-both (file->string "input.day3"))

(define (sum-priority-groups rucks-str)
  (define (get-sum rucks)
    (if (empty? rucks)
        0
        (let-values ([(group others) (split-at rucks 3)])
          (+ (group-priority group) (get-sum others)))))
  (get-sum (string-split rucks-str)))

(define (group-priority group)
  (to-priority (set-first (apply set-intersect (map string->list group)))))

(sum-priority-groups (file->string "input.day3"))
