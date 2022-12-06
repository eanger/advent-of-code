#lang racket
(require "utils.rkt")

(define debug #f)
(define printf (if debug printf void))

(module+ test
  (require rackunit)
  (check-equal? (intcode-ref-mode (make-intcode #(203 0)) 0 #t) 203)
  (check-equal? (intcode-ref-mode (make-intcode #(203 1)) 0 #t) 1)
  (check-equal? (intcode-ref-mode (intcode #(203 0 0 0 123) 0 #f #f 4) 0 #t) 123)
  (check-equal? (intcode-output (process (make-intcode #(104 1125899906842624 99)))) '(1125899906842624))
  (check-equal? (reverse (intcode-output (process (make-intcode #(109 1 204 -1 1001 100 1 100 1008 100 16 101 1006 101 0 99))))) '(109 1 204 -1 1001 100 1 100 1008 100 16 101 1006 101 0 99))
  )

(struct intcode ([program #:mutable] ip input output base) #:transparent)

(define (make-intcode prog [input #f])
  (intcode (vector-copy prog) 0 input '() 0))

(define (intcode-ref vm [offset 0])
  (intcode-ref-absolute vm (+ (intcode-ip vm) offset)))

(define (intcode-program-write vm addr val)
  (let ([_ (intcode-ref-absolute vm addr)])
    (vector-set! (intcode-program vm) addr val)))

(define (intcode-ref-absolute vm absolute)
  (when (>= absolute (vector-length (intcode-program vm)))
    (let ([new-prog (make-vector (add1 absolute))])
      (vector-copy! new-prog 0 (intcode-program vm))
      (set-intcode-program! vm new-prog)))
  (vector-ref (intcode-program vm) absolute))

(define (intcode-ref-mode vm param-num deref?)
  (let* ([val (intcode-ref vm (add1 param-num))]
         [instr (intcode-ref vm)]
         [all-modes (quotient instr 100)]
         [mode (remainder (quotient all-modes (expt 10 param-num)) 10)])
    (printf "~a ~a ~a ~a ~a\n" val instr all-modes mode (intcode-base vm))
    (match mode
      [0 (if deref? (intcode-ref-absolute vm val) val)]
      [1 val]
      [2 (let ([rel-val (+ val (intcode-base vm))])
           (if deref? (intcode-ref-absolute vm rel-val) rel-val))]
      [_ (eprintf "BAD MODE\n") #f])))

(define (intcode-halted? vm)
  (= 99 (intcode-ref vm)))

(define (binary-op op vm)
  (let* ([left (intcode-ref-mode vm 0 #t)]
         [right (intcode-ref-mode vm 1 #t)]
         [dest (intcode-ref-mode vm 2 #f)]
         [res (op left right)]
         [next-ip (+ (intcode-ip vm) 4)])
    (printf "~a ~a ~a\n" left right dest)
    (intcode-program-write vm dest res)
    (process (struct-copy intcode vm [ip next-ip]))))

(define (read-input vm)
  (printf "BEFORE input: ~a base: ~a\n" (intcode-input vm) (intcode-base vm))
  (if (intcode-input vm)
      (let ([addr (intcode-ref-mode vm 0 #f)])
        (printf "input: ~a addr: ~a base: ~a\n" (intcode-input vm) addr (intcode-base vm))
        (intcode-program-write vm addr (intcode-input vm))
        (process (struct-copy intcode vm
                              [ip (+ (intcode-ip vm) 2)]
                              [input #f])))
      vm))

(define (write-output vm)
  (let ([val (intcode-ref-mode vm 0 #t)])
    (process (struct-copy intcode vm
                          [ip (+ (intcode-ip vm) 2)]
                          [output (cons val (intcode-output vm))]))))

(define (jump-if predicate vm)
  (let ([cond-val (intcode-ref-mode vm 0 #t)]
        [dest-val (intcode-ref-mode vm 1 #t)])
    (printf "cond: ~a dest: ~a\n" cond-val dest-val)
    (process (struct-copy intcode vm [ip (if (predicate cond-val)
                                             dest-val
                                             (+ (intcode-ip vm) 3))]))))

(define (rel-base vm)
  (let* ([increment (intcode-ref-mode vm 0 #t)]
         [newbase (+ (intcode-base vm) increment)])
    (printf "base: ~a inc: ~a newbase: ~a\n" (intcode-base vm) increment newbase)
    (process (struct-copy intcode vm
                          [ip (+ (intcode-ip vm) 2)]
                          [base newbase]))))

(define (halt vm)
  (unless (intcode-halted? vm)
    (eprintf "ERROR: VM not halted correctly\n"))
  vm)

(define (eq0 x) (= x 0))
(define (neq0 x) (not (eq0 x)))
(define (less-than left right) (if (< left right) 1 0))
(define (is-equal left right) (if (= left right) 1 0))

(define decoder #hash((1 . "add")
                      (2 . "mul")
                      (3 . "read")
                      (4 . "write")
                      (5 . "jump-neq0")
                      (6 . "jump-eq0")
                      (7 . "less-than?")
                      (8 . "is-equal?")
                      (9 . "rel-base")
                      (99 . "halt")))

(define (process vm)
  (let* ([opcode (remainder (intcode-ref vm) 100)]
         [op (hash-ref decoder opcode)])
    (printf "ip: ~a op: ~a\n" (intcode-ip vm) op)
    (match opcode
      [1 (binary-op + vm)]
      [2 (binary-op * vm)]
      [3 (read-input vm)]
      [4 (write-output vm)]
      [5 (jump-if neq0 vm)]
      [6 (jump-if eq0 vm)]
      [7 (binary-op less-than vm)]
      [8 (binary-op is-equal vm)]
      [9 (rel-base vm)]
      [99 (halt vm)]
      [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) vm])))

(define orig-prog (string->vector (string-trim (file->string "input.day9"))))
(intcode-output (process (make-intcode orig-prog 1)))
