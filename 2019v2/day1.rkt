#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (fuel-required 12) 2)
  (check-equal? (fuel-required 14) 2)
  (check-equal? (fuel-required 1969) 654)
  (check-equal? (fuel-required 100756) 33583))

(define (fuel-required mass)
  (- (floor (/ mass 3)) 2))

(accumulate fuel-required "input.day1")

(module+ test
  (check-equal? (fuel-required-p2 14) 2)
  (check-equal? (fuel-required-p2 1969) 966)
  (check-equal? (fuel-required-p2 100756) 50346))

(define (fuel-required-p2 mass)
  (let ([this-fuel (fuel-required mass)])
    (if (<= this-fuel 0)
        0
        (+ this-fuel (fuel-required-p2 this-fuel)))))

(accumulate fuel-required-p2 "input.day1")
