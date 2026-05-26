; 3-coloring of K4 — the complete graph on 4 vertices.
;
; Variables c1..c4 each take a color in {1, 2, 3}. K4 contains all 6
; possible edges, so every pair of vertices must get a different color.
; The chromatic number of Kn is n, so K4 needs 4 colors and this query
; is UNSAT — Z3 refutes it, certifying that 3 colors do not suffice.
;
; Run:     z3 day01/examples/z3_k4_3coloring.smt2
; Expect:  unsat

(set-logic QF_LIA)
(set-info :status unsat)

(declare-const c1 Int)
(declare-const c2 Int)
(declare-const c3 Int)
(declare-const c4 Int)

; each color is in {1, 2, 3}
(assert (and (<= 1 c1) (<= c1 3)))
(assert (and (<= 1 c2) (<= c2 3)))
(assert (and (<= 1 c3) (<= c3 3)))
(assert (and (<= 1 c4) (<= c4 3)))

; the 6 edges of K4: adjacent endpoints must differ
(assert (not (= c1 c2)))
(assert (not (= c1 c3)))
(assert (not (= c1 c4)))
(assert (not (= c2 c3)))
(assert (not (= c2 c4)))
(assert (not (= c3 c4)))

; Equivalent shorthand for the above six disequalities:
;   (assert (distinct c1 c2 c3 c4))
; Forcing four pairwise-distinct values into a 3-element domain is
; impossible, which is exactly why K4 is not 3-colorable.

(check-sat)
