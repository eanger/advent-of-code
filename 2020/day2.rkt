#lang racket

;; PART 1
(define input (file->lines "day2.input"))

(define (is-valid? line)
  (match-let ([(list _ minimum-str maximum-str char-str password)
               (regexp-match #rx"([0-9]*)-([0-9]*) (.*): (.*)" line)])
    (let* ([char (string-ref char-str 0)]
           [minimum (string->number minimum-str)]
           [maximum (string->number maximum-str)]
           [num (count (lambda (x) (equal? x char)) (string->list password))])
      (and
       (>= num minimum)
       (<= num maximum)))))

(count is-valid? input)

;; PART 2
(define (is-valid-pt2? line)
  (match-let ([(list _ pos-1-str pos-2-str char-str password)
               (regexp-match #rx"([0-9]*)-([0-9]*) (.*): (.*)" line)])
    (let ([char (string-ref char-str 0)]
          [pos-1 (- (string->number pos-1-str) 1)]
          [pos-2 (- (string->number pos-2-str) 1)])
      (xor
       (equal? char (string-ref password pos-1))
       (equal? char (string-ref password pos-2))))))

(count is-valid-pt2? input)
