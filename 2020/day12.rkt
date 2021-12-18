#lang racket

(define input (file->lines "day12.input"))

;; PART 1

(struct posn (x y facing) #:transparent)
(define (get-new-x-y-from l a)
  (cond
    [(equal? (modulo (posn-facing l) 360) 0)
     (values (+ (posn-x l) a) (posn-y l))]
    [(equal? (modulo (posn-facing l) 360) 90)
     (values (posn-x l) (+ (posn-y l) a))]
    [(equal? (modulo (posn-facing l) 360) 180)
     (values (- (posn-x l) a) (posn-y l))]
    [(equal? (modulo (posn-facing l) 360) 270)
     (values (posn-x l) (- (posn-y l) a))]))

(define (apply-op cur-loc op)
  (if (posn? cur-loc)
      (apply-posn-op cur-loc op)
      (apply-posn2-op cur-loc op)))

(define (apply-posn-op cur-loc op)
  (let ([ins (string-ref op 0)]
        [amount (string->number (substring op 1))])
    (cond
      [(equal? ins #\N) (posn
                         (posn-x cur-loc)
                         (+ (posn-y cur-loc) amount)
                         (posn-facing cur-loc))]
      [(equal? ins #\S) (posn
                         (posn-x cur-loc)
                         (- (posn-y cur-loc) amount)
                         (posn-facing cur-loc))]
      [(equal? ins #\E) (posn
                         (+ (posn-x cur-loc) amount)
                         (posn-y cur-loc)
                         (posn-facing cur-loc))]
      [(equal? ins #\W) (posn
                         (- (posn-x cur-loc) amount)
                         (posn-y cur-loc)
                         (posn-facing cur-loc))]
      [(equal? ins #\L) (posn
                         (posn-x cur-loc)
                         (posn-y cur-loc)
                         (+ (posn-facing cur-loc) amount))]
      [(equal? ins #\R) (posn
                         (posn-x cur-loc)
                         (posn-y cur-loc)
                         (- (posn-facing cur-loc) amount))]
      [(equal? ins #\F)
       (let-values ([(x y) (get-new-x-y-from cur-loc amount)])
         (posn
          x
          y
          (posn-facing cur-loc)))])))

(define (get-manhattan-loc instructions cur-loc)
  (if (empty? instructions)
      ;; (+ (abs (posn-x cur-loc)) (abs (posn-y cur-loc)))
      cur-loc
      (let ([op (car instructions)])
        (get-manhattan-loc (cdr instructions) (apply-op cur-loc op)))))

(define part1 (get-manhattan-loc input (posn 0 0 0)))
(+ (abs (posn-x part1)) (abs (posn-y part1)))

;; PART 2

(struct posn2 (x y way-x way-y) #:transparent)

(define (way-x-y l a)
  (cond
    [(equal? a 90)
     (values (- (posn2-way-y l)) (posn2-way-x l))]
    [(equal? a 180)
     (values (- (posn2-way-x l)) (- (posn2-way-y l)))]
    [(equal? a 270)
     (values (posn2-way-y l) (- (posn2-way-x l)))]))

(define (apply-posn2-op cur-loc op)
  (let ([ins (string-ref op 0)]
        [amount (string->number (substring op 1))])
    (cond
      [(equal? ins #\N) (posn2
                         (posn2-x cur-loc)
                         (posn2-y cur-loc)
                         (posn2-way-x cur-loc)
                         (+ (posn2-way-y cur-loc) amount))]
      [(equal? ins #\S) (posn2
                         (posn2-x cur-loc)
                         (posn2-y cur-loc)
                         (posn2-way-x cur-loc)
                         (- (posn2-way-y cur-loc) amount))]
      [(equal? ins #\E) (posn2
                         (posn2-x cur-loc)
                         (posn2-y cur-loc)
                         (+ (posn2-way-x cur-loc) amount)
                         (posn2-way-y cur-loc))]
      [(equal? ins #\W) (posn2
                         (posn2-x cur-loc)
                         (posn2-y cur-loc)
                         (- (posn2-way-x cur-loc) amount)
                         (posn2-way-y cur-loc))]
      [(equal? ins #\L) (let-values ([(x y) (way-x-y cur-loc amount)])
                          (posn2
                           (posn2-x cur-loc)
                           (posn2-y cur-loc)
                           x
                           y))]
      [(equal? ins #\R) (let-values ([(x y) (way-x-y cur-loc (- 360 amount))])
                          (posn2
                           (posn2-x cur-loc)
                           (posn2-y cur-loc)
                           x
                           y))]
      [(equal? ins #\F) (posn2
                         (+ (posn2-x cur-loc) (* amount (posn2-way-x cur-loc)))
                         (+ (posn2-y cur-loc) (* amount (posn2-way-y cur-loc)))
                         (posn2-way-x cur-loc)
                         (posn2-way-y cur-loc))])))

(define part2 (get-manhattan-loc input (posn2 0 0 10 1)))

(+ (abs (posn2-x part2)) (abs (posn2-y part2)))
