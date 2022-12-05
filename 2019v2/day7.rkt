#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (run5-linear (string->intcode
                              "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0")
                             (list 4 3 2 1 0))
                43210)
  (check-equal? (run5-linear (string->intcode
                              "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0")
                             (list 0 1 2 3 4))
                54321)
  (check-equal? (run5-linear (string->intcode
                              "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0")
                             (list 1 0 4 3 2))
                65210)
  (check-equal? (max-thrust-p1 (string->intcode
                                "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"))
                43210)
  (check-equal? (max-thrust-p1 (string->intcode
                              "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"))
                54321)
  (check-equal? (max-thrust-p1 (string->intcode
                              "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"))
                65210)
  )

(struct intcode (program ip input output) #:transparent)

(define (vm-ref vm [offset 0])
  (vector-ref (intcode-program vm) (+ (intcode-ip vm) offset)))
(define (vm-ref-absolute vm absolute)
  (vector-ref (intcode-program vm) absolute))

(define (vm-halted? vm)
  (= 99 (vm-ref vm)))

(define (binary-op op vm modes)
    (let* ([left-idx (vm-ref vm 1)]
           [right-idx (vm-ref vm 2)]
           [left (value-by-mode vm left-idx modes 0)]
           [right (value-by-mode vm right-idx modes 1)]
           [dest (vm-ref vm 3)]
           [next-ip (+ (intcode-ip vm) 4)])
      (vector-set! (intcode-program vm) dest (op left right))
      (process (struct-copy intcode vm [ip next-ip]))))

(define (read-input vm)
  (if (intcode-input vm)
      (let ([addr (vm-ref vm 1)])
        (vector-set! (intcode-program vm) addr (intcode-input vm))
        (process (struct-copy intcode vm
                              [ip (+ (intcode-ip vm) 2)]
                              [input #f])))
      vm))

(define (write-output vm modes)
  (let* ([addr (vm-ref vm 1)]
         [val (value-by-mode vm addr modes 0)])
    (process (struct-copy intcode vm
                          [ip (+ (intcode-ip vm) 2)]
                          [output val]))))

(define (jump-if pred vm modes)
  (let* ([cond-idx (vm-ref vm 1)]
         [dest-idx (vm-ref vm 2)]
         [cond-val (value-by-mode vm cond-idx modes 0)]
         [dest-val (value-by-mode vm dest-idx modes 1)])
    (process (struct-copy intcode vm [ip (if (pred cond-val)
                                             dest-val
                                             (+ (intcode-ip vm) 3))]))))

(define (less-than vm modes)
  (let* ([left-idx (vm-ref vm 1)]
         [right-idx (vm-ref vm 2)]
         [left (value-by-mode vm left-idx modes 0)]
         [right (value-by-mode vm right-idx modes 1)]
         [dest (vm-ref vm 3)]
         [next-ip (+ (intcode-ip vm) 4)])
    (vector-set! (intcode-program vm) dest (if (< left right) 1 0))
    (process (struct-copy intcode vm [ip next-ip]))))

(define (is-equal vm modes)
  (let* ([left-idx (vm-ref vm 1)]
         [right-idx (vm-ref vm 2)]
         [left (value-by-mode vm left-idx modes 0)]
         [right (value-by-mode vm right-idx modes 1)]
         [dest (vm-ref vm 3)]
         [next-ip (+ (intcode-ip vm) 4)])
    (vector-set! (intcode-program vm) dest (if (= left right) 1 0))
    (process (struct-copy intcode vm [ip next-ip]))))

(define (halt vm)
  (unless (vm-halted? vm)
    (println "ERROR: VM not halted correctly"))
  ;; (println vm)
  vm)

(define (value-by-mode vm val modes param-idx)
  (let-values ([(mode-1 mode-0) (quotient/remainder modes 10)])
    (match (if (equal? param-idx 0) mode-0 mode-1)
      [0 (vm-ref-absolute vm val)]
      [1 val]
      [_ (println "BAD MODE") #f])))

; input (input output) ... terminate
; return an optional output on input.
(define (process vm)
  (let-values ([(modes opcode) (quotient/remainder (vm-ref vm) 100)])
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

(define orig-prog (string->intcode (string-trim (file->string "input.day7"))))

(define amp1 (intcode (vector-copy orig-prog) 0 0 #f))
(define amp2 (intcode (vector-copy orig-prog) 0 1 #f))
(define amp3 (intcode (vector-copy orig-prog) 0 2 #f))
(define amp4 (intcode (vector-copy orig-prog) 0 3 #f))
(define amp5 (intcode (vector-copy orig-prog) 0 4 #f))
(define (run5-linear prog permute)
  (let* (
         [amp1 (intcode (vector-copy prog) 0 (first permute) #f)]
         [amp2 (intcode (vector-copy prog) 0 (second permute) #f)]
         [amp3 (intcode (vector-copy prog) 0 (third permute) #f)]
         [amp4 (intcode (vector-copy prog) 0 (fourth permute) #f)]
         [amp5 (intcode (vector-copy prog) 0 (fifth permute) #f)]
         [new1 (process amp1)]
         [new2 (process amp2)]
         [new3 (process amp3)]
         [new4 (process amp4)]
         [new5 (process amp5)]
         [end1 (process (struct-copy intcode new1 [input 0]))]
         [end2 (process (struct-copy intcode new2 [input (intcode-output end1)]))]
         [end3 (process (struct-copy intcode new3 [input (intcode-output end2)]))]
         [end4 (process (struct-copy intcode new4 [input (intcode-output end3)]))]
         [end5 (process (struct-copy intcode new5 [input (intcode-output end4)]))]
         )
    (intcode-output end5)))

(define (max-thrust-p1 prog)
  (apply max (map (lambda (p) (run5-linear prog p)) (permutations '(0 1 2 3 4)))))
;; (max-thrust-p1 orig-prog)

; part 2

(module+ test
  (require rackunit)
  (check-equal? (max-thrust-p2 (string->intcode "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5")
                               ;; (list 9 8 7 6 5))
                               )
                139629729)
  (check-equal? (max-thrust-p2 (string->intcode "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10")
                               ;; (list 9 7 8 5 6))
                               )
                18216)
  )
(define (max-thrust-p2 prog)
  (apply max (map (lambda (p) (test-permute-p2 prog p)) (permutations '(5 6 7 8 9)))))

(define (test-permute-p2 prog permute)
  (let* ([vm1 (process (intcode (vector-copy prog) 0 (first permute) #f))]
         [vm2 (process (intcode (vector-copy prog) 0 (second permute) #f))]
         [vm3 (process (intcode (vector-copy prog) 0 (third permute) #f))]
         [vm4 (process (intcode (vector-copy prog) 0 (fourth permute) #f))]
         [vm5 (process (intcode (vector-copy prog) 0 (fifth permute) #f))])
    (process-next (list vm1 vm2 vm3 vm4 vm5) '() 0)))

(define (process-next todo completed output)
  (if (andmap vm-halted? todo)
      (intcode-output (fifth todo))
      (let* ([done (process (struct-copy intcode (car todo) [input output]))]
             [done-output (intcode-output done)]
             [leftover (cdr todo)]
             [new-completed (cons done completed)])
        (if (empty? leftover)
            (process-next (reverse new-completed) '() done-output)
            (process-next leftover new-completed done-output)))))

(max-thrust-p2 orig-prog)
