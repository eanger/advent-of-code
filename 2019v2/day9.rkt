#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  )

(struct intcode (program ip input output) #:transparent)

(define (intcode-ref vm [offset 0])
  (vector-ref (intcode-program vm) (+ (intcode-ip vm) offset)))
(define (intcode-ref-absolute vm absolute)
  (vector-ref (intcode-program vm) absolute))

(define (intcode-halted? vm)
  (= 99 (intcode-ref vm)))

(define (binary-op op vm modes)
    (let* ([left-idx (intcode-ref vm 1)]
           [right-idx (intcode-ref vm 2)]
           [left (value-by-mode vm left-idx modes 0)]
           [right (value-by-mode vm right-idx modes 1)]
           [dest (intcode-ref vm 3)]
           [next-ip (+ (intcode-ip vm) 4)])
      (vector-set! (intcode-program vm) dest (op left right))
      (process (struct-copy intcode vm [ip next-ip]))))

(define (read-input vm)
  (if (intcode-input vm)
      (let ([addr (intcode-ref vm 1)])
        (vector-set! (intcode-program vm) addr (intcode-input vm))
        (process (struct-copy intcode vm
                              [ip (+ (intcode-ip vm) 2)]
                              [input #f])))
      vm))

(define (write-output vm modes)
  (let* ([addr (intcode-ref vm 1)]
         [val (value-by-mode vm addr modes 0)])
    (process (struct-copy intcode vm
                          [ip (+ (intcode-ip vm) 2)]
                          [output val]))))

(define (jump-if pred vm modes)
  (let* ([cond-idx (intcode-ref vm 1)]
         [dest-idx (intcode-ref vm 2)]
         [cond-val (value-by-mode vm cond-idx modes 0)]
         [dest-val (value-by-mode vm dest-idx modes 1)])
    (process (struct-copy intcode vm [ip (if (pred cond-val)
                                             dest-val
                                             (+ (intcode-ip vm) 3))]))))

(define (less-than vm modes)
  (let* ([left-idx (intcode-ref vm 1)]
         [right-idx (intcode-ref vm 2)]
         [left (value-by-mode vm left-idx modes 0)]
         [right (value-by-mode vm right-idx modes 1)]
         [dest (intcode-ref vm 3)]
         [next-ip (+ (intcode-ip vm) 4)])
    (vector-set! (intcode-program vm) dest (if (< left right) 1 0))
    (process (struct-copy intcode vm [ip next-ip]))))

(define (is-equal vm modes)
  (let* ([left-idx (intcode-ref vm 1)]
         [right-idx (intcode-ref vm 2)]
         [left (value-by-mode vm left-idx modes 0)]
         [right (value-by-mode vm right-idx modes 1)]
         [dest (intcode-ref vm 3)]
         [next-ip (+ (intcode-ip vm) 4)])
    (vector-set! (intcode-program vm) dest (if (= left right) 1 0))
    (process (struct-copy intcode vm [ip next-ip]))))

(define (halt vm)
  (unless (intcode-halted? vm)
    (println "ERROR: VM not halted correctly"))
  ;; (println vm)
  vm)

(define (value-by-mode vm val modes param-idx)
  (let-values ([(mode-1 mode-0) (quotient/remainder modes 10)])
    (match (if (equal? param-idx 0) mode-0 mode-1)
      [0 (intcode-ref-absolute vm val)]
      [1 val]
      [_ (println "BAD MODE") #f])))

; input (input output) ... terminate
; return an optional output on input.
(define (process vm)
  (let-values ([(modes opcode) (quotient/remainder (intcode-ref vm) 100)])
    (match opcode
      [1 (binary-op + vm modes)]
      [2 (binary-op * vm modes)]
      [3 (read-input vm)]
      [4 (write-output vm modes)]
      [5 (jump-if (lambda (x) (not (= x 0))) vm modes)]
      [6 (jump-if (lambda (x) (= x 0)) vm modes)]
      [7 (less-than vm modes)]
      [8 (is-equal vm modes)]
      [99 (halt vm)]
      [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) vm])))

(define orig-prog (string->intcode (string-trim (file->string "input.day9"))))
