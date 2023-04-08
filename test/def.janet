(use ../src)
(use judge)

(defmacaron def [] [name value]
  (macaron [& lefts] [& rights]
    ~(,;lefts (let [,name ,value] ,;rights))))

(test-macaroni (do (def x 1) (+ x 1))
  (do
    (let
      [x 1]
      (+ x 1))))
