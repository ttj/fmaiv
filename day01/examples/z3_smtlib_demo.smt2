; The SMT-LIB demo shown on the Day 1 "SMT-LIB: the standard input language" slide.
; Verify:  z3 z3_smtlib_demo.smt2   ->  sat, then a model with x+y=7, x>0, y>0.
(set-logic QF_LIA)               ; quantifier-free linear integer arithmetic
(declare-const x Int)            ; declare integer x
(declare-const y Int)
(assert (= (+ x y) 7))           ; x + y = 7
(assert (> x 0))                 ; x > 0
(assert (> y 0))                 ; y > 0
(check-sat)                      ; -> sat
(get-model)                      ; -> ((x 1) (y 6))  or any x,y > 0 with x+y=7
