(use ../src)
(use judge)

(defmacaron get! [] [table key]
  (macaron [& lefts] [& rights]
    (if (= lefts ['set])
      ~(put ,table ,key ,;rights)
      ~(,;lefts (get ,table ,key) ,;rights))))

(test-macaron
  (do
    (set (get! tab :key) :value)
    (print (get! tab :key)))
  (do
    (put tab :key :value)
    (print (get tab :key))))

# something that's janky about this
# is that it only works if it's literally
# preceded by `set` -- so it doesn't compose
# very well with other syntax extensions:

(defmacaron = [name] [value]
  ~(set ,name ,value))

(test-macaron (x = 1)
  (set x 1))

(test-macaron ((foo bar) = 1)
  (set (foo bar) 1))

(test-macaron ((get! x :foo) = 1)
  (set (get x :foo) 1))
# :(

# i think this is fixable by evaluating macarons
# a less eagerly -- right now we force it to expand
# into an abstract syntax tree as soon as it's
# encountered. we could instead defer the expansion
# and re-check if it's "ready" to expand whenever its
# surrounding context changes. i don't know if that's
# worth it, though.
