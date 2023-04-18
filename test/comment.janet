(use ../src)
(use judge)

(defmacaron comment [] _
  (macaron lefts rights [;lefts ;rights]))

(test-macaron (print "hi" (comment bye))
  (print "hi"))
