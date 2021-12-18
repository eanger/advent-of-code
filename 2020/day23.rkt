#lang racket

(define input '(7 1 6 8 9 2 5 4 3))
(define inputa '(3 8 9 1 2 5 4 6 7))

;; PART 1

(define (get-target-idx lst target wrap)
  (or
   (index-of lst target)
   (if (equal? 0 target)
       (get-target-idx lst wrap wrap)
       (get-target-idx lst (- target 1) wrap))))

(define (move lst wrap)
  (let* ([id (car lst)]
         [pick-up (take (cdr lst) 3)]
         [rst (drop lst 4)]
         [idx (+ 1 (get-target-idx rst (- id 1) wrap))])
    (append (take rst idx)
            pick-up
            (drop rst idx)
            (list id))))

(define (get-outcome start times wrap)
  (foldl (lambda (x n)
           (move n wrap))
         start
         (stream->list (in-range times))))

(define (calc-labels start times wrap)
  (let* ([outcome (get-outcome start times wrap)]
         [idx (index-of outcome 1)]
         [left (take outcome idx)]
         [right (drop outcome (+ 1 idx))])
    (string-join (map number->string (append right left)) "")))

(displayln (calc-labels inputa 10 9))

;; PART 2

#|
(3) [8 9 1] 2 5 4 6 7 (10 .. 1M) -> 2
(2) [8 9 1] 5 4 6 7 (10 .. 1M) 3 -> 1M
(5) [4 6 7] (10 .. 1M) 8 9 1 3 2 -> 3
(10) 11 12 13 (14 .. 1M) 8 9 1 3 4 6 7 2 5 -> 9
(14) 15 16 17 (18 .. 1M) 8 9 11 12 13 1 3 4 6 7 2 5 10 -> 13
(18) 19 20 21 (22 .. 1M) 8 9 11 12 13 15 16 17 1 3 4 6 7 2 5 10 -> 17

after hash:
3: 8
8: 9
9: 1
1: 2
2: 5
5: 4
4: 6
6: 7
7: 3

arguments: head
1. let pickup = after[head], after[after[head]], after[after[after[head]]]
2. let target = head - 1 if not in pickup
3. temp = after[target], after[target] = pickup, after[pickup_3] = temp
4. after[head] = after[p3]
5. new head is after[head]
|#

(define (get-target t p1 p2 p3)
  (cond
    [(equal? 0 t)
     ;; (get-target 9 p1 p2 p3)]
     (get-target 1000000 p1 p2 p3)]
    [(or (equal? t p1)
         (equal? t p2)
         (equal? t p3))
     (get-target (- t 1) p1 p2 p3)]
    [else t]))

(define (move2 after head)
  (let* ([p1 (vector-ref after head)]
         [p2 (vector-ref after p1)]
         [p3 (vector-ref after p2)]
         [target (get-target (- head 1) p1 p2 p3)]
         [temp (vector-ref after target)]
         [after-head (vector-ref after p3)])
    (vector-set*! after
                  target p1
                  p3 temp
                  head after-head)
    after-head))

; (7 1 6 8 9 2 5 4 3)
(define input-vec (list->vector (append
                                 '(0 6 5 10 3 4 8 1 9 2)
                                 (range 11 1000001)
                                 '(7))))
; (3 8 9 1 2 5 4 6 7)
(define inputa-vec (list->vector (append
                                  '(0 2 5 8 6 4 7 10 9 1)
                                  (range 11 1000001)
                                  '(3))))

(define (do-n after head n)
  (if (equal? n 0)
      after
      (let ([new-head (move2 after head)])
        (do-n after new-head (- n 1)))))

(define res
  ;; (do-n inputa-vec 3 10000000))
  (do-n input-vec 7 10000000))

(let* ([a (vector-ref res 1)]
       [b (vector-ref res a)])
  (displayln a)
  (displayln b)
  (* a b))
