(use ../src)
(use judge)

(defn drop-last [xs]
  (take (- (length xs) 1) xs))

(defmacaron else [] else-exprs
  (macaron lefts rights
    (match (last lefts)
      ['if & then-exprs]
        ~(,;(drop-last lefts)
          (if-then-else (do ,;then-exprs) (do ,;else-exprs))
          ,;rights)
      (error "else must come immediately after if"))))

(test-macaron (do
  (print "hi")
  (if x (print "okay")
    (print "cool"))
  (else (print "oh no")))
  (do
    (print "hi")
    (if-then-else (do x (print "okay") (print "cool")) (do (print "oh no")))))
