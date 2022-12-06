#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (max-visible ".#..#
.....
#####
....#
...##") 8)
  (check-equal? (max-visible "......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
") 33)
  (check-equal? (max-visible "#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
") 35)
  (check-equal? (max-visible ".#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
") 41)
  (check-equal? (max-visible ".#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
") 210)
)

; 1. parse input for list of asteroid locations
; 2. evaluate each location given all other locations
; 3. eval: iterate through all other asteroids and walk backwards to this candidate and pass if it collides with another in list. return count of visible
; 4. return (location, count) for max count


(define test ".#..#
.....
#####
....#
...##")

(struct point (x y) #:transparent)
(define (point-normalize p origin)
  (let* ([diff-x (- (point-x p) (point-x origin))]
         [diff-y (- (point-y p) (point-y origin))]
         [divisor (gcd diff-x diff-y)])
    (cons divisor (point (/ diff-x divisor) (/ diff-y divisor)))))

(define (parse-image img-str)
  (for/list ([line (string-split img-str "\n")]
             [y (in-naturals)]
             #:when #t
             [char (in-string line)]
             [x (in-naturals)]
             #:when (char=? char #\#))
    (point x y)))

(define (asteroids-visible img-str)
  (let ([asteroids (parse-image img-str)])
    (for/list ([asteroid (in-list asteroids)])
      (cons asteroid (eval-asteroid asteroid asteroids)))))

(define (eval-asteroid candidate asteroids)
  (set-count
   (for/set ([asteroid (in-list asteroids)]
              #:unless (equal? asteroid candidate))
     (cdr
      (point-normalize asteroid candidate))
     )))

(define (max-visible img-str)
  (apply max (map cdr (asteroids-visible img-str))))

(max-visible (file->string "input.day10"))
