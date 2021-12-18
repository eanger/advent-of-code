#lang racket

(define input (file->lines "day8.input"))

;; PART 1
;; keep set of visited instructions
;; keep accumulator

(define program (list->vector
                 (map (compose1 (lambda (x) (list (car x) (string->number (cadr x))))
                                string-split)
                      input)))

(define (get-last-acc program)
  (define accumulator 0)
  (define visited (mutable-set))
  (define (operate pc)
    (if (>= pc (vector-length program))
        (list accumulator 'normal)
        (let* ([ins (vector-ref program pc)]
               [op (car ins)]
               [num (cadr ins)])
          (cond [(set-member? visited pc) (list accumulator 'inf)]
                [else
                 (set-add! visited pc)
                 (match op
                   ["nop" (operate (+ pc 1))]
                   ["jmp" (operate (+ pc num))]
                   ["acc" (set! accumulator (+ accumulator num))
                          (operate (+ pc 1))])]))))
    (operate 0))
(get-last-acc program)

;; PART 2

(define all-accs
  (for/list ([i (in-range (vector-length program))]
             #:unless (equal? "acc" (car (vector-ref program i))))
    (let ([prog (vector-copy program)]
          [op (vector-ref program i)])
      (match (car op)
        ["nop" (vector-set! prog i (list "jmp" (cadr op)))
               (get-last-acc prog)]
        ["jmp" (vector-set! prog i (list "nop" (cadr op)))
               (get-last-acc prog)]))))
(filter (lambda (x) (equal? (cadr x) 'normal)) all-accs)
