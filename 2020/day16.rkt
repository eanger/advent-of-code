#lang racket

(require memoize)

(define input (file->lines "day16.input"))

;; PART 1


;; ranges is a hash: name: pair of pairs
(struct notes (ranges my-ticket nearby-tickets) #:transparent)

(define (parse-ranges lines ranges)
  (let ([mtch (regexp-match #rx"(.*): ([0-9]*)-([0-9]*) or ([0-9]*)-([0-9]*)"
                            (car lines))])
    (if (not mtch) (parse-my-ticket (cdr lines) ranges)
        (let ([name (second mtch)]
              [r1 (cons (string->number (third mtch))
                        (string->number (fourth mtch)))]
              [r2 (cons (string->number (fifth mtch))
                        (string->number (sixth mtch)))])
          (parse-ranges (cdr lines)
                        (hash-set ranges name (list r1 r2)))))))

(define (parse-my-ticket lines ranges)
  (let ([vals (second lines)]
        [rst (cddddr lines)]) ; This starts at the line just after "nearby tickets:"
    (parse-nearby-tickets
     rst
     ranges
     (map string->number (string-split vals ","))
     '())))

(define (parse-nearby-tickets lines ranges my-ticket nearby-tickets)
  (if (empty? lines) (notes ranges my-ticket nearby-tickets)
      (let ([vals (car lines)]
            [rst (cdr lines)])
        (parse-nearby-tickets
         rst
         ranges
         my-ticket
         (cons (map string->number (string-split vals ",")) nearby-tickets)))))

(define note (parse-ranges input (hash)))
;; note

; for each value in all of nearby-tickets
; sum any that don't fit in any of the ranges
(for/sum ([i (flatten (notes-nearby-tickets note))])
  (if (for/or ([rng (foldl append '() (hash-values (notes-ranges note)))])
        (and
         (i . >= . (car rng))
         (i . <= . (cdr rng))))
      0
      i))

;; PART 2

(define (is-valid? lst)
  (for/and ([i lst])
    (for/or ([rng (foldl append '() (hash-values (notes-ranges note)))])
      (and
       (i . >= . (car rng))
       (i . <= . (cdr rng))))))

(define valid-tickets
  (for/list ([lst (notes-nearby-tickets note)]
             #:when (is-valid? lst))
    lst))

;; valid-tickets

(define/memo (valid? elem idx)
  (for/and ([valid valid-tickets])
    (let* ([i (list-ref valid idx)]
           [ranges (hash-ref (notes-ranges note) elem)]
           [s1 (car (first ranges))]
           [e1 (cdr (first ranges))]
           [s2 (car (second ranges))]
           [e2 (cdr (second ranges))])
      (or
       (and (i . >= . s1) (i . <= . e1))
       (and (i . >= . s2) (i . <= . e2))))))

(define seen (mutable-set))
(define (process order left)
  (if (set-empty? left)
      (reverse order)
      (if (set-member? seen left)
          #f
          (begin
            (set-add! seen left)
            (for/or ([elem (in-set left)])
              (and
               (valid? elem (length order))
               (process (cons elem order) (set-remove left elem))))))))

(define valid-order
  (process '() (list->set (hash-keys (notes-ranges note)))))

(define departures
  (for/list ([(x i) (in-indexed valid-order)]
             #:when (string-prefix? x "departure"))
    (list-ref (notes-my-ticket note) i)))
departures
(apply * departures)
