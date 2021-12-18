#lang racket

(define public-key1 13135480)
(define public-key2 8821721)
(define public-key1a 5764801)
(define public-key2a 17807724)

;; PART 1


; x = x*7 mod 20201227

(define (transform subject loop-size)
  (foldl (lambda (_ iter)
           (modulo (* iter subject) 20201227))
         1
         (range loop-size)))

(define (find-loop-size key subject)
  (define (find-loop-size-helper key subject cur n)
    (let ([x (modulo (* cur subject) 20201227)])
      (if (equal? x key) n
          (find-loop-size-helper key subject x (+ 1 n)))))
  (find-loop-size-helper key subject 1 1))

(define loop-size1 (find-loop-size public-key1 7))
(define loop-size2 (find-loop-size public-key2 7))

(transform public-key2 loop-size1)
;; (transform public-key1 loop-size2)

;; PART 2
