#lang racket

(module+ test
  (require rackunit)
  (check-equal? (stack-tops "    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2") "CMZ")
  (check-equal? (stack-tops-p2 "    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2") "MCD"))

(define test "    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2")

(define (stack-tops input)
  (let* ([inputs-split (string-split input "\n\n")]
         [spots (to-stacks (string-split (first inputs-split) "\n"))]
         [moves (string-split (second inputs-split) "\n")])
    (list->string (append (map car (vector->list (foldl do-move spots moves)))))))

(define (vis-strip line)
  ; pick 1 5 9 13 ...
  (let ([line-list (string->list line)])
    (filter identity
            (for/list ([elem line-list]
                       [idx (in-naturals)])
              (if (= (modulo idx 4) 1)
                  elem
                  #f)))))

(define (transpose lst)
  (if (empty? (first lst))
      '()
      (let ([front (filter (lambda (x) (not (char=? x #\space))) (map first lst))]
            [back (map rest lst)])
        (cons front (transpose back)))))

(define (to-stacks spots)
  (list->vector
   (map reverse
        (transpose (map vis-strip (drop (reverse spots) 1))))))

(define (do-move move stacks)
  (let* ([parsed (regexp-match #rx"move (.*) from (.*) to (.*)" move)]
         [cnt (string->number (second parsed))]
         [src (- (string->number (third parsed)) 1)]
         [dst (- (string->number (fourth parsed)) 1)])
    (apply-move cnt src dst stacks)))

(define (apply-move cnt src dst stacks)
  ; pop from src and push to dst cnt times
  (for/fold ([state stacks])
            ([_ (in-range cnt)])
    (let ([pulled (car (vector-ref state src))]
          [left (cdr (vector-ref state src))])
      (vector-set! state dst (cons pulled (vector-ref state dst)))
      (vector-set! state src left)
      state)))

(stack-tops (file->string "input.day5"))

(define (stack-tops-p2 input)
  (let* ([inputs-split (string-split input "\n\n")]
         [spots (to-stacks (string-split (first inputs-split) "\n"))]
         [moves (string-split (second inputs-split) "\n")])
    (list->string (append (map car (vector->list (foldl do-move-p2 spots moves)))))))

(define (do-move-p2 move stacks)
  (let* ([parsed (regexp-match #rx"move (.*) from (.*) to (.*)" move)]
         [cnt (string->number (second parsed))]
         [src (- (string->number (third parsed)) 1)]
         [dst (- (string->number (fourth parsed)) 1)])
    (apply-move-p2 cnt src dst stacks)))

(define (apply-move-p2 cnt src dst stacks)
  ; pop from src and push to dst cnt items
  (let-values ([(pulled left) (split-at (vector-ref stacks src) cnt)])
    (vector-set! stacks dst (append pulled (vector-ref stacks dst)))
    (vector-set! stacks src left))
  stacks)

(stack-tops-p2 (file->string "input.day5"))
