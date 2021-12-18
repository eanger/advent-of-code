#lang racket

(require racket/hash)

(define input (file->lines "day21.input"))

;; PART 1

#|
1. map allergen to intersection of sets
2. find a key-value pair with only one element in the value
3. remove that element from all other sets
4. repeat 2-3 until no sets have multiple elements
|#

(define (parse-line line)
  ; returns list of list of ingredients and list of allergens
  (let ([m
         (regexp-match #rx"^(.*) \\(contains (.*)\\)" line)])
    (list (string-split (second m))
          (string-split (third m) #rx"[ ,]+"))))

(define (add-allergen l hsh)
  (let* ([parsed (parse-line l)]
         [ingredients (list->set (first parsed))]
         [allergens (second parsed)])
    (apply hash-union
           (cons hsh
                 (map (lambda (x) (hash x ingredients))
                      allergens))
           #:combine set-intersect)))

(define (map-allergens lines)
  (foldl add-allergen (hash) lines))

(define allergens-hash (map-allergens input))

(define (id-allergens lst [res (hash)])
  (if (empty? lst)
      res
      (let* ([sorted (sort lst < #:key (lambda (x) (set-count (cdr x))))]
             [allergen (car (car sorted))]
             [ingredient (set-first (cdr (car sorted)))])
        (id-allergens (map
                        (lambda (x) (cons
                                     (car x)
                                     (set-remove (cdr x) ingredient)))
                        (cdr sorted))
                       (hash-set res ingredient allergen)))))

(define known-allergens (id-allergens (hash->list allergens-hash)))

(for/sum ([l input])
  (let ([items (car (parse-line l))]
        [keys (list->set (hash-keys known-allergens))])
    (for/sum ([i items]
              #:unless (set-member? keys i))
      1)))

;; PART 2

(define dangerous-ingredient-list
  (string-join
   (map car (sort (hash->list known-allergens) string<? #:key cdr))
   ","))
(displayln dangerous-ingredient-list)
