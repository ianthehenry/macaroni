(use ../src)
(use judge)

(defmacaron as [] [name f arg]
  (macaron lefts rights
    ~(,;lefts (,f (fn [,name] ,;rights) ,arg))))

(test-macaron (do (as x map [1 2 3]) (+ x 1))
  (do
    (map (fn [x] (+ x 1)) [1 2 3])))

(test-macaron
  (defn add [xs ys]
    (as x mapcat xs)
    (as y map ys)
    (+ x y))
  (defn
    add
    [xs ys]
    (mapcat (fn [x] (map (fn [y] (+ x y)) ys)) xs)))

(test-macaron (pp (as x map [1 2 3]) (+ x 1))
  (pp (map (fn [x] (+ x 1)) [1 2 3])))
