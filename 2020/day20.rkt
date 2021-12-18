#lang racket

(define input (file->string "day20.input"))

;; PART 1

#|
the image can be rotated or flipped along an axis.
each image has 4 borders;
left to right, top to bottom, each encoded edge should match the neighbors
top, left, right, bottom: nums representing images left to right, top to bottom
tile: vector of four numbers, a start index, and a bit for if flipped
  if not rotated: TOP, RIGHT, BOTTOM, LEFT
  if rotated: -TOP, LEFT, -BOTTOM, RIGHT
matching left to right: i.right == (i+1).left (unrotated!)
EDGE_LENGTH = square root of num tiles
for tile in tiles
  for edge in tile.edges + tile.edges.reversed
    ; edge is now top edge of top left corner
    try building grid with this start piece, if it fails continue,
    otherwise return the successful arrangement
buildgrid(constraint, world, pieces-left):
  if no pieces-left, return world
  for piece in pieces-left
    for edge in piece.edges + piece.edges.reversed
      if(fullfills-constraints(constraints, world, piece with this orientation)
        add piece to world, buildgrid(new constraint, new world, pieces-left minus piece)
      else
        continue
  if we get through both loops, we fail, so return false
fulfills-constraints(constraints, world, piece with this orientation):
  world fills in left to right, top to bottom.
  depending on position, have to match left, above, or both
  get x, y position of new piece.
  if x > 0, match left border with right border of (x-1),y. If no, return false
  if y > 0, match top border with bottom border of x,(y-1)? if no, return false

hash edge to set of tiles
can find the matching tiles to a specific edge
might need to hash to pair of edge and flipped? or even edge and constraint
then, iteratively build up by looking at matching edges and seeing if the piece has already been used.


|#
(struct tile (id edges r-edges data) #:transparent)
(struct constraint (rotation flipped) #:transparent)

(define tiles-strings (string-split input "\n\n"))

(define (parse-tile line)
  (let* ([lines (string-split line)]
         [tid (string->number (string-trim (second lines) ":"))]
         [left (map (compose1 first string->list) (cddr lines))]
         [right (map (compose1 last string->list) (cddr lines))]
         [top (string->list (third lines))]
         [bottom (string->list (last lines))])
    (tile
     tid
     (list top right (reverse bottom) (reverse left))
     (list (reverse top) left bottom (reverse right))
     ; data
     ; for each row in chars
     ; skip row 0 and row edge-length-1
     ; skip col 0 and col edge-length-1
     (list->vector
      (string->list
       (apply string-append
              (for/list ([(l i) (in-indexed (cddr lines))]
                         #:when (and
                                 (i . > . 0)
                                 (i . < . (- (length (cddr lines)) 1))))
                (substring l 1 (- (string-length l) 1)))))))))

(define tiles (list->set (map parse-tile tiles-strings)))

;; (for/list ([x (in-set tiles)])
;;   (tile-data x))

(define tile-image-length (sqrt (vector-length (tile-data (set-first tiles)))))

(define edge-length (sqrt (set-count tiles)))

(define (world-at world x y)
  (list-ref world (- (length world) (+ (* y edge-length) x) 1)))

(define (match-left world piece pieces-left)
  (let* ([t (first piece)]
         [c (second piece)]
         [edge (if (constraint-flipped c)
                   (list-ref (tile-r-edges t)
                             (modulo (+ (constraint-rotation c) 1) 4))
                   (list-ref (tile-edges t)
                             (modulo (+ (constraint-rotation c) 1) 4)))]
         [candidates (hash-ref edge-hash (reverse edge))])
    (if (set-empty? candidates)
        #f
        (for/or ([cand (in-set candidates)])
          (and (set-member? pieces-left (car cand))
               (let ([cand-t (first cand)]
                     [cand-e (second cand)])
                 (build-grid (cons (list cand-t
                                         (constraint (modulo (+ 1 (constraint-rotation cand-e)) 4)
                                                     (constraint-flipped cand-e)))
                                   world)
                             (set-remove pieces-left cand-t))))))))

(define (match-top world piece pieces-left)
  (let* ([t (first piece)]
         [c (second piece)]
         [edge (if (constraint-flipped c)
                   (list-ref (tile-r-edges t)
                             (modulo (+ (constraint-rotation c) 2) 4))
                   (list-ref (tile-edges t)
                             (modulo (+ (constraint-rotation c) 2) 4)))]
         [candidates (hash-ref edge-hash (reverse edge))])
    (if (set-empty? candidates)
        #f
        (for/or ([c (in-set candidates)])
          (and (set-member? pieces-left (car c))
               (build-grid (cons c world)
                           (set-remove pieces-left (first c))))))))

(define (valid-rotation? c top-candidates)
  ; is there an element in top-candidates that matches c (tile constraint)?
  ; Here, the constraint on C is the orientation of the left matching edge.
  (let ([straint (constraint
                  (modulo (+ 1 (constraint-rotation (second c))) 4)
                  (constraint-flipped (second c)))])
    (for/or ([t (in-set top-candidates)])
      (equal? (list (car c) straint) t))))

(define (match-both world left top pieces-left)
  (let* ([left-t (first left)]
         [left-c (second left)]
         [top-t (first top)]
         [top-c (second top)]
         [left-edge (if (constraint-flipped left-c)
                        (list-ref (tile-r-edges left-t)
                                  (modulo (+ (constraint-rotation left-c) 1) 4))
                        (list-ref (tile-edges left-t)
                                  (modulo (+ (constraint-rotation left-c) 1) 4)))]
         [top-edge (if (constraint-flipped top-c)
                       (list-ref (tile-r-edges top-t)
                                 (modulo (+ (constraint-rotation top-c) 2) 4))
                       (list-ref (tile-edges top-t)
                                 (modulo (+ (constraint-rotation top-c) 2) 4)))]
         [left-candidates (hash-ref edge-hash (reverse left-edge))]
         [top-candidates (hash-ref edge-hash (reverse top-edge))])
    (if (or
         (set-empty? left-candidates)
         (set-empty? top-candidates))
        #f
        (for/or ([c (in-set left-candidates)])
          (and
           (set-member? pieces-left (car c))
           (valid-rotation? c top-candidates)
           (let ([t (first c)]
                 [e (second c)])
             (build-grid (cons (list t
                                     (constraint (modulo (+ 1 (constraint-rotation e)) 4)
                                                 (constraint-flipped e)))
                               world)
                         (set-remove pieces-left (first c)))))))))

(define (build-grid world pieces-left)
  (when (> (length world) (set-count tiles))
    (error "TOO BIG"))
  ; NOTE: world is REVERSE
  (if (set-empty? pieces-left)
      (reverse world)
      (let-values ([(y x) (quotient/remainder (length world) edge-length)])
        (cond
          [(and (x . > . 0) (y . > . 0)) (match-both
                                          world
                                          (world-at world (- x 1) y)
                                          (world-at world x (- y 1))
                                          pieces-left)]
          [(x . > . 0) (match-left
                        world
                        (world-at world (- x 1) y)
                                  pieces-left)]
          [(y . > . 0) (match-top
                        world
                        (world-at world x (- y 1))
                        pieces-left)]
          [else
           (for/or ([piece (in-set pieces-left)])
             (for*/or ([rot (in-range 4)]
                       [flipped '(#f #t)])
               (build-grid (list (list piece (constraint rot flipped)))
                           (set-remove pieces-left piece))))]))))

(define (construct-world)
  (build-grid '() tiles))

(define (add-tile-to-hash hsh t)
  (let* ([edges (tile-edges t)]
         [e-straints (list
                      (constraint 0 #f)
                      (constraint 1 #f)
                      (constraint 2 #f)
                      (constraint 3 #f))]
         [r-edges (tile-r-edges t)]
         [r-e-straints (list
                        (constraint 0 #t)
                        (constraint 1 #t)
                        (constraint 2 #t)
                        (constraint 3 #t))])
    (let loop ([e (map list
                       (append edges r-edges)
                       (append e-straints r-e-straints))]
               [h hsh])
      (if (empty? e)
          h
          (let* ([elem (car e)]
                 [edge (car elem)]
                 [straint (second elem)]
                 [tiles (hash-ref h edge set)])
            (loop (cdr e) (hash-set h edge
                                    (set-add tiles (list t straint)))))))))

(define edge-hash
  (foldl (lambda (x h) (add-tile-to-hash h x)) (hash) (set->list tiles)))

(define oriented (construct-world))

(let* ([l (- edge-length 1)]
       [a (world-at oriented 0 0)]
       [b (world-at oriented 0 l)]
       [c (world-at oriented l 0)]
       [d (world-at oriented l l)])
  (* (tile-id (car a))
     (tile-id (car b))
     (tile-id (car c))
     (tile-id (car d))))

;; PART 2

#|
A monster is 20 wide by 3 tall
List of locations that should all be # to count a monster.
Try each of 8 orientations for the monster image to find it
Only exists in one orientation, so can use for/or
1. Turn oriented into vector of all data
2. walk through each monster orientation to count matches

abc
def
ghi
row123
col123

rot1
cfi
beh
adg
col321
row123

rot2
ihg
fed
cba
row321
col321

rot3
gda
heb
ifc
col123
row321

flipped
cba
fed
ihg
row123
col321

rot1
adg
beh
cfi
col123
row123

rot2
ghi
def
abc
row321
col123

rot3
ifc
heb
gda
col321
row321

rotating 90 degrees means flipping the loop order and reversing the outer loop direction
flipped just starts the inner loop reversed
|#

(define (rotate-iters outr inr dir times l w)
  ; t for outr/inr means ascending order
  (if (equal? times 0)
      (cond
        [(and outr inr) (values 0 l 1
                                0 w 1
                                dir)]
        [(and outr (not inr)) (values 0 l 1
                                      (- w 1) -1 -1
                                      dir)]
        [(and (not outr) inr) (values (- l 1) -1 -1
                                      0 w 1
                                      dir)]
        [else (values (- l 1) -1 -1
                      (- w 1) -1 -1
                      dir)])
      (rotate-iters (not inr) outr
                    (if (equal? dir 'row) 'col 'row)
                    (- times 1)
                    w l)))

(define (get-iteration flipped rot l w)
  (if flipped
      (rotate-iters #t #f 'row rot l w)
      (rotate-iters #t #t 'row rot l w)))

(define (make-image-vector)
  (let ([res (make-vector (* tile-image-length tile-image-length
                             edge-length edge-length))])
    (for ([(piece idx) (in-indexed oriented)])
      (let*-values ([(tile) (first piece)]
                    [(rot) (second piece)]
                    [(piece-y piece-x) (quotient/remainder idx edge-length)]
                    [(o-start o-end o-inc i-start i-end i-inc o-dir)
                     (get-iteration (constraint-flipped rot)
                                    (constraint-rotation rot)
                                    tile-image-length
                                    tile-image-length)])
        (for* ([(j y) (in-indexed (in-range o-start o-end o-inc))]
               [(i x) (in-indexed (in-range i-start i-end i-inc))])
          ; x,y is the address in the output vector
          ; i,j is the address in the input vector
          ; if o-dir == 'col: idx = j * tile-image-length + i
          ; if o-dir == 'row: idx = i * tile-image-length + j
          (let* ([ix (if (equal? o-dir 'row)
                         (+ (* j tile-image-length) i)
                         (+ (* i tile-image-length) j))]
                 [val (vector-ref (tile-data tile) ix)]
                 [res-idx (+ (* piece-y tile-image-length tile-image-length edge-length)
                             (* y tile-image-length edge-length)
                             (* piece-x tile-image-length)
                             x)])
            (vector-set! res res-idx val)))))
    res))

(define image (make-image-vector))
(define (print-image i)
  (for ([x (in-range (* tile-image-length edge-length))])
    (for ([y (in-range (* tile-image-length edge-length))])
      (printf "~a" (vector-ref i (+ (* y tile-image-length edge-length) x))))
    (newline)))

(print-image image)

(define monster
#|
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   
|#
  '((18 . 0)
    (0 . 1)
    (5 . 1)
    (6 . 1)
    (11 . 1)
    (12 . 1)
    (17 . 1)
    (18 . 1)
    (19 . 1)
    (1 . 2)
    (4 . 2)
    (7 . 2)
    (10 . 2)
    (13 . 2)
    (16 . 2)))

(define (is-monster x y image i-inc i-start o-inc o-start o-dir)
  (for/and ([loc (in-list monster)])
    (let* ([loc-x (car loc)]
           [loc-y (cdr loc)]
           [i (if (equal? o-dir 'row)
                  (* i-inc (- loc-x i-start))
                  (* i-inc (- loc-y i-start)))]
           [j (if (equal? o-dir 'row)
                  (* o-inc (- loc-y o-start))
                  (* o-inc (- loc-x o-start)))])
      ; check that location x+i,y+j is #\# in the image
      (equal? #\# (vector-ref image (+ (+ x i)
                                       (* (+ y j) tile-image-length edge-length)))))))

(define (count-monsters i flip rot)
  (let-values ([(o-start o-end o-inc i-start i-end i-inc o-dir)
                (get-iteration flip rot 3 20)]
               [(res) 0])
    (for* ([y (in-range (- (* tile-image-length edge-length)
                           (abs (- o-end o-start))))]
           [x (in-range (- (* tile-image-length edge-length)
                           (abs (- i-end i-start))))])
      (when (is-monster x y i i-inc i-start o-inc o-start o-dir)
        (set! res (+ res 1))))
    res))

(define (count-all-monsters i)
  (for*/or ([flipped '(#f #t)]
            [rotation '(0 1 2 3)])
    (let ([c (count-monsters i flipped rotation)])
      (if (> c 0)
          c
          #f))))

(define (determine-roughness image)
  (- (vector-count (lambda (x) (equal? #\# x)) image)
     (* (count-all-monsters image) (length monster))))

(determine-roughness image)
