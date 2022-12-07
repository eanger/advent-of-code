#lang racket

(module+ test
  (require rackunit)
  (check-equal? (max-cal "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000") 24000)
  (check-equal? (top3-cal "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000") 45000))

(define (max-cal inv-str)
  (apply max
         (map (lambda (x) (apply + (map string->number x)))
              (map string-split
                   (string-split inv-str "\n\n")))))

(max-cal (file->string "input.day1"))

(define (top3-cal inv-str)
  (apply +
         (take (sort (map (lambda (x) (apply + (map string->number x)))
                          (map string-split
                               (string-split inv-str "\n\n")))
                     >)
               3)))

(top3-cal (file->string "input.day1"))
