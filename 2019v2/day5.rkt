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
        [1 (binary-op + ip modes)]
        [2 (binary-op * ip modes)]
        [3 (read-input ip)]
        [4 (write-output ip modes)]
        [99 (reverse output)]
        [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) (reverse output)])))

  (define (binary-op op ip modes)
    (let* ([left-idx (vector-ref prog (+ ip 1))]
           [right-idx (vector-ref prog (+ ip 1))]
           [left (value-by-mode left-idx modes 0)]
           [right (value-by-mode right-idx modes 1)]
           [dest (vector-ref prog (+ ip 3))]
           [next-ip (+ ip 4)])
      (vector-set! prog dest (op left right))
      (process next-ip)))

  (define (read-input ip)
    (let ([addr (vector-ref prog (+ ip 1))])
      (vector-set! prog addr input)
      (process (+ ip 2))))

  (define (write-output ip modes)
    (let* ([addr (vector-ref prog (+ ip 1))]
           [val (value-by-mode addr modes 0)])
      (set! output (cons val output))
      (process (+ ip 2))))

  (define (value-by-mode val modes param-idx)
    (let-values ([(mode-1 mode-0) (quotient/remainder modes 10)])
      (match (if (equal? param-idx 0) mode-0 mode-1)
        [0 (vector-ref prog val)]
        [1 val]
        [_ (println "BAD MODE") #f])))

  (process 0))

(define orig-prog (string->intcode (string-trim (file->string "input.day5"))))
(run-intcode orig-prog 1)
