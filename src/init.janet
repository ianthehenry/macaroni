#!/usr/bin/env janet

(use judge)
(use ./util)

(def- macaron-proto @{:expand (fn [self left right]
  ((self :f) left right))})

(defn- macaron* [f]
  (table/setproto @{:f f} macaron-proto))

(defmacro macaron [left right & body]
  ~(,macaron* (fn mac [,left ,right] ,;body)))

(defn- macaron? [x]
  (and (table? x) (= (table/getproto x) macaron-proto)))

(def- *macarons* (gensym))

(defmacro defmacaron [name before after & body]
  ~(,put (,setdyn ',*macarons* (,dyn ',*macarons* @{})) ',name
    (as-macro ,macaron ,before ,after ,;body)))

(var- expand nil)

(defn macaronex1 [form]
  (when (macaron? form)
    (break form))
  (var result @[])
  (def orig result)
  (eachp [i x] form
    (def x (expand x))
    (if (macaron? x)
      (let [left (chill result)
            right (drop (+ i 1) form)]
        (set result (:expand x left right))
        (break))
      (array/push result x)))
  (if (= orig result)
    (chill result)
    result))

(defn macaronex [form]
  (fix macaronex1 form))

(varfn expand [form]
  (if (macaron? form)
    form
    (case (type+ form)
      :symbol (or (in (dyn *macarons* @{}) form) form)
      :ptuple (macaronex form)
      (walk expand form))))

(defmacro macaroni [form]
  (expand form))

(defmacro* test-macaron [exp & args]
    ~(test-macro (as-macro ,macaroni ,exp) ,;args))
