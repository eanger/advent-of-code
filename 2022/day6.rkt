#lang racket

(module+ test
  (require rackunit)
  (check-equal? (end-of-marker "mjqjpqmgbljsphdztnvjfqwrcgsmlb") 7)
  (check-equal? (end-of-marker "bvwbjplbgvbhsrlpgdmjqwftvncz") 5)
  (check-equal? (end-of-marker "nppdvjthqldpwncqszvftbrmjlhg") 6)
  (check-equal? (end-of-marker "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") 10)
  (check-equal? (end-of-marker "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") 11)
  (check-equal? (end-of-message "mjqjpqmgbljsphdztnvjfqwrcgsmlb") 19)
  (check-equal? (end-of-message "bvwbjplbgvbhsrlpgdmjqwftvncz") 23)
  (check-equal? (end-of-message "nppdvjthqldpwncqszvftbrmjlhg") 23)
  (check-equal? (end-of-message "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg") 29)
  (check-equal? (end-of-message "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw") 26))

(define (unique? lst)
  (= (length lst) (set-count (list->set lst))))

(define (do-end-of-n data idx n)
    ; WARNING: will crash when data is shorter than 4
    (let ([candidate (take data n)])
      (if (unique? candidate)
          (+ n idx)
          (do-end-of-n (cdr data) (+ 1 idx) n))))

(define (end-of-marker data)
  (do-end-of-n (string->list data) 0 4))

(end-of-marker (file->string "input.day6"))

(define (end-of-message data)
  (do-end-of-n (string->list data) 0 14))

(end-of-message (file->string "input.day6"))
