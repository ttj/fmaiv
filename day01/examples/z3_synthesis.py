"""Synthesis as ∃∀ solving (Z3): let the solver FIND the parameter — taster.

Verification asks "does the property hold?" — a ∀ question. *Synthesis* asks
"is there a parameter that MAKES it hold?" — an ∃∀ question. SMT handles both;
the only new ingredient is a quantified variable Z3 must solve for.

Task: find an integer offset k such that for EVERY x in 0..9, x + k lands in
the decade 10..19.

        ∃k. ∀x. (0 ≤ x ≤ 9)  →  (10 ≤ x + k ≤ 19)

(x = 0 forces k ≥ 10; x = 9 forces k ≤ 10; so k = 10 is the unique answer.)

Run:  python z3_synthesis.py
"""
import z3

k = z3.Int("k")        # the unknown we are SYNTHESIZING (the ∃)
x = z3.Int("x")        # the universally-quantified input (the ∀)

s = z3.Solver()
# One assertion with an inner ForAll: "the chosen k works for all x in range".
s.add(z3.ForAll([x], z3.Implies(z3.And(x >= 0, x <= 9),
                                z3.And(x + k >= 10, x + k <= 19))))

print("synthesis query:  exists k. forall x in [0,9]. x+k in [10,19]")
if s.check() == z3.sat:
    kv = s.model()[k]
    print(f"  Z3 found  k = {kv}")
    assert kv.as_long() == 10, "the unique solution is k = 10"
    # Independent re-check of the synthesized k over the whole domain.
    assert all(10 <= xi + 10 <= 19 for xi in range(10))
    print("  verified: x + 10 maps [0,9] exactly onto [10,19]")
else:
    print("  unsat: no such k")
    raise SystemExit(1)
