#lang racket

(module+ test
  (require rackunit)
  (check-equal? (count-pair-supersets "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8") 2)
  (check-equal? (count-pair-overlaps "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8") 4))

(define (count-pair-supersets pairs-str)
  (length (filter is-superset? (map parse-pair (string-split pairs-str)))))

(define (is-superset? pair)
  (or (contains? (first pair) (second pair))
      (contains? (second pair) (first pair))))

(define (contains? a b)
  (and
   (<= (first a) (first b))
   (>= (second a) (second b))))

(define (parse-pair pair-str)
  ; returns ((min max) (min max))
  (let ([pair-vals
         (regexp-match #rx"(.*)-(.*),(.*)-(.*)" pair-str)])
    (list (list (string->number (second pair-vals))
                (string->number (third pair-vals)))
          (list (string->number (fourth pair-vals))
                (string->number (fifth pair-vals))))))

(count-pair-supersets (file->string "input.day4"))

(define (count-pair-overlaps pairs-str)
  (length (filter is-overlap? (map parse-pair (string-split pairs-str)))))

(define (is-overlap? pair)
  (let ([l1 (first (first pair))]
        [r1 (second (first pair))]
        [l2 (first (second pair))]
        [r2 (second (second pair))])
    (not (or (< r1 l2)
             (< r2 l1)))))

(count-pair-overlaps (file->string "input.day4"))
