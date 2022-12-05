#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (intcode-ref-mode (make-intcode #(203 0)) 0) 203)
  (check-equal? (intcode-ref-mode (make-intcode #(203 1)) 0) 1)
  (check-equal? (intcode-ref-mode (intcode #(203 0 0 0 123) 0 #f #f 4) 0) 123)
  )

(struct intcode (program ip input output base) #:transparent)

(define (make-intcode prog)
  (intcode prog 0 #f #f 0))

(define (intcode-ref vm [offset 0])
  (vector-ref (intcode-program vm) (+ (intcode-ip vm) offset)))

(define (intcode-ref-absolute vm absolute)
  (vector-ref (intcode-program vm) absolute))

(define (intcode-ref-mode vm param-num)
  (let* ([val (intcode-ref vm (add1 param-num))]
         [instr (intcode-ref vm)]
         [all-modes (quotient instr 100)]
         [mode (remainder (quotient all-modes (expt 10 param-num)) 10)])
    (match mode
      [0 (intcode-ref-absolute vm val)]
      [1 val]
      [2 (intcode-ref-absolute vm (+ val (intcode-base vm)))]
      [_ (println "BAD MODE") #f])))

(define (intcode-halted? vm)
  (= 99 (intcode-ref vm)))

(define (binary-op op left right dest vm)
    (let ([res (op left right)]
          [next-ip (+ (intcode-ip vm) 4)])
      (vector-set! (intcode-program vm) dest res)
      (process (struct-copy intcode vm [ip next-ip]))))

(define (read-input addr vm)
  (if (intcode-input vm)
      (begin
        (vector-set! (intcode-program vm) addr (intcode-input vm))
        (process (struct-copy intcode vm
                              [ip (+ (intcode-ip vm) 2)]
                              [input #f])))
      vm))

(define (write-output val vm)
  (process (struct-copy intcode vm
                        [ip (+ (intcode-ip vm) 2)]
                        [output val])))

(define (jump-if predicate cond-val dest-val vm)
  (process (struct-copy intcode vm [ip (if (predicate cond-val)
                                           dest-val
                                           (+ (intcode-ip vm) 3))])))

(define (halt vm)
  (unless (intcode-halted? vm)
    (println "ERROR: VM not halted correctly"))
  ;; (println vm)
  vm)

(define (eq0 x) (= x 0))
(define (neq0 x) (not (eq0 x)))
(define (less-than left right) (if (< left right) 1 0))
(define (is-equal left right) (if (= left right) 1 0))

(define (process vm)
  (let ([opcode (remainder (intcode-ref vm) 100)]
        [p1 (intcode-ref-mode vm 0)]
        [p2 (intcode-ref-mode vm 1)]
        [p3 (intcode-ref-mode vm 2)])
    (match opcode
      [1 (binary-op + p1 p2 p3 vm)]
      [2 (binary-op * p1 p2 p3 vm)]
      [3 (read-input p1 vm)]
      [4 (write-output p1 vm)]
      [5 (jump-if eq0 p1 p2 vm)]
      [6 (jump-if neq0 p1 p2 vm)]
      [7 (binary-op less-than p1 p2 p3 vm)]
      [8 (binary-op is-equal p1 p2 p3 vm)]
      [99 (halt vm)]
      [other (printf "UNIMPLEMENTED OPCODE: ~a\n" other) vm])))

(define orig-prog (string->intcode (string-trim (file->string "input.day9"))))
