#lang racket
(require racket/hash)
(require predicates)

(define input (file->lines "day7.input"))

;; PART 1

(define (get-contains lst)
  (define (contained lst)
    (cond
      [(empty? lst) empty]
      [else
       (let ([elt (~a (second lst) (third lst) #:separator " ")])
         (cons (cons elt (first lst)) (contained (cddddr lst))))]))
  (cond
    [(= (length lst) 7) empty]
    [else
     (let ([container (~a (car lst) (cadr lst) #:separator " ")])
       (cons container (contained (cddddr lst))))]))

(define (hash-contains contains)
  (cond [(empty? contains) (make-hash)]
        [else
         (let ([otr (car contains)]
               [inr (cdr contains)])
           (for/hash ([x inr])
             (values (car x) (list (cons otr (cdr x))))))]))

(define container-map (apply hash-union
                             (map (compose1 hash-contains get-contains string-split) input)
                             #:combine/key (lambda (k v1 v2) (append v1 v2))))

(define (get-holdable bag containers worklist)
  (cond [(not (hash-has-key? containers bag)) (cond
                                                [(empty? worklist) (set)]
                                                [else (get-holdable (car worklist) containers (cdr worklist))])]
        [else
         (let* ([cur-bags (map car (hash-ref containers bag))]
                [wl (append worklist cur-bags)])
           (set-union (list->set cur-bags)
                      (get-holdable (car wl) containers (cdr wl))))]))

(define shiny-gold-holders (get-holdable "shiny gold" container-map empty))
(set-count shiny-gold-holders)

;; PART 2

(define bag-count-list (map (compose1 get-contains string-split) input))

(define (make-hash-elem x)
  (cons (car x) (cdr x)))
(define bag-count-hash (make-hash (map make-hash-elem (filter nonempty-list? bag-count-list))))

(define (get-holdable-2 bag containers)
  (cond [(not (hash-has-key? containers bag)) 0]
        [else
         (let* ([contains (hash-ref containers bag)]
                [counts (map (compose1 string->number cdr) contains)]
                [cnt (for/list ([b (map car contains)]
                                [c counts])
                       (* c (get-holdable-2 b containers)))])
           (apply + (append counts cnt)))]))

(get-holdable-2 "shiny gold" bag-count-hash)
