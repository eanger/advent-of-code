#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (run-intcode (vector 3 0 4 0 99) 123) '(123))
  )

(define (run-intcode prog [input #f])
  (process prog 0 input '()))

(define (process prog ip input output)
  (let ([opcode (remainder (vector-ref prog ip) 100)])
    (match opcode
      [1 (binary-op + prog ip input output)]
      [2 (binary-op * prog ip input output)]
      [3 (read-input prog ip input output)]
      [4 (write-output prog ip input output)]
      [99 (reverse output)]
      [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) (reverse output)])))

(define (binary-op op prog ip input output)
  (let* ([modes (quotient (vector-ref prog ip) 100)]
         [left (vector-ref prog (+ ip 1))]
         [left-mode (remainder modes 10)]
         [left-val (get-val prog left left-mode)]
         [right (vector-ref prog (+ ip 2))]
         [right-mode (remainder (quotient modes 10) 10)]
         [right-val (get-val prog right right-mode)]
         [dest (vector-ref prog (+ ip 3))]
         [next-ip (+ ip 4)])
    (vector-set! prog dest (op left-val right-val))
    (process prog next-ip input output)))

(define (read-input prog ip input output)
  (let ([addr (vector-ref prog (+ ip 1))])
    (vector-set! prog addr input)
    (process prog (+ ip 2) input output)))

(define (write-output prog ip input output)
  (let* ([addr (vector-ref prog (+ ip 1))]
         [val (get-val prog addr (quotient (vector-ref prog ip) 100))])
    (process prog (+ ip 2) input (cons val output))))

(define (get-val prog val mode)
  (match (remainder mode 10)
    [0 (vector-ref prog val)]
    [1 val]
    [_ (println "BAD MODE") #f]))

(define orig-prog (string->intcode (string-trim (file->string "input.day5"))))
(run-intcode orig-prog 1)
