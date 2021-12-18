#lang racket

(define input (file->lines "day17.input"))

;; PART 1


#|
for each cycle i, the search space is initial size +i in each dimension

123
456
789

2,1,0 -> x + dim*y + dim*dim*z


00000
0xxx0
0xxx0
0xxx0
00000

|#
(define rounds 6)
(define max-dim (+ (length input) (* 2 rounds)))
(define space (make-vector (expt max-dim 3) 'empty))
(define space4 (make-vector (expt max-dim 4) 'empty))
(define (space-set! space x y z val)
  (vector-set! space
               (+ x (* max-dim y) (* max-dim max-dim z))
               val))
(define (init-space space)
  (for ([(row y) (in-indexed input)])
    (for ([(c x) (in-indexed row)])
      (if (equal? c #\#)
          (space-set! space (+ rounds x) (+ rounds y) (quotient max-dim 2) 'set)
          (space-set! space (+ rounds x) (+ rounds y) (quotient max-dim 2) 'empty)))))

(define (space-ref space x y z)
  (vector-ref space
              (+ x (* max-dim y) (* max-dim max-dim z))))

(init-space space)
(define (prints space)
  (for ([z (in-range max-dim)])
    (for ([y (in-range max-dim)])
      (for ([x (in-range max-dim)])
        (let ([v (space-ref space x y z)])
          (if (equal? v 'empty)
              (printf ". ")
              (printf "# "))))
      (newline))
    (newline)))
;; (prints space)
(define (count-surrounding space x y z)
  (for*/sum ([i (in-range (- x 1) (+ x 2))]
             [j (in-range (- y 1) (+ y 2))]
             [k (in-range (- z 1) (+ z 2))]
             #:unless (or
                       (i . < . 0)
                       (i . >= . max-dim)
                       (j . < . 0)
                       (j . >= . max-dim)
                       (k . < . 0)
                       (k . >= . max-dim)
                       (equal? (list x y z) (list i j k))))
    (if (equal? 'set (space-ref space i j k))
        1
        0)))

(define (get-next-cycle space)
  (let ([res (vector-copy space)])
    (for* ([x (in-range max-dim)]
           [y (in-range max-dim)]
           [z (in-range max-dim)])
      (let ([cnt (count-surrounding space x y z)]
            [val (space-ref space x y z)])
        (if
         (and (equal? val 'set)
              (not (equal? cnt 2))
              (not (equal? cnt 3)))
         (space-set! res x y z 'empty)
         (when
             (and
              (equal? val 'empty)
              (equal? 3 cnt))
           (space-set! res x y z 'set)))))
    res))

(define (repeate-n func n init)
  (if (equal? n 0) init
      (repeate-n func (- n 1) (func init))))

(define end (repeate-n get-next-cycle rounds space))
(define (count-set space)
  (for/sum ([elem (in-vector space)])
    (if (equal? elem 'set)
        1
        0)))
;; (prints end)
(count-set end)

;; PART 2

(define (space-set4! space x y z w val)
  (vector-set! space
               (+ x (* max-dim y) (* max-dim max-dim z) (* max-dim max-dim max-dim w))
               val))
(define (init-space4 space)
  (for ([(row y) (in-indexed input)])
    (for ([(c x) (in-indexed row)])
      (if (equal? c #\#)
          (space-set4! space
                       (+ rounds x)
                       (+ rounds y)
                       (quotient max-dim 2)
                       (quotient max-dim 2)
                       'set)
          (space-set4! space
                       (+ rounds x)
                       (+ rounds y)
                       (quotient max-dim 2)
                       (quotient max-dim 2)
                       'empty)))))

(define (space-ref4 space x y z w)
  (vector-ref space
              (+ x (* max-dim y) (* max-dim max-dim z) (* max-dim max-dim max-dim w))))

(init-space4 space4)

(define (count-surrounding4 space x y z w)
  (for*/sum ([i (in-range (- x 1) (+ x 2))]
             [j (in-range (- y 1) (+ y 2))]
             [k (in-range (- z 1) (+ z 2))]
             [l (in-range (- w 1) (+ w 2))]
             #:unless (or
                       (i . < . 0)
                       (i . >= . max-dim)
                       (j . < . 0)
                       (j . >= . max-dim)
                       (k . < . 0)
                       (k . >= . max-dim)
                       (l . < . 0)
                       (l . >= . max-dim)
                       (equal? (list x y z w) (list i j k l))))
    (if (equal? 'set (space-ref4 space i j k l))
        1
        0)))

(define (get-next-cycle4 space)
  (let ([res (vector-copy space)])
    (for* ([x (in-range max-dim)]
           [y (in-range max-dim)]
           [z (in-range max-dim)]
           [w (in-range max-dim)])
      (let ([cnt (count-surrounding4 space x y z w)]
            [val (space-ref4 space x y z w)])
        (if
         (and (equal? val 'set)
              (not (equal? cnt 2))
              (not (equal? cnt 3)))
         (space-set4! res x y z w 'empty)
         (when
             (and
              (equal? val 'empty)
              (equal? 3 cnt))
           (space-set4! res x y z w 'set)))))
    res))
(count-set (repeate-n get-next-cycle4 rounds space4))
