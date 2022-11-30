#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (run-intcode (vector 3 0 4 0 99) 123) '(123)))

(define (run-intcode prog [input #f])
  (define output '())
  (define (process ip)
    (let-values ([(modes opcode) (quotient/remainder (vector-ref prog ip) 100)])
      (match opcode
        [1 (binary-op + ip modes)]
        [2 (binary-op * ip modes)]
        [3 (read-input ip)]
        [4 (write-output ip modes)]
        [5 (jump-if (lambda (x) (not (= x 0))) ip modes)]
        [6 (jump-if (lambda (x) (= x 0)) ip modes)]
        [7 (less-than ip modes)]
        [8 (is-equal ip modes)]
        [99 (reverse output)]
        [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) (reverse output)])))

  (define (binary-op op ip modes)
    (let* ([left-idx (vector-ref prog (+ ip 1))]
           [right-idx (vector-ref prog (+ ip 2))]
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

  (define (jump-if pred ip modes)
    (let* ([cond-idx (vector-ref prog (+ ip 1))]
           [dest-idx (vector-ref prog (+ ip 2))]
           [cond-val (value-by-mode cond-idx modes 0)]
           [dest-val (value-by-mode dest-idx modes 1)])
      (process (if (pred cond-val) dest-val (+ ip 3)))))

  (define (less-than ip modes)
    (let* ([left-idx (vector-ref prog (+ ip 1))]
           [right-idx (vector-ref prog (+ ip 2))]
           [left (value-by-mode left-idx modes 0)]
           [right (value-by-mode right-idx modes 1)]
           [dest (vector-ref prog (+ ip 3))]
           [next-ip (+ ip 4)])
      (vector-set! prog dest (if (< left right) 1 0))
      (process next-ip)))

  (define (is-equal ip modes)
    (let* ([left-idx (vector-ref prog (+ ip 1))]
           [right-idx (vector-ref prog (+ ip 2))]
           [left (value-by-mode left-idx modes 0)]
           [right (value-by-mode right-idx modes 1)]
           [dest (vector-ref prog (+ ip 3))]
           [next-ip (+ ip 4)])
      (vector-set! prog dest (if (= left right) 1 0))
      (process next-ip)))

  (define (value-by-mode val modes param-idx)
    (let-values ([(mode-1 mode-0) (quotient/remainder modes 10)])
      (match (if (equal? param-idx 0) mode-0 mode-1)
        [0 (vector-ref prog val)]
        [1 val]
        [_ (println "BAD MODE") #f])))

  (process 0))

(define orig-prog (string->intcode (string-trim (file->string "input.day5"))))
(run-intcode (vector-copy orig-prog) 1)

(module+ test
  (require rackunit)
  (check-equal? (run-intcode (string->intcode "3,9,8,9,10,9,4,9,99,-1,8") 8) '(1))
  (check-equal? (run-intcode (string->intcode "3,9,8,9,10,9,4,9,99,-1,8") 123) '(0))
  (check-equal? (run-intcode (string->intcode "3,9,7,9,10,9,4,9,99,-1,8") 1) '(1))
  (check-equal? (run-intcode (string->intcode "3,9,7,9,10,9,4,9,99,-1,8") 123) '(0))
  (check-equal? (run-intcode (string->intcode "3,3,1108,-1,8,3,4,3,99") 8) '(1))
  (check-equal? (run-intcode (string->intcode "3,3,1108,-1,8,3,4,3,99") 123) '(0))
  (check-equal? (run-intcode (string->intcode "3,3,1107,-1,8,3,4,3,99") 1) '(1))
  (check-equal? (run-intcode (string->intcode "3,3,1107,-1,8,3,4,3,99") 123) '(0))
  (check-equal? (run-intcode (string->intcode "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9") 0) '(0))
  (check-equal? (run-intcode (string->intcode "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9") 123) '(1))
  (check-equal? (run-intcode (string->intcode "3,3,1105,-1,9,1101,0,0,12,4,12,99,1") 0) '(0))
  (check-equal? (run-intcode (string->intcode "3,3,1105,-1,9,1101,0,0,12,4,12,99,1") 123) '(1))
  (check-equal? (run-intcode (string->intcode "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99") 1) '(999))
  (check-equal? (run-intcode (string->intcode "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99") 8) '(1000))
  (check-equal? (run-intcode (string->intcode "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99") 123) '(1001))
  )

(run-intcode (vector-copy orig-prog) 5)
