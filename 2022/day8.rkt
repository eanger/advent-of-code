#lang racket

(module+ test
  (require rackunit)
  (check-equal? (count-visible "30373
25512
65332
33549
35390") 21))

(define test "30373
25512
65332
33549
35390")

; for each direction, visible if (empty? (takef others (lambda (x) (> x cur))))
; foldl: proc init lst, proc (combined x)
; visible if everything is lower
; invisible if takef
; (takef others (lambda (x) (> x cur)))
(define (visible-over? cur others)
  (empty? (filter (lambda (x) (>= x cur)) others)))

(define (to-rows-and-cols str)
  (let ([rows (map line-to-heights (string-split str "\n"))])
    (values rows (apply map list rows))))

(define (line-to-heights str)
  (map (compose string->number string) (string->list str)))

(define (is-visible? cur left right)
  (or (visible-over? cur left)
      (visible-over? cur right)))

; for each location, (visible-over? location (take (idx - 1) row) or (visible-over? location (drop (idx + 1) row)
(define (get-all-visible left right)
  ; car right is candidate
  (if (empty? right)
      '()
      (let ([cur (car right)]
            [others (cdr right)])
        (cons
         (is-visible? cur left others)
         (get-all-visible (cons cur left) others)))))


#|
30373
25512
65332
33549
35390
|#

(define (count-visible str)
  (let-values ([(r c) (to-rows-and-cols str)])
    (let* ([vis-horiz (map (lambda (x) (get-all-visible '() x)) r)]
           [vis-vert-T (map (lambda (x) (get-all-visible '() x)) c)]
           [vis-vert (apply map list vis-vert-T)])
      (for/sum ([h-line (in-list vis-horiz)]
                [v-line (in-list vis-vert)]
                #:when #t
                [h (in-list h-line)]
                [v (in-list v-line)])
        (if (or h v)
            1
            0)))))

(count-visible (file->string "input.day8"))
