(use ../src)
(use judge)

(defmacaron plus [& left] [& right] ~(+ ,;left ,;right))

(test-macaron (1 plus 2)
  (+ 1 2))

(test-macaron (2 plus 3 4)
  (+ 2 3 4))

(test-macaron (1 plus 2 plus 3)
  (+ + 1 2 3))

(test-macaron (+ 1 (2 plus 3 4))
  (+ 1 (+ 2 3 4)))
