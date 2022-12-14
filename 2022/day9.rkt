#lang racket

(module+ test
  (require rackunit)
  (check-equal? (car (string-split test "\n")) "R 4"))

(define test "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2")

(struct loc (x y) #:transparent)

(define (<=> a b)
  (cond
    [(> (- a b) 0) 1]
    [(< (- a b) 0) -1]
    [else 0]))

(define (move-towards a b)
  (if (or (> (abs (- (loc-x a) (loc-x b))) 1)
          (> (abs (- (loc-y a) (loc-y b))) 1))
      (loc
       (<=> (loc-x a) (loc-x b))
       (<=> (loc-y a) (loc-y b)))
      (loc 0 0)))

(define (loc-add a b)
  (loc (+ (loc-x a) (loc-x b)) (+ (loc-y a) (loc-y b))))

(define (tail-visits head tail)
  ; returns list of all locations tail visits by getting pulled by head
  ; car of list is final tail location
  ; recursive? return (list tail) if no moves, otherwise return (cons tail (tail-visits head next-spot))
  ; next spot needs to be calculated
  (let ([move (move-towards head tail)])
    (if (and (= (loc-x move) 0)
             (= (loc-y move) 0))
        (list tail)
        (cons tail (tail-visits head (loc-add move tail))))))

(define (do-move move-str head tail)
  (let* ([words (string-split move-str " ")]
         [dir (first words)]
         [inc (string->number (second words))]
         [new-head (match dir
                     ["U" (loc-add head (loc 0 inc))]
                     ["D" (loc-add head (loc 0 (- inc)))]
                     ["R" (loc-add head (loc inc 0))]
                     ["L" (loc-add head (loc (- inc) 0))])])
    (values new-head (reverse (tail-visits new-head tail)))))

;; for each move, append moves to list
;; fold?
;; head of tail-moves is where tail should start for next move
;; if we need to do another move, pop it off the list
(define (all-tail-moves moves-str)
  (for/fold ([head (loc 0 0)]
             [tail-moves (list (loc 0 0))])
            ([move (string-split moves-str "\n")])
    (let-values ([(new-head new-tails) (do-move move head (car tail-moves))])
      (values new-head
              (append new-tails (cdr tail-moves))))))

(let-values ([(_ tail-moves) (all-tail-moves (file->string "input.day9"))])
  (set-count (list->set tail-moves)))
