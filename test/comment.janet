(use ../src)
(use judge)

(defmacaron comment [] _
  (macaron lefts rights [;lefts ;rights]))

(defn foo [a (comment this is a comment)]
  (print a))

(test-macaron (print "hi" (comment bye))
  (print "hi"))
