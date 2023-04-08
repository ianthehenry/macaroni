(use judge)

(defn type+ [x]
  (def t (type x))
  (case t
    :tuple (case (tuple/type x)
      :parens :ptuple
      :brackets :btuple
      (assert false))
    t))

(defn chill [x]
  (case (type x)
    :table (table/to-struct x)
    :array (tuple/slice x)
    :buffer (string x)
    x))

(defn fix [f x]
  (def x- (f x))
  (if (= x x-)
    x
    (fix f x-)))

(defn split-at [xs i]
  (if (or (< i 0) (>= i (length xs)))
    (error "index out of bounds"))
  [(take i xs)
   (drop (+ i 1) xs)])

(test (split-at [1 2 3 4] 0) [[] [2 3 4]])
(test (split-at [1 2 3 4] 1) [[1] [3 4]])
(test (split-at [1 2 3 4] 2) [[1 2] [4]])
(test (split-at [1 2 3 4] 3) [[1 2 3] []])
(test-error (split-at [1 2 3 4] 4) "index out of bounds")
(test-error (split-at [1 2 3 4] -3) "index out of bounds")

(defn with-map [src dest]
  (tuple/setmap dest ;(tuple/sourcemap src)))
