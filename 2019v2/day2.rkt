#lang racket
(require "utils.rkt")

(module+ test
  (require rackunit)
  (check-equal? (1202-program-alarm (string->intcode "1,0,0,0,99")) 2)
  (check-equal? (1202-program-alarm (string->intcode "2,3,0,3,99")) 2)
  (check-equal? (1202-program-alarm (string->intcode "2,4,4,5,99,0")) 2)
  (check-equal? (1202-program-alarm (string->intcode "1,1,1,4,99,5,6,0,99")) 30))

(define (1202-program-alarm prog)
  (run-intcode prog 0)
  (vector-ref prog 0))

(define (run-intcode prog ip)
  (match (vector-ref prog ip)
    [1 (binary-op + prog ip)]
    [2 (binary-op * prog ip)]
    [99 #t]
    [_ (println "UNIMPLEMENTED") #f]))

(define (binary-op op prog ip)
  (let ([a (vector-ref prog (+ ip 1))]
        [b (vector-ref prog (+ ip 2))]
        [c (vector-ref prog (+ ip 3))]
        [d (+ ip 4)])
    (vector-set! prog c (op (vector-ref prog a) (vector-ref prog b)))
    (run-intcode prog d)))

(let* ([prog-str (file->string "input.day2")]
       [prog (string->intcode prog-str)])
  (vector-set! prog 1 12)
  (vector-set! prog 2 2)
  (1202-program-alarm prog))

(define orig-prog (string->intcode (file->string "input.day2")))

(define (try-verb-noun prog noun verb)
  (vector-set! prog 1 noun)
  (vector-set! prog 2 verb)
  (1202-program-alarm prog))

(for*/first ([noun (in-range 100)]
             [verb (in-range 100)]
             #:when (equal? 19690720
                            (try-verb-noun (vector-copy orig-prog) noun verb)))
  (+ verb (* 100 noun)))
