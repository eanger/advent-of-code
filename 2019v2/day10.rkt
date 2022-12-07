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

(struct polar (r theta) #:transparent)

(define (to-polar p)
  (let ([r (sqrt (+ (sqr (point-x p))
                    (sqr (point-y p))))]
        [theta (if (= (point-x p) 0)
                   (/ pi 2)
                   (atan (/ (point-y p) (point-x p))))])
    (polar r (radians->degrees (cond
                                 [(< (point-x p) 0) (+ theta pi)]
                                 [(< (point-y p) 0) (+ theta (* 2 pi))]
                                 [else theta])))))

(define (point-rel p origin)
  (point (- (point-x p) (point-x origin))
         (- (point-y p) (point-y origin))))

(define (parse-image img-str)
  (for/list ([line (string-split img-str "\n")]
             [y (in-naturals)]
             #:when #t
             [char (in-string line)]
             [x (in-naturals)]
             #:when (char=? char #\#))
    (point x y)))

(define (eval-asteroid candidate asteroids)
 (set-count (list->set
             (map polar-theta
                  (map (lambda (x) (to-polar (point-rel x candidate))) asteroids)))))

(define (asteroids-visible img-str)
  (let ([asteroids (parse-image img-str)])
    (for/list ([asteroid (in-list asteroids)])
      (cons asteroid (eval-asteroid asteroid (remove asteroid asteroids))))))

(define (max-visible img-str)
  (apply max (map cdr (asteroids-visible img-str))))

(max-visible (file->string "input.day10"))

; part 2

; order closest asteroids before removing from set
