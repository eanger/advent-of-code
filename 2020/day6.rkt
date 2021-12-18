#lang racket

(define input (file->string "day6.input"))

;; PART 1

(define all-answers (string-split input "\n\n"))
(define a (car all-answers))
(define (get-yeses answers)
  (set-count (set-remove (list->set (string->list answers)) #\newline)))
;; (map get-yeses all-answers)
(foldl + 0 (map get-yeses all-answers))

;; PART 2

;; split on newline, get set intersection
(define (get-agreement answers)
  (let ([a (string-split answers)])
    (set-count (apply set-intersect (map (lambda (x) (list->set (string->list x))) a)))))
(foldl + 0 (map get-agreement all-answers))
