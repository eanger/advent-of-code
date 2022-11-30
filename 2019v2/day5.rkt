#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (run-intcode (vector 3 0 4 0 99) 123) '(123))
  )

(define (run-intcode prog [input #f])
  (define output '())
  (define (process ip)
    (let-values ([(modes opcode) (quotient/remainder (vector-ref prog ip) 100)])
      (match opcode
        [1 (binary-op + ip)]
        [2 (binary-op * ip)]
        [3 (read-input ip)]
        [4 (write-output ip)]
        [99 (reverse output)]
        [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) (reverse output)])))

  (define (binary-op op ip)
    (let* ([modes (quotient (vector-ref prog ip) 100)]
           [left (vector-ref prog (+ ip 1))]
           [left-mode (remainder modes 10)]
           [left-val (get-val left left-mode)]
           [right (vector-ref prog (+ ip 2))]
           [right-mode (remainder (quotient modes 10) 10)]
           [right-val (get-val right right-mode)]
           [dest (vector-ref prog (+ ip 3))]
           [next-ip (+ ip 4)])
      (vector-set! prog dest (op left-val right-val))
      (process next-ip)))

  (define (read-input ip)
    (let ([addr (vector-ref prog (+ ip 1))])
      (vector-set! prog addr input)
      (process (+ ip 2))))

  (define (write-output ip)
    (let* ([addr (vector-ref prog (+ ip 1))]
           [val (get-val addr (quotient (vector-ref prog ip) 100))])
      (set! output (cons val output))
      (process (+ ip 2))))

  (define (get-val val mode)
    (match (remainder mode 10)
      [0 (vector-ref prog val)]
      [1 val]
      [_ (println "BAD MODE") #f]))

  (process 0))

(define orig-prog (string->intcode (string-trim (file->string "input.day5"))))
(run-intcode orig-prog 1)
