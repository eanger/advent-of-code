#lang racket

(define input (file->lines "day14.input"))

;; PART 1

(define (process-program lines mask mem)
  (if (empty? lines)
      (sum-mem mem)
      (let* ([line (car lines)]
             [mask-match (regexp-match #rx"mask = (.*)" line)]
             [mem-match (regexp-match #rx"mem.(.*). = (.*)" line)])
        (if mask-match
            (process-program (cdr lines) (new-mask (second mask-match)) mem)
            (let ([addr (string->number (second mem-match))]
                  [val (string->number (third mem-match))])
              (process-program (cdr lines) mask
                               (hash-set mem addr (apply-mask mask val))))))))

(define (sum-mem mem)
  (foldl + 0 (hash-values mem)))


(struct mask (zeros ones) #:transparent)
(define (apply-mask mask val)
  (bitwise-and (bitwise-ior val (mask-ones mask)) (mask-zeros mask)))

(define (new-mask m)
  (let ([z (string->number (string-replace m "X" "1") 2)]
        [o (string->number (string-replace m "X" "0") 2)])
    (mask z o)))

(process-program input (mask 0 0) (hash))

;; PART 2

#|
1. replace X with 0, then OR
2. list of comb/perm,



010101
00001X
------
01011X
010110
010111


replace 1 with 0, X with 1, then AND
010111
    00
    01
    10
    11


identify each bit location and make permutations
1X0X0X
100000

addr = apply first mask
for x in (combinations x-bits)
  new-addr = and(addr, not(sum(x-bits)))
  for y in x,
    new-addr = or(new-addr, y)
  (hash-set result new-addr val)
|#

(define (get-first-mask str)
  (string->number (string-replace str "X" "0") 2))

(define (get-x-bits str)
    (for/list ([(x i) (in-indexed (in-string str))]
                        #:when (equal? x #\X))
                (- 35 i)))

(define (apply-mask2 msk addr)
  (bitwise-ior msk addr))
(define (get-addrs addr msk)
  (let* ([start-addr (apply-mask2
                      (get-first-mask msk)
                      (string->number addr))]
         [x-bits (get-x-bits msk)]
         [sum-x-bits (foldl (lambda (x init) (+ init (expt 2 x))) 0 x-bits)])
    (for/list ([x (combinations x-bits)])
      (let ([new-addr (bitwise-and start-addr (bitwise-not sum-x-bits))])
        (foldl (lambda (y na) (bitwise-ior na (expt 2 y))) new-addr x)))))


(define (set-addrs hsh addrs val)
  (apply hash-set* hsh
         (foldl (lambda (x y) (append y (list x val))) '() addrs)))

(define (process-program2 lines mask mem)
  (if (empty? lines)
      (sum-mem mem)
      (let* ([line (car lines)]
             [mask-match (regexp-match #rx"mask = (.*)" line)]
             [mem-match (regexp-match #rx"mem.(.*). = (.*)" line)])
        (if mask-match
            (process-program2 (cdr lines) (second mask-match) mem)
            (let* ([addr (second mem-match)]
                   [val (string->number (third mem-match))]
                   [addrs (get-addrs addr mask)])
              (process-program2 (cdr lines) mask
                                (set-addrs mem addrs val)))))))

(process-program2 input "" (hash))
