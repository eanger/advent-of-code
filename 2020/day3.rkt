#lang racket

(define input (file->lines "day3.input"))

;; PART 1

(define (make-sled-tree-finder)
  (let ([i 0])
    (lambda (line)
      (let ([idx i])
        (set! i (modulo (+ i 3) (string-length line)))
        (equal? (string-ref line idx) #\#)))))

(define tree-finder (make-sled-tree-finder))
(count tree-finder input)

;; PART 2

(define (make-sled-tree-finder-n n)
  (let ([i 0])
    (lambda (line)
      (let ([idx i])
        (set! i (modulo (+ i n) (string-length line)))
        (equal? (string-ref line idx) #\#)))))

(define tree-finder-1 (make-sled-tree-finder-n 1))
(define tree-finder-3 (make-sled-tree-finder-n 3))
(define tree-finder-5 (make-sled-tree-finder-n 5))
(define tree-finder-7 (make-sled-tree-finder-n 7))
(define tree-finder-1-2 (make-sled-tree-finder-n 1))

(* (count tree-finder-1 input)
   (count tree-finder-3 input)
   (count tree-finder-5 input)
   (count tree-finder-7 input)
   (count tree-finder-1-2 (for/list ([i (length input)] #:when (even? i))
                            (list-ref input i))))
