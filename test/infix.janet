(use ../src)
(use judge)

(defn drop-last [xs]
  (take (- (length xs) 1) xs))

(defn singleton [x] (case (length x) 1 x [x]))

# right-associative:

(defmacaron @ [& left] [& right]
  ~(cons ,;(singleton left) ,;(singleton right)))

(test-macaron (1 @ [])
  (cons 1 []))

(test-macaron (1 @ 2 @ [])
  (cons 1 (cons 2 [])))

(test-macaron (foo bar @ 2 @ [])
  (cons (foo bar) (cons 2 [])))

# left-associative:

(defmacaron @@ [& left] [& right]
  (case (length right)
    1 ~(cons ,;(singleton left) ,(first right))
    ~((cons ,;(singleton left) ,(first right)) ,;(drop 1 right))))

(test-macaron (1 @@ 2 @@ [])
  (cons (cons 1 2) []))

# mixing left and right associativity

(test-macaron (1 @@ 2 @ 3 @@ 4 @ [])
  (cons (cons 1 2) (cons (cons 3 4) [])))

# Very very simple precedence:

(defmacaron + [& left] [& right]
  ~(,+ ,;(singleton left) ,;(singleton right)))

(defmacaron * [& left] [& right]
  (case (length right)
    1 ~(,* ,;(singleton left) ,(first right))
    ~((,* ,;(singleton left) ,(first right)) ,;(drop 1 right))))

(test-macaron (1 + 2)
  (@+ 1 2))

(test-macaron (1 + 2 + 3)
  (@+ 1 (@+ 2 3)))

(test-macaron (1 * 2)
  (@* 1 2))

(test-macaron (1 * 2 * 3)
  (@* (@* 1 2) 3))

(test-macaron (1 + 2 * 3)
  (@+ 1 (@* 2 3)))

(test-macaron (1 * 2 + 3)
  (@+ (@* 1 2) 3))

(test-macaron (1 * 2 + 3 * 4)
  (@+ (@* 1 2) (@* 3 4)))

(test-macaron (1 * 2 + 3 * 4)
  (@+ (@* 1 2) (@* 3 4)))

(test-macaron (1 * 2 + 3 * 4 * 5)
  (@+ (@* 1 2) (@* (@* 3 4) 5)))

(test-macaron (1 * 2 + 3 * 4 * 5 + 6)
  (@+ (@* 1 2) (@+ (@* (@* 3 4) 5) 6)))
