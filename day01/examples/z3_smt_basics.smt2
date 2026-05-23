; Day 1 — SMT-LIB basics
;
; This is the same idea as the Python examples, but written in SMT-LIB:
; the plain-text language solvers like Z3 read directly. (A leading ';'
; starts a comment, like '#' in Python.) Everything is in (parentheses)
; with the operation written FIRST, so "x + y" is written "(+ x y)".
;
; The point of this file is to read end-to-end and understand the four
; kinds of commands you will meet today:
;
;   1. (set-logic ...)    pick the background theory
;   2. (declare-const ...) introduce a free variable
;   3. (assert ...)       add a constraint
;   4. (check-sat)        ask the solver and (optionally) (get-model)
;
; Run with:   z3 z3_smt_basics.smt2

; set-logic tells Z3 what kind of math to expect, so it can pick the right
; engine. QF_NIA = Quantifier-Free Non-linear Integer Arithmetic: whole
; numbers, no "for all"/"exists", and multiplication of variables allowed.
(set-logic QF_NIA)        ; quantifier-free non-linear integer arithmetic

; declare-const introduces an unknown whole number (Int). Like z3.Int("x")
; in Python: it names a value for Z3 to solve for.
(declare-const x Int)
(declare-const y Int)

; assert adds a fact that must hold. (* x x) is x*x and (+ ... ...) adds, so
; this whole line says x^2 + y^2 = 25. (= a b) means "a equals b".
(assert (= (+ (* x x) (* y y)) 25))   ; x^2 + y^2 = 25
(assert (> x 0))                       ; x is positive
(assert (> y 0))                       ; y is positive

; check-sat asks "can all the asserts be true at once?" -> prints sat/unsat.
; (Here: sat, since 3^2 + 4^2 = 25.)
(check-sat)
; get-model prints one assignment that works, e.g. x = 3, y = 4. Only
; meaningful right after check-sat reports sat.
(get-model)
