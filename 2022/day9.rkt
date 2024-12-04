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


;; for each increment, move head and propagate moves
;; for/last?
(define (do-move2 move-str head knots)
  (let* ([dir (first (string-split move-str " "))]
         [inc (second (string-split moves-str " "))]
         [inc-loc (match dir
                     ["U" (loc 0 inc)]
                     ["D" (loc 0 (- inc))]
                     ["R" (loc inc 0)]
                     ["L" (loc (- inc) 0)])])
    (for*/fold ([h (loc-add head inc-loc)]
                [res '()])
               ([_ (in-range inc)]
                [knot knots])
      (tail-visits h knot)
  0)

(define (do-move move-str head knots)
  ;; returns new head and list of list of visited locations
  (let* ([words (string-split move-str " ")]
         [dir (first words)]
         [inc (string->number (second words))]
         [new-head (match dir
                     ["U" (loc-add head (loc 0 inc))]
                     ["D" (loc-add head (loc 0 (- inc)))]
                     ["R" (loc-add head (loc inc 0))]
                     ["L" (loc-add head (loc (- inc) 0))])])
    (let-values ([(_ result) ;; 'result' is the list of lists of moves
                  (for/fold ([h new-head]
                             [res '()])
                            ([knot knots])
                    (let ([visits (reverse (tail-visits h knot))])
                      (values (car visits) (cons visits res))))])
      (values new-head (reverse result)))))

;; for each move, append moves to list
;; fold?
;; head of tail-moves is where tail should start for next move
;; if we need to do another move, pop it off the list
(define (all-tail-moves moves-str)
  ;; TODO move by one increment at a time instead of full step
  (for/fold ([head (loc 0 0)]
             [tail-moves (make-list 9 (list (loc 0 0)))])
            ([move (string-split moves-str "\n")])
    (let-values ([(new-head new-tails) (do-move move head (map car tail-moves))])
      (values new-head
              (map append new-tails (map cdr tail-moves))))))

(define (count-moves str knot-idx)
  (let-values ([(_ tail-moves) (all-tail-moves str)])
    (set-count (list->set (list-ref tail-moves knot-idx)))))

; part 2
; keep list of knots (including head)
; apply moves one by one? down the line

(define test2 "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20")

;; (count-moves (file->string "input.day9") 0)
;; (count-moves (file->string "input.day9") 8)
;; (count-moves test2 8)
;; (all-tail-moves (file->string "input.day9"))

(do-move "R 4" (loc 0 0) (list (loc 0 0) (loc 0 0) (loc 0 0) (loc 0 0)))
