#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (cdr (max-visible ".#..#
.....
#####
....#
...##")) 8)
  (check-equal? (cdr (max-visible "......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
")) 33)
  (check-equal? (cdr (max-visible "#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
")) 35)
  (check-equal? (cdr (max-visible ".#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
")) 41)
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
") (cons (point 11 13) 210))
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
                   (* (sgn (point-y p)) (/ pi 2))
                   (atan (/ (point-y p) (point-x p))))])
    (polar r (radians->degrees (cond
                                 [(< (point-x p) 0) (+ theta pi)]
                                 [(< (point-y p) 0) (+ theta (* 2 pi))]
                                 [else theta])))))
(define (to-point p)
  (point (exact-round (* (polar-r p) (cos (degrees->radians (polar-theta p)))))
         (exact-round (* (polar-r p) (sin (degrees->radians (polar-theta p)))))))

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
  (for/fold ([res #f])
            ([vis (in-list (asteroids-visible img-str))])
    (if (and res (> (cdr res) (cdr vis)))
        res
        vis)))

(max-visible (file->string "input.day10"))

; part 2

; order closest asteroids before removing from set
; start with theta=270

(define (make-radius-polar-hash station asteroids)
  (for/fold ([res (make-immutable-hash)])
            ([asteroid (map (lambda (x) (to-polar (point-rel x station)))
                            asteroids)])
    (let ([existing (hash-ref res (polar-theta asteroid) '())])
      (hash-set res (polar-theta asteroid) (cons asteroid existing)))))

(define (remove-n asteroids n)
  ; this method just pulls the first  off the first pair and moves it to the end
  ; asteroids is list of (theta polar ...) where there may be no points
  (let* ([top (car asteroids)]
         [bottom (cdr asteroids)]
         [theta (car top)]
         [points (cdr top)])
    (cond
      [(empty? points) (remove-n bottom n)]
      [(= n 0) (car points)]
      [else (remove-n (append bottom (cons theta (cdr points))) (- n 1))])
  ))

(define (to-ordered-polar-alist hsh)
  (let ([lst (sort (hash->list hsh) < #:key (lambda (x) (if (< (car x) 270)
                                                            (+ (car x) 360)
                                                            (car x))))])
    lst))

(define (part2 img-str n)
  (let* ([station (car (max-visible img-str))]
         [asteroids (remove station (parse-image img-str))])
    (point-rel
     (to-point (remove-n (to-ordered-polar-alist (make-radius-polar-hash station asteroids))
                         n))
     (point-rel (point 0 0) station))))

(let ([res (part2 (file->string "input.day10") 199)])
  (+ (point-y res) (* (point-x res) 100)))
