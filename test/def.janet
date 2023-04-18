(use ../src)
(use judge)

(defmacaron def [] [name value]
  (macaron [& lefts] [& rights]
    ~(,;lefts (let [,name ,value] ,;rights))))

(test-macaron (do (def x 1) (+ x 1))
  (do
    (let
      [x 1]
      (+ x 1))))

(test-macaron (do (def x 10) (def y 20) (+ x y))
  (do
    (let
      [x 10]
      (let
        [y 20]
        (+ x y)))))
