#lang racket

(define input (file->string "day22.input"))

;; PART 1

(define input-split (string-split input "\n\n"))
(define p1 (map string->number (cddr (string-split (first input-split)))))
(define p2 (map string->number (cddr (string-split (second input-split)))))

(define (round p1 p2)
  (cond [(empty? p1) p2]
        [(empty? p2) p1]
        [else
         (let ([p1-card (car p1)]
               [p2-card (car p2)])
           (if (> p1-card p2-card)
               (round (append (cdr p1)
                              (list p1-card p2-card))
                      (cdr p2))
               (round (cdr p1)
                      (append (cdr p2)
                              (list p2-card p1-card)))))]))

(define winner (round p1 p2))

(define (calc-score winner)
  (for/sum ([card (in-list winner)]
            [n (in-range (length winner) 0 -1)])
    (* card n)))
(calc-score winner)

;; PART 2

; seen is a set of all games we've previously played
(define (round2 p1 p2 [seen (set)])
  ;; (printf "~a\n~a\n\n" p1 p2)
  (cond [(empty? p1) (cons 'p2 p2)]
        [(empty? p2) (cons 'p1 p1)]
        [(set-member? seen (cons p1 p2)) (list 'p1)]
        [else
         (let ([p1-card (car p1)]
               [p2-card (car p2)]
               [p1-count (length (cdr p1))]
               [p2-count (length (cdr p2))]
               [new-seen (set-add seen (cons p1 p2))])
           (cond
             [(and (>= p1-count p1-card)
                   (>= p2-count p2-card))
              (let ([outcome
                     (round2 (take (cdr p1) p1-card)
                             (take (cdr p2) p2-card)
                             new-seen)])
                (if (equal? (car outcome) 'p1)
                    (round2 (append (cdr p1)
                                    (list p1-card p2-card))
                            (cdr p2)
                            new-seen)
                    (round2 (cdr p1)
                            (append (cdr p2)
                                    (list p2-card p1-card))
                            new-seen)))]
             [else
              (if (> p1-card p2-card)
                  (round2 (append (cdr p1)
                                  (list p1-card p2-card))
                          (cdr p2)
                          new-seen)
                  (round2 (cdr p1)
                          (append (cdr p2)
                                  (list p2-card p1-card))
                          new-seen))]))]))

(define winner2 (cdr (round2 p1 p2)))

(calc-score winner2)
