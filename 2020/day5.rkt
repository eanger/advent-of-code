#lang racket

(define input (file->lines "day5.input"))

;; PART 1
;; FBFBBFF  ->  44
;; 0101100  ->  44

(define (get-seat-id seat)
  (let ([row (substring seat 0 7)]
        [col (substring seat 7 10)])
    (+
     (* 8 (string->number (string-replace (string-replace row "F" "0") "B" "1") 2))
     (string->number (string-replace (string-replace col "L" "0") "R" "1") 2))))
(foldl (lambda (id cur-max) (max (get-seat-id id) cur-max)) 0 input)

;; PART 2

;; set difference b/w all seat ids and numbers between min and max
(define listed-ids (map get-seat-id input))
(define set-listed-ids (list->set listed-ids))
(define all-ids (list->set (in-range (apply min listed-ids) (+ 1 (apply max listed-ids)))))
(set-first (set-subtract all-ids set-listed-ids))
