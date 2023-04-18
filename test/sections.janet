(use ../src)
(use judge)

(defmacaron + [& left] [& right]
  (case [(length left) (length right)]
    [0 0] (error "nothing to add")
    [1 0] (with-syms [$] ~(fn [,$] (,+ ,(first left) ,$)))
    [0 1] (with-syms [$] ~(fn [,$] (,+ ,$ ,(first right))))
    [1 1] ~(,+ ,(first left) ,(first right))
    (error "too many arguments")))

(test-error (macex1 '(macaroni (+))) "nothing to add")

(test-macaron (1 + 2)
  (@+ 1 2))

(test-macaron (1 + 2)
  (@+ 1 2))

(test-macaron (+ 1)
  (fn
    [<1>]
    (@+ <1> 1)))

(test-macaron (1 +)
  (fn
    [<1>]
    (@+ 1 <1>)))
