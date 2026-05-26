; 3-coloring of C5 — the cycle graph on 5 vertices.
;
; Variables c1..c5 each take a color in {1, 2, 3}. C5 has 5 edges
; forming a single cycle: (c1,c2), (c2,c3), (c3,c4), (c4,c5), (c5,c1).
; Adjacent vertices must differ. Odd cycles have chromatic number 3
; (even cycles only need 2), so this query is SAT — Z3 returns a
; concrete 3-coloring as a model.
;
; Compare with z3_k4_3coloring.smt2: K4 forces 4 mutually-different
; colors and is UNSAT under 3 colors; C5 only constrains consecutive
; pairs around the cycle and is satisfiable.
;
; Run:     z3 day01/examples/z3_c5_3coloring.smt2
; Expect:  sat
;          (model ...)

(set-logic QF_LIA)
(set-info :status sat)

(declare-const c1 Int)
(declare-const c2 Int)
(declare-const c3 Int)
(declare-const c4 Int)
(declare-const c5 Int)

; each color is in {1, 2, 3}
(assert (and (<= 1 c1) (<= c1 3)))
(assert (and (<= 1 c2) (<= c2 3)))
(assert (and (<= 1 c3) (<= c3 3)))
(assert (and (<= 1 c4) (<= c4 3)))
(assert (and (<= 1 c5) (<= c5 3)))

; the 5 edges of C5: adjacent endpoints must differ
(assert (not (= c1 c2)))
(assert (not (= c2 c3)))
(assert (not (= c3 c4)))
(assert (not (= c4 c5)))
(assert (not (= c5 c1)))   ; close the cycle back to c1

(check-sat)
(get-model)
