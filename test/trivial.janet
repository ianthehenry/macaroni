(use ../src)
(use judge)

(defmacaron plus [& left] [& right] ~(+ ,;left ,;right))

(test-macaroni (1 plus 2)
  (+ 1 2))

(test-macaroni (2 plus 3 4)
  (+ 2 3 4))

(test-macaroni (1 plus 2 plus 3)
  (+ + 1 2 3))

(test-macaroni (+ 1 (2 plus 3 4))
  (+ 1 (+ 2 3 4)))
