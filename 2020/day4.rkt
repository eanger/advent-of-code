#lang racket

(define input (file->string "day4.input"))

;; PART 1

(define pports (string-split input "\n\n"))

(define (make-passport entries)
  (make-hash (map (lambda (x)
                    (let ([vals (string-split x ":")])
                      (cons (car vals) (cadr vals))))
                  (string-split entries))))

(define (is-valid-passport? pport)
  (and
   (hash-has-key? pport "byr")
   (hash-has-key? pport "iyr")
   (hash-has-key? pport "eyr")
   (hash-has-key? pport "hgt")
   (hash-has-key? pport "hcl")
   (hash-has-key? pport "ecl")
   (hash-has-key? pport "pid")
   ;; (hash-has-key? "cid" pport)
   ))
(count is-valid-passport? (map make-passport pports))


;; PART 2

(define (is-validated-passport? pport)
  (and
   (let ([val (hash-ref pport "byr" #f)])
     (and
      val
      (equal? 4 (string-length val))
      (string>=? val "1920")
      (string<=? val "2002")))
   (let ([val (hash-ref pport "iyr" #f)])
     (and
      val
      (equal? 4 (string-length val))
      (string>=? val "2010")
      (string<=? val "2020")))
   (let ([val (hash-ref pport "eyr" #f)])
     (and
      val
      (equal? 4 (string-length val))
      (string>=? val "2020")
      (string<=? val "2030")))
   (hash-has-key? pport "hgt")
   (let* ([val (hash-ref pport "hgt" #f)]
          [mtch (regexp-match #rx"^([0-9]*)(in|cm)$" val)])
     (and
      val
      mtch
      (case (caddr mtch)
        [("in") (and (string>=? (cadr mtch) "59")
                   (string<=? (cadr mtch) "76"))]
        [("cm") (and (string>=? (cadr mtch) "150")
                   (string<=? (cadr mtch) "193"))]
        [else #f])))
   (let ([val (hash-ref pport "hcl" #f)])
     (and
      val
      (equal? #\# (string-ref val 0))
      (for/and ([c (substring val 1)])
        (for/or ([i (in-string "abcdef1234567890")])
          (equal? i c)))))
   (let ([val (hash-ref pport "ecl" #f)])
     (member val '("amb" "blu" "brn" "gry" "grn" "hzl" "oth")))
   (let ([val (hash-ref pport "pid" #f)])
     (and
      val
      (equal? 9 (string-length val))
      (for/and ([c val])
        (char-numeric? c))))
   ;; (hash-has-key? "cid" pport)
   ))
(count is-validated-passport? (map make-passport pports))
