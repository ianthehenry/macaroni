(use ../src)
(use judge)

(defn drop-last [xs]
  (take (- (length xs) 1) xs))

# right-associative:

(defmacaron @ [& left] [& right]
  ~(,;(drop-last left) (cons ,(last left) ,;right)))

(test-macaroni (do 1 @ [])
  (do
    (cons 1 [])))

(test-macaroni (1 @ 2 @ [])
  ((cons 1 (cons 2 []))))

(test-macaroni (length 1 @ 2 @ [])
  (length (cons 1 (cons 2 []))))

# left-associative:

(defmacaron @@ [& left] [& right]
  ~(,;(drop-last left) (cons ,(last left) ,(first right)) ,;(drop 1 right)))

(test-macaroni (do 1 @@ 2 @@ [])
  (do
    (cons (cons 1 2) [])))

# mixing left and right associativity

(test-macaroni (do 1 @@ 2 @ 3 @@ 4 @ [])
  (do
    (cons (cons 1 2) (cons (cons 3 4) []))))

# Very very simple precedence:

(defn singleton [x] (case (length x) 1 x [x]))

(defmacaron + [& left] [& right]
  ~(,+ ,;(singleton left) ,;(singleton right)))

(defmacaron * [& left] [& right]
  (case (length right)
    1 ~(,* ,;(singleton left) ,(first right))
    ~((,* ,;(singleton left) ,(first right)) ,;(drop 1 right))))

(test-macaroni (1 + 2)
  (@+ 1 2))

(test-macaroni (1 + 2 * 3)
  (@+ 1 (@* 2 3)))

(test-macaroni (1 * 2 + 3)
  (@+ (@* 1 2) 3))

(test-macaroni (1 * 2 + 3 * 4)
  (@+ (@* 1 2) (@* 3 4)))

(test-macaroni (1 * 2 + 3 * 4)
  (@+ (@* 1 2) (@* 3 4)))

(test-macaroni (1 * 2 + 3 * 4 * 5)
  (@+ (@* 1 2) (@* (@* 3 4) 5)))

(test-macaroni (1 * 2 + 3 * 4 * 5 + 6)
  (@+ (@* 1 2) (@+ (@* (@* 3 4) 5) 6)))
