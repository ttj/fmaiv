; Day 1 — SMT-LIB basics
;
; SMT-LIB is the input language Z3 reads on stdin. The point of this file
; is to read end-to-end and understand the four kinds of commands you will
; meet today:
;
;   1. (set-logic ...)    pick the background theory
;   2. (declare-const ...) introduce a free variable
;   3. (assert ...)       add a constraint
;   4. (check-sat)        ask the solver and (optionally) (get-model)
;
; Run with:   z3 z3_smt_basics.smt2

(set-logic QF_NIA)        ; quantifier-free non-linear integer arithmetic

(declare-const x Int)
(declare-const y Int)

(assert (= (+ (* x x) (* y y)) 25))   ; x^2 + y^2 = 25
(assert (> x 0))
(assert (> y 0))

(check-sat)
(get-model)
