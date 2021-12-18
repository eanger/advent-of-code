#lang racket

(define input (file->lines "day11.input"))

;; PART 1

(define (my-parse row)
  (for/vector ([char row])
    (if (equal? char #\L)
        'empty
        'floor)))
(define seats (list->vector (map my-parse input)))

#|
for each location in seats:
determine update
if update, mark a bit somewhere?
changed = false
for row in seats:
    (new row, changed?) = process-row
|#

(define (is-occupied? seats x y)
  (cond
    [(x . < . 0) #f]
    [(x . >= . (vector-length seats)) #f]
    [(y . < . 0) #f]
    [(y . >= . (vector-length (vector-ref seats 0))) #f]
    [(equal? (vector-ref (vector-ref seats x) y)
             'occupied)
     #t]
    [else #f]))

(define (simple-visibility seats i j)
  (count identity (list
                   (is-occupied? seats (i . - . 1) (j . - . 1))
                   (is-occupied? seats (i . - . 1) j)
                   (is-occupied? seats (i . - . 1) (j . + . 1))
                   (is-occupied? seats i (j . - . 1))
                   (is-occupied? seats i (j . + . 1))
                   (is-occupied? seats (i . + . 1) (j . - . 1))
                   (is-occupied? seats (i . + . 1) j)
                   (is-occupied? seats (i . + . 1) (j . + . 1)))))

(define (process-seats seats visibility occupied-max)
  ;; return (values new-seats updated?)
  (let ([rows (vector-length seats)]
        [cols (vector-length (vector-ref seats 0))]
        [updated? #f])
    (values
     (for*/vector ([i (in-range rows)])
       (for*/vector ([j (in-range cols)])
         ; count occupied surrounding
         ; update if necessary
         ; set! return val
         (let ([cnt (visibility seats i j)]
               [seat (vector-ref (vector-ref seats i) j)])
           (cond
             [(and (equal? seat 'empty)
                   (equal? 0 cnt))
              (set! updated? #t)
              'occupied]
             [(and (equal? seat 'occupied)
                   (>= cnt occupied-max))
              (set! updated? #t)
              'empty]
             [else seat]
             ))))
     updated?)))

(define (count-occupied seats)
  (for/sum ([row (in-vector seats)])
    (vector-count (lambda (x) (equal? x 'occupied)) row)))

(define (get-stable-seat-count seats)
  (let-values ([(new-seats updated) (process-seats seats simple-visibility 4)])
    (if updated
      (get-stable-seat-count new-seats)
      (count-occupied seats))))

(get-stable-seat-count seats)

;; PART 2

(define (complex-visibility seats i j)
  ;; walk in each direction until end of map
  ;; if occupied, return #t
  ;; if empty, break
  ;; count for each of 8 directions
  ;; (printf "C: ~a,~a\n" i j)
  (define (do-walk i-start i-inc j-start j-inc)
    (for/or ([i (in-range (+ i-start i-inc)
                          (if (< i-inc 0) -1 (vector-length seats))
                          i-inc)]
             [j (in-range (+ j-start j-inc)
                          (if (< j-inc 0) -1 (vector-length (vector-ref seats 0)))
                          j-inc)])
      ;; (printf "~a,~a\n" i j)
      #:break (equal? (vector-ref (vector-ref seats i) j) 'empty)
      (equal? (vector-ref (vector-ref seats i) j) 'occupied)))

  (let ([vals
         (list
          (do-walk i 0 j 1)      ; right
          (do-walk i 1 j 0)      ; down
          (do-walk i 0 j -1)     ; left
          (do-walk i -1 j 0)     ; up
          (do-walk i 1 j 1)      ; right down
          (do-walk i 1 j -1)     ; left down
          (do-walk i -1 j 1)     ; right up
          (do-walk i -1 j -1))]) ; left up
    ;; (displayln vals)
    (count identity vals)))

(define (my-display seats)
  (for ([row (in-vector seats)])
    (for ([seat (in-vector row)])
      (cond [(equal? seat 'occupied) (printf "#")]
            [(equal? seat 'floor) (printf ".")]
            [(equal? seat 'empty) (printf "L")]))
    (newline))
  (newline))

(define (get-complex-stable-seat-count seats)
  ;; (my-display seats)
  (let-values ([(new-seats updated) (process-seats seats complex-visibility 5)])
    (if updated
      (get-complex-stable-seat-count new-seats)
      (count-occupied seats))))

(get-complex-stable-seat-count seats)
