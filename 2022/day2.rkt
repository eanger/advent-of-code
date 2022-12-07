#lang racket

(module+ test
  (require rackunit)
  (check-equal? (total-score "A Y
B X
C Z") 15)
  (check-equal? (total-score-p2 "A Y
B X
C Z") 12))

(define (total-score guide)
  (let ([games (parse-guide guide)])
    (apply + (map score-game games))))

(define (parse-guide guide)
  (map string-split
       (string-split guide "\n")))

(define (score-game game)
  (define winner-score #hash((("A" "X") . 3) ; draw 3
                             (("A" "Y") . 6) ; win 6
                             (("A" "Z") . 0) ; lose 0
                             (("B" "X") . 0) ; lose 0
                             (("B" "Y") . 3) ; draw 3
                             (("B" "Z") . 6) ; win 6
                             (("C" "X") . 6) ; win 6
                             (("C" "Y") . 0) ; lose 0
                             (("C" "Z") . 3) ; draw 3
                             ))

  (define shape-score #hash(("X" . 1)
                            ("Y" . 2)
                            ("Z" . 3)))
  (+
   (hash-ref shape-score (second game))
   (hash-ref winner-score game)))

(total-score (file->string "input.day2"))

(define (total-score-p2 guide)
  (let ([games (parse-guide guide)])
    (apply + (map score-game-p2 games))))

(define (score-game-p2 game)
  (define what-to-play #hash((("A" "X") . "C") ; lose
                             (("A" "Y") . "A") ; draw
                             (("A" "Z") . "B") ; win
                             (("B" "X") . "A") ; lose
                             (("B" "Y") . "B") ; draw
                             (("B" "Z") . "C") ; win
                             (("C" "X") . "B") ; lose
                             (("C" "Y") . "C") ; draw
                             (("C" "Z") . "A") ; win
                             ))

  (define game-score #hash(("X" . 0)
                           ("Y" . 3)
                           ("Z" . 6)))
  (define shape-score #hash(("A" . 1)
                            ("B" . 2)
                            ("C" . 3)))
  (let ([shape (hash-ref what-to-play game)])
    (+
     (hash-ref game-score (second game))
     (hash-ref shape-score shape))))

(total-score-p2 (file->string "input.day2"))
