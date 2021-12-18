#lang racket/base
(require racket/file)
(require racket/list)

(define input (sort  (file->list "day1.input") <))
(define (get-date? target a b)
   (cond
     [(eq? (length a) 1) '()]
     [(empty? b) '()]
     [else
      (begin
        (define x (+ (car a) (car b)))
        (cond
          [(< x target) (get-date? target a (cdr b))]
          [(= x target) (list (car a) (car b))]
          [else (get-date? target (cdr a) (cddr a))]))]))

; (displayln (get-date? 2020 input (cdr input)))

(define (get-date2? target a b c)
   (define res (get-date? (- target (car a)) b c))
   (if (empty? res)
      (get-date2? target (cdr a) (cddr a) (cdddr a))
      (cons (car a) res)))

; (println (get-date? 1999 (cdr input) (cddr input)))
(define res (get-date2? 2020 (cdr input) (cddr input) (cdddr input)))
(println (foldl + 0 res))
(println (foldl * 1 res))
(println res)
