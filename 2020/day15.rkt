#lang racket

(require racket/generator)

;; (define input '(1 3 2))
(define input '(16 12 1 0 15 7 11))

;; PART 1

;; (sequence-ref (in-producer process-next (void)) 9)

(define initial
  (for/hash ([(x i) (in-indexed input)])
    (values x i)))

;; initial

(define (mygen)
  (generator ()
             (let proc ([state initial]
                        [cur (last input)]
                        [idx (- (hash-count initial) 1)])
               (let ([next-val (- idx (hash-ref state cur idx))])
                 (yield next-val)
                 (proc (hash-set state cur idx) next-val (+ 1 idx))))))

(define (get-nth n)
  (sequence-ref (in-producer (mygen) (void))
                (- n (length input) 1)))

(get-nth 2020)
(get-nth 30000000)
