#lang racket

(define input (file->lines "day24.input"))

;; PART 1

#|
try using cube coordinates (q,r,s), where q is ne/sw, r is n/w, s is nw/se
e:  (1,0,-1)
se: (0,1,-1)
sw: (-1,1,0)
w:  (-1,0,1)
nw: (0,1,-1)
ne: (1,-1,0)
|#

; NOTE: This is a magic number to make sure we don't overflow the
; vector
(define half-dim 68)
(define dim (* 2 half-dim))
(define (get-e) (list 1 0 -1))
(define (get-w) (list -1 0 1))
(define (get-s c)
  (if (equal? c #\e)
      (list 0 1 -1)
      (list -1 1 0)))
(define (get-n c)
  (if (equal? c #\e)
      (list 1 -1 0)
      (list 0 -1 1)))

(define (coord-from-line line)
  ; walk through directions to calculate final coords
  (if (empty? line)
      (list half-dim half-dim half-dim)
      (let*-values ([(c) (car line)]
                    [(rst) (cdr line)]
                    [(this-coord rst) (cond
                                        [(equal? c #\e) (values (get-e) rst)]
                                        [(equal? c #\w) (values (get-w) rst)]
                                        [(equal? c #\s) (values (get-s (car rst)) (cdr rst))]
                                        [(equal? c #\n) (values (get-n (car rst)) (cdr rst))])])
        (map + this-coord (coord-from-line rst)))))

(define (calc-flip-hash lines)
  ; result-hash[line]++ for line in lines
  (foldl (lambda (l hsh)
           (let* ([coord (coord-from-line (string->list l))]
                  [cur-val (hash-ref hsh coord 0)])
             (hash-set hsh coord (+ cur-val 1))))
         (hash) lines))

(define flip-hash (calc-flip-hash input))

(define (count-flipped hsh)
  ; number of keys where value is odd
  (for/sum ([(k v) (in-hash hsh)])
    (if (even? v)
        0
        1)))

(count-flipped flip-hash)

;; PART 2

#|
Consider 3d array with some padding in each direction and map flip-hash to locations in the grid.
Then, walk through each location in the grid and see if it should change.
|#
(define flip-vec (make-vector (* dim dim dim) #f)) ; false means white (unset)

(define (coord-to-vec-id coord)
  (let ([q (first coord)]
        [r (second coord)]
        [s (third coord)])
    (+ (* q (* dim dim))
       (* r (* dim))
       s)))

(for ([(k v) (in-hash flip-hash)]
      #:when (odd? v))
  (vector-set! flip-vec (coord-to-vec-id k) #t))

(define (flip? loc)
  (let ([neighbors
         (for/sum ([k '(0 -1 -1 0 1 1)]
                   [j '(-1 0 1 1 0 -1)]
                   [i '(1 1 0 -1 -1 0)])
           (let ([idx (+ (* k dim dim)
                         (* j dim)
                         i
                         loc)])
             (if (and (>= idx 0)
                      (< idx (vector-length flip-vec))
                      (vector-ref flip-vec idx))
                 1
                 0)))])
    (or
     (and (vector-ref flip-vec loc)
          (or (equal? neighbors 0)
              (> neighbors 2)))
     (and (not (vector-ref flip-vec loc))
          (equal? neighbors 2)))))

(define (day)
  (let ([to-flip (filter flip? (range (vector-length flip-vec)))])
    (for ([loc (in-list to-flip)])
      (vector-set! flip-vec loc (not (vector-ref flip-vec loc))))))

;; (day)
(define (count-flipped-vec v)
  (for/sum ([x (in-vector v)])
    (if x 1 0)))
(define (count-after-n-days n)
  (map (lambda (x) (day)) (range n))
  (count-flipped-vec flip-vec))

(count-after-n-days 20)
(count-after-n-days 10)
(count-after-n-days 10)
(count-after-n-days 10)
(count-after-n-days 10)
(count-after-n-days 10)
(count-after-n-days 10)
(count-after-n-days 10)
(count-after-n-days 10)
