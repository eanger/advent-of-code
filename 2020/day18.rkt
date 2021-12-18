#lang racket

(define input (file->lines "day18.input"))

;; PART 1

#|
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
2 + 3 * 4    -> 20
2 + (3 * 4)  -> 14
values and operands stacks
case number:
    push number on stack
    if operand on opstack and isnt open paren:
      pop two values and operand, apply, push value on stack
case operand:
    push operand on stack
case open-paren:
    push paren on stack
case closed-paren:
    pop open paren from stack
|#

(define (get-leading-num lst)
  (let ([idx
         (for/last ([(c i) (in-indexed lst)])
           #:break (or
                    (equal? c #\space)
                    (equal? c #\+)
                    (equal? c #\*)
                    (equal? c #\()
                    (equal? c #\)))
           (+ 1 i))])
    (values
     (string->number (list->string (take lst idx)))
     (drop lst idx))))

(define (do-apply numbers operands)
  (if (and (not (empty? operands))
           (not (equal? (first operands) 'paren)))
      (values
       (cons ((first operands) (first numbers) (second numbers))
             (cddr numbers))
       (rest operands))
      (values numbers operands)))

(define (interpret lst numbers operands)
  (if (empty? lst)
      (car numbers)
      (match (car lst)
        [#\space (interpret (cdr lst) numbers operands)] ; ignore space
        [#\+ (interpret (cdr lst) numbers (cons + operands))]
        [#\* (interpret (cdr lst) numbers (cons * operands))]
        [#\( (interpret (cdr lst) numbers (cons 'paren operands))]
        [#\) ; pop 'paren, eval top
         (let-values ([(new-nums new-ops) (do-apply
                                           numbers
                                           (rest operands))])
           (interpret (cdr lst) new-nums new-ops))]
        [_ ; number
         (let*-values ([(num rest) (get-leading-num lst)]
                       [(new-nums new-ops) (do-apply
                                            (cons num numbers)
                                            operands)])
           (interpret rest new-nums new-ops))])))

(define (do-math line)
  (interpret (string->list line) '() '()))

(foldl (lambda (x y) (+ (do-math x) y)) 0 input)
;; (do-math "2 * 3 + (4 * 5)")
;; (do-math "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")

;; PART 2

#|

1 + 2 * 3 + 4 * 5 + 6

1 _
1 +
1,2 + -> 3 _
3 *
3,3 *
3,3 *,+
3,3,4 *,+ -> 3,7 *
3,7 *,*
3,7,5 *,*
3,7,5 *,*,+
3,7,5,6 *,*,+ -> 3,7,11 *,*

2 * 3 + (4 * 5)

2 _
2 *
2,3 *
2,3 *,+
2,3 *,+,(
2,3,4 *,+,(
2,3,4 *,+,(,*
2,3,4,5 *,+,(,*
2,3,4,5 *,+,(,*,) -> 2,3,4,5

open paren: interpret (push paren)
close paren: interpret (recursive-eval-to-paren numbers operands), rest

+: evaluate immediately, push and continue
do-apply, interpret rest
*: push and continue

|#

(define (apply-top n o)
  (let ([v ((car o) (first n) (second n))])
    (values (cons v (cddr n)) (rest o))))

(define (recursive-apply numbers operands)
  ;; (printf "RA\n")
  ;; (println numbers)
  ;; (println operands)
  ; return (values new-nums new-ops)
  (cond
    [(empty? operands) (values numbers operands)]
    [(equal? (car operands) 'paren)
          (values numbers (cdr operands))]
    [else (let-values ([(n o) (apply-top numbers operands)])
            (recursive-apply n o))]))

(define (do-apply2 numbers operands)
  (if (and (not (empty? operands))
           (not (equal? (first operands) 'paren))
           (not (equal? (first operands) *)))
      (values
       (cons ((first operands) (first numbers) (second numbers))
             (cddr numbers))
       (rest operands))
      (values numbers operands)))

(define (interpret2 lst numbers operands)
  ;; (println (list->string lst))
  ;; (println numbers)
  ;; (println operands)
  (if (empty? lst)
      (let-values ([(n _) (recursive-apply numbers operands)])
        (car n))
      (match (car lst)
        [#\space (interpret2 (cdr lst) numbers operands)] ; ignore space
        [#\+ (interpret2 (cdr lst) numbers (cons + operands))]
        [#\* (interpret2 (cdr lst) numbers (cons * operands))]
        [#\( (interpret2 (cdr lst) numbers (cons 'paren operands))]
        [#\) ; pop 'paren, eval top
         (let*-values ([(new-nums new-ops) (recursive-apply
                                           numbers
                                           operands)]
                       [(n2 o2) (do-apply2 new-nums new-ops)])
           (interpret2 (cdr lst) n2 o2))]
        [_ ; number
         (let*-values ([(num rest) (get-leading-num lst)]
                       [(new-nums new-ops) (do-apply2
                                            (cons num numbers)
                                            operands)])
           (interpret2 rest new-nums new-ops))])))

(define (do-math2 line)
  (interpret2 (string->list line) '() '()))

(foldl (lambda (x y) (+ (do-math2 x) y)) 0 input)
