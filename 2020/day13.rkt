#lang racket

(define input (file->lines "day13.input"))

;; PART 1

(define earliest (string->number (car input)))
(define bus-list
  (filter-map (lambda (x)
                (if (equal? x "x")
                    #f
                    (string->number x)))
              (string-split (second input) ",")))

(define bus-waits (map (lambda (x) (cons (- x (modulo earliest x)) x)) bus-list))
(define bus-waits-sorted (sort bus-waits < #:key car))
(* (car (car bus-waits-sorted)) (cdr (car bus-waits-sorted)))

;; PART 2

#|

17,x,13,19 -> 3417

17n = 13m+2 = 19p+3

17n = t
13m = t + 2

multiples of 17

for (i = 0; ; i++)
  if i*17+2 mod 13 == 0:
    i is a candidate

|#

(define timetable (string-split (second input) ","))

(define routes (filter-map (lambda (y z)
                             (if (equal? y "x")
                                 #f
                                 (cons (string->number y)
                                       z)))
                           timetable
                           (stream->list (stream-take (in-naturals) (length timetable)))))

;; (get-start routes)
;; (get-start '((67 . 0) (7 . 1) (59 . 2) (61 . 3)))

#|

7 13 59 31 19
start, inc, target, offset
0, 7, 13, 1 -> 77
77, (7*13), 59, 4 -> 350

|#

(define (get-start start inc lst)
  (if (empty? lst)
      start
      (let ([target (car (car lst))]
            [offset (cdr (car lst))])
        (for/or ([i (in-naturals)])
          (let ([t (+ start (* i inc))])
            (if (equal? 0 (modulo (+ t offset) target))
                (get-start t (* inc target) (cdr lst))
                #f))))))

(get-start (cdr (car routes)) (car (car routes)) (cdr routes))
