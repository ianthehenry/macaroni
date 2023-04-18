(use ../src)
(use judge)

(def pipe (macaron [& before] [& after]
  (def subject (case (length before)
    0 (error "nothing to pipe!")
    1 (first before)
    before))

  (match after
    [f & args] [f subject ;args]
    [] (error "nothing to pipe!"))))

(defmacaron short-fn [] [form]
  (macaron [& before] [& after]
    [;before pipe form ;after]))

(test-macaron (x | f)
  (f x))

(test-macaron (x 1 | f)
  (f (x 1)))

(test-macaron (x 1 | f 2 3 | g 4)
  (g (f (x 1) 2 3) 4))
