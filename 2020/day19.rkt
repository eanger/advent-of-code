#lang racket

(define input (file->lines "day19a.input"))

;; PART 1

(define-values (rules-lines tests) (split-at input (index-of input "")))

; rules: vector of lists, each list is list of rules to match
;; (define num-rules (length rules-lines))
(define num-rules 43)
(define rules
  (let ([res (make-vector num-rules)])
    (for ([line (in-list rules-lines)])
      (let* ([parts (string-split line ": ")]
             [idx (string->number (car parts))])
        (if (equal? #\" (string-ref (cadr parts) 0))
            (vector-set! res idx (car (string-split (cadr parts) "\"")))
            (let* ([strs (map string-split (string-split (cadr parts) " | "))]
                   [lsts (map (lambda (x) (map string->number x)) strs)])
              (vector-set! res idx lsts)))))
    res))

(define (shortest-subset lst)
  (define (s l m)
    (cond [(empty? l) m]
          [(not (car l)) (s (cdr l) m)]
          [(not m) (s (cdr l) (car l))]
          [(> (string-length (car l)) (string-length m)) (s (cdr l) (car l))]
          [else (s (cdr l) m)]))
  (s (cdr lst) (car lst)))

(define (get-match-8 start)
  (printf "8: ~a\n" start)
  (let ([res (get-match 42 start)])
    (printf "first: ~a\n" res)
    (let loop ([str res])
      (let ([r (get-match 42 str)])
        (printf "loop: ~a\n" r)
        (cond
          [(equal? r "") r]
          [(not r) res]
          [else (loop r)])))))
  #|
  loop:
  res = get-match (42, str)
  if res != "" and not #f, loop()
  return res

  what happens if the loop happens in the middle?
  if res is #f from the second match, return old match
my method is too aggressive; it will match as many as possible before
quitting. Instead, it should unwind and try other options, but if that fails, it will have to do more. I think. This is hard I'm going to give up.


match 42 once. loop on 42 until error, then loop on 31 n-1 times
  |#

(define (get-match-31 cnt start)
  ;; (printf "31: ~a, ~a\n" cnt start)
  (let loop ([i cnt]
             [s start])
    (if (equal? i 0) s
        (let ([r (get-match 31 s)])
          ;; (printf "31loop: ~a\n" r)
          (loop (- i 1) r)))))

(define (get-match-11 start)
  ;; (printf "11: ~a\n" start)
  (let ([res (get-match 42 start)])
    ;; (printf "first: ~a\n" res)
    (let loop ([str res]
               [cnt 1])
      (let ([r (get-match 42 str)])
        ;; (printf "loop: ~a\n" r)
        (cond
          [(not r) (get-match-31 cnt str)]
          [else (loop r (+ 1 cnt))])))))

(define (get-match-all rule str)
  ;; (printf "A: ~a, ~a\n" rule str)
  (define (get-match-helper r s)
    (cond
      [(equal? r 8) (get-match-8 s)]
      [(equal? r 11) (get-match-11 s)]
      [else (get-match r s)]))
  (define (get-match-subset subset)
    ;; (printf "GMS: ~a, ~a\n" subset str)
    (foldl get-match-helper str subset))
  (ormap get-match-subset rule))

(define (get-match rule-idx str)
  ;; (printf "GM: ~a, ~a\n" rule-idx str)
  (if (not str)
      #f ; propagate #f back up
      (let ([rule (vector-ref rules rule-idx)])
        (if (string? rule)
            (if (string-prefix? str rule)
                (substring str (string-length rule))
                #f)
            (get-match-all rule str)))))

(define (matches? line)
  (printf "START: ~a\n" line)
  (let ([res (get-match 0 line)])
    (equal? res "")))

(count identity (map matches? (cdr tests)))

;; PART 2

#|
to match a subset, the WHOLE string must match for all rules in the subset
|#
;; (vector-set! rules 8 '((42) (42 8)))
;; (vector-set! rules 11 '((42 31) (42 11 31)))
;; (define num-iters 11)
;; (vector-set! rules 8 (build-list num-iters (lambda (x) (make-list (+ 1 x) 42))))
;; (vector-set! rules 11
;;              (build-list num-iters
;;                          (lambda (x) (append
;;                                       (make-list (+ 1 x) 42)
;;                                       (make-list (+ 1 x) 31)))))

;; (vector-ref rules 8)
;; (vector-ref rules 11)
(count identity (map matches? (cdr tests)))
;; (map matches? (cdr tests))
