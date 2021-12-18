#lang racket

(require memoize)

(define input (file->lines "day10.input"))

;; PART 1

(define joltages (sort (map string->number input) <))
(define (sub-prior lst)
  (if (equal? 1 (length lst))
      '(3)
      (cons (- (second lst) (first lst)) (sub-prior (rest lst)))))
(define diffs (sub-prior (cons 0 joltages)))
(* (count (lambda (x) (equal? x 1)) diffs)
   (count (lambda (x) (equal? x 3)) diffs))

;; PART 2

(define/memo (do-count from lst)
  (let ([diff (- (car lst) from)]
        [len (length lst)])
    (cond [(> diff 3) 0]
          [(equal? len 1) 1]
          [(equal? len 2) (do-count (car lst) (cdr lst))]
          [(equal? len 3) (+ (do-count (car lst) (cdr lst))
                             (do-count (car lst) (cddr lst)))]
          [else (+
                 (do-count (car lst) (cdr lst))
                 (do-count (car lst) (cddr lst))
                 (do-count (car lst) (cdddr lst)))])))


(define (get-combos lst)
  (+ (do-count 0 lst)
     (do-count 0 (cdr lst))
     (do-count 0 (cddr lst))))
(define test (sort '(28 33 18 42 31 14 46 20 48 47 24 23 49 45 19 38 39 11 1 32 25 35 8 17 7 9 4 2 34 10 3) < ))
(unless (equal? (get-combos test ) 19208)
  (error "INCORRECT"))

(get-combos joltages)
