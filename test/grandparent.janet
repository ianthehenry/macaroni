(use ../src)
(use judge)

(defmacaron sploot [& lefts1] [& rights1]
  (macaron [& lefts2] [& rights2]
    (macaron [& lefts3] [& rights3]
      ~(,;lefts1 ,;lefts2 ,;lefts3 ,;rights1 ,;rights2 ,;rights3))))

(test-macaron (foo (bar (sploot tab) 1) 2)
  (bar foo tab 1 2))

(defmacaron ditto [& lefts] [& rights]
  (def index (length lefts))
  (macaron [& parent-lefts] [& parent-rights]
    (def previous-sibling (last parent-lefts))
    (def referent (in previous-sibling index))
    [;parent-lefts [;lefts referent ;rights] ;parent-rights]))

(test-macaron
  (do
    (print "hello")
    (print ditto))
  (do
    (print "hello")
    (print "hello")))

(defmacaron !$ [& lefts] [& rights]
  (macaron [& parent-lefts] [& parent-rights]
    (def previous-sibling (last parent-lefts))
    [;parent-lefts [;lefts (last previous-sibling) ;rights] ;parent-rights]))

(test-macaron
  (do
    (print "hello" "there")
    (print !$))
  (do
    (print "hello" "there")
    (print "there")))

(defn drop-last [list]
  (take (- (length list) 1) list))

(defmacaron !$ [& lefts] [& rights]
  (macaron [& parent-lefts] [& parent-rights]
    (def previous-sibling (last parent-lefts))
    (def up-to-previous-sibling (drop-last parent-lefts))
    (def referent (last previous-sibling))
    (with-syms [$x]
      ~(,;up-to-previous-sibling
        (let [,$x ,referent]
          (,;(drop-last previous-sibling) ,$x)
          (,;lefts ,$x ,;rights))
        ,;parent-rights))))

(test-macaron
  (do
    (print "hello" "there")
    (print !$))
  (do
    (let
      [<1> "there"]
      (print "hello" <1>)
      (print <1>))))
