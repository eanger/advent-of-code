#lang racket

(define input (file->lines "day19.input"))

;; PART 1

(define-values (rules-lines tests) (split-at input (index-of input "")))

;; (define num-rules 43)
;; rules-lines
(define original-rules
  (for/hash ([line (in-list rules-lines)])
    (let* ([parts (string-split line ": ")]
           [idx (string->number (car parts))])
      (if (equal? #\" (string-ref (cadr parts) 0))
          (values idx (string-ref (cadr parts) 1))
          (let* ([strs (map string-split (string-split (cadr parts) " | "))]
                 [lsts (map (lambda (x) (map string->number x)) strs)])
            (values idx lsts))))))

;; (define rules (hash-set* original-rules
;;                          8 (for/list ([n (in-range 10 0 -1)])
;;                              (make-list n 42))
;;                          11 (for/list ([n (in-range 10 0 -1)])
;;                               (append (make-list n 42) (make-list n 31)))))
;; (define rules (hash-set* original-rules
;;                          8 (for/list ([n (in-range 1 10)])
;;                              (make-list n 42))
;;                          11 (for/list ([n (in-range 1 10)])
;;                               (append (make-list n 42) (make-list n 31)))))
(define rules (hash-remove (hash-remove original-rules 8) 11))

;; (hash-ref rules 8)

; return rest of str after matching rule-id, #f if no match
(define (match lst rule-id)
  (let ([rule (hash-ref rules rule-id)])
    (cond [(false? lst) #f]
          [(empty? lst) #f]
          [(char? rule)
           ;; (printf "char: ~a\nlst: ~a\n" rule lst)
           (and (equal? (car lst) rule)
                (cdr lst))]
          [else (ormap (lambda (rls)
                         (foldl (lambda (rl l) (match l rl)) lst rls))
                       rule)])))

(define (match2-0 lst)
  (let loopx ([x 2])
    (let ([res (foldl (lambda (_ l) (match l 42)) lst (range x))])
      (printf "x: ~a\nres: ~a\n" x res)
      (if (false? res) #f
          (let ([resx (let loopy ([y 1]
                                  [l res])
                        (if (= y x) #f
                            (let ([res2 (foldl (lambda (_ l) (match l 31)) l (range y))])
                              (printf "y: ~a\nres2: ~a\n" y res2)
                              (cond [(false? res2) #f]
                                    [(equal? res2 '()) '()]
                                    [else (loopy (+ 1 y) res2)]))))])
            (cond [(false? resx) #f]
                  [(equal? resx '()) '()]
                  [else (loopx (+ 1 x))]))))))

(define (match4-0 lst)
  ;; (displayln lst)
  (let ([r (match (match lst 42) 42)])
    (if (false? r) r
        ; 2+,1+
        (let loopx ([lx r]
                    [nx 1])
          (let ([final-y
                 (let loopy ([ly lx]
                             [ny 1])
                   (printf "~a,~a\n" nx ny)
                   (let ([ry (match ly 31)])
                     ;; (printf "ly: ~a\nry: ~a\n" ly ry)
                     (cond [(false? ry) #f]
                           [(equal? ry '()) '()]
                           [(= ny nx) #f]
                           [else (loopy ry (+ 1 ny))])))]
                [next-lx (match lx 42)])
            ;; (printf "lx: ~a\nrx: ~a\n" lx rx)
            (cond [(equal? final-y '()) '()]
                  [(false? next-lx) #f]
                  [else (loopx next-lx (+ 1 nx))]))))))

(define (match42 lst)
  (let loop ([l lst]
             [n 0])
    (let ([m (match l 42)])
      (if (false? m) n
          (loop m (+ 1 n))))))

(define (match-0 lst)
  (let loopx ([x 1])
  ;; (for/and ([x (in-naturals 1)])
    (printf "x: ~a\n" x)
    (let ([res (foldl (lambda (_ l) (match l 42)) lst (range x))])
      (if (false? res) #f
          (let ([ret
                 (let loop ([y 1])
                   (let* ([res2 (foldl (lambda (_ l) (match l 42)) res (range y))]
                          [res3 (foldl (lambda (_ l) (match l 31)) res2 (range y))])
                     (printf "y: ~a\nres3: ~a\n" y res3)
                     (cond [(equal? res3 '()) res3]
                           [(false? res3) #f]
                           [else (loop (+ 1 y))])))])
            (if (equal? ret '()) ret
                (loopx (+ x 1))))))))

(define results (map (lambda (x)
                       ;; (displayln x)
                       (match4-0 (string->list x)))
                     (cdr tests)))
;; results

(count (lambda (x) (equal? x '())) results)

;; (displayln (third (cdr tests)))
;; (match-0 (string->list (third (cdr tests))))
;; (match2-0 (string->list (third (cdr tests))))
;; (match3-0 (string->list (third (cdr tests))))
;; (match4-0 (string->list (third (cdr tests))))
;; (match (string->list (third (cdr tests))) 0)
