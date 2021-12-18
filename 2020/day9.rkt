#lang racket

(define input (file->lines "day9.input"))

;; PART 1
(define-values (preamble lst) (split-at (map string->number input) 25))

(define (invalid-candidate preamble lst)
  ;; if (car lst) is invalid, return it
  ;; otherwise, return (invalid-candidate (rest (append preamble (car list))) (rest lst))
  (define (valid c p)
    (for*/or ([i p]
              [j p]
              #:unless (equal? i j))
      (equal? (+ i j) c)))

  (let ([candidate (car lst)])
    (if (valid candidate preamble)
        (invalid-candidate (rest (append preamble (list candidate))) (rest lst))
        candidate)))
(define invalid-number (invalid-candidate preamble lst))
invalid-number

;; PART 2

;; for i in-range length lst:
;;   cand = take lst i
;;   if sum(cand) == invalid, return (list first cand last cand)
;;   if sum(cand) > invalid, return #f

(displayln (length lst))

(for*/or ([i (in-range (length lst))]
          [j (in-range 0 (- (length lst) i))])
  (let* ([cand (take (drop lst i) j)]
         [sum (apply + cand)])
    (if (equal? sum invalid-number)
        (+ (first cand) (last cand))
        #f)))
