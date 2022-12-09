#lang racket

(module+ test
  (require rackunit)
  (check-equal? (sum-dirs-under-100k "$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k") 95437))

(define test "$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k")

(define test2 "$ cd /
$ ls
dir a
$ cd a
$ ls
dir a
2 a.txt
$ cd a
$ ls
99999 a.txt")

; parent is just link to parent dir object
; should contents just be a map from name to either size or directory object?
(struct directory (name parent contents) #:transparent)

(define (parse-cmd cmd-lines curdir)
  (if (empty? cmd-lines)
      '()
      (let* ([cmd (car cmd-lines)]
             [rst (cdr cmd-lines)]
             [mtch (regexp-match #rx"\\$ (ls|cd) ?(.*)?" cmd)])
        (match (second mtch)
          ["ls" (do-ls rst curdir)]
          ["cd" (do-cd (third mtch) rst curdir)]
          [_ (parse-cmd rst curdir)]))))

(define (do-ls lines curdir)
  ; adds directories or files to this directory
  ; then parse next command based on (struct-copy directory curdir [files this-dir-files])
  ; subdirs should be added as keys in curdir?
  (let-values ([(content-lines others)
                (splitf-at lines (lambda (x) (not (char=? (string-ref x 0) #\$))))])
    (for ([line content-lines])
      (let ([words (string-split line " ")])
        (hash-set! (directory-contents curdir)
                   (second words)
                   (if (char=? (string-ref line 0) #\d)
                       (directory (second words) curdir (make-hash))
                       (first words)))))
    (parse-cmd others curdir)))

(define (do-cd dir lines curdir)
  ; if dir=="..", parse next command based on (directory-parent dir)
  ; else, parse next command based on (list-ref (directory-dirs dir) dir)
  (if (string=? dir "..")
      (parse-cmd lines (directory-parent curdir))
      (parse-cmd lines (hash-ref (directory-contents curdir) dir))))

(define (to-directory str)
  (let ([root (directory "/" #f (make-hash))])
    (parse-cmd
     (rest (string-split str "\n"))
     root)
    root))

(define (sum-contents val hsh)
  (if (directory? val)
      (let ([storage
             (apply + (map (lambda (x) (sum-contents x hsh)) (hash-values (directory-contents val))))])
        (hash-set! hsh val storage)
        storage)
      (string->number val)))

(define (sum-dirs-under-100k str)
  (let ([h (make-hash)])
    (sum-contents (to-directory str) h)
    (println
     (apply + (filter (lambda (x) (<= x 100000)) (hash-values h))))
    h))


(define p1
  (sum-dirs-under-100k (file->string "input.day7")))

(define (p2 p1)
  (let* ([sorted (sort (hash->list p1)
                       >
                       #:key cdr)]
         [root (car sorted)]
         [others (cdr sorted)]
         [needed (+ (- 30000000 70000000) (cdr root))])
    (cdr (last (takef others (lambda (x) (> (cdr x) needed)))))))

(p2 p1)
