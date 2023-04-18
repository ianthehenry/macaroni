(use ../src)
(use judge)

(defn drop-last [xs]
  (take (- (length xs) 1) xs))

(defmacaron . lefts [key & rights]
  ~(,;(drop-last lefts)
    (get ,(last lefts) ,(keyword key))
    ,;rights))

(test-macaron (do (as x map [1 2 3]) (+ x 1))
  (do
    (as x map [1 2 3])
    (+ x 1)))

(test-macaron (print foo . bar)
  (print (get foo :bar)))
