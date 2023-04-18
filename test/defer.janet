(use ../src)
(use judge)

(defmacaron defer [] [expr]
  (macaron [& lefts] [& rights]
    ~(,;lefts (finally (do ,;rights) ,expr))))

(test-macaron
  (do
    (def f (file/open "foo.txt"))
    (defer (file/close f))
    (do-something)
    (do-something-else))
  (do
    (def f (file/open "foo.txt"))
    (finally
      (do
        (do-something)
        (do-something-else))
      (file/close f))))
