#lang racket

(provide (all-defined-out))

(define (accumulate proc filename)
  (for/fold ([acc 0])
            ([elem (file->numbers filename)])
    (+ acc (proc elem))))

(define (file->numbers filename)
  (map string->number (file->lines filename)))

(define (string->intcode str)
  (list->vector (map string->number (string-split str ","))))

(define (string->vector str)
  (list->vector (map string->number (string-split str ","))))
