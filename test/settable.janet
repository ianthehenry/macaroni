(use ../src)
(use judge)

(defmacaron in [] [table key]
  (macaron [& lefts] [& rights]
    (if (= lefts ['set])
      ~(put ,table ,key ,;rights)
      ~(,;lefts (in ,table ,key) ,;rights))))

(test-macaroni
  (do
    (set (in tab :key) :value)
    (print (in tab :key)))
  (do
    (put tab :key :value)
    (print (in tab :key))))
