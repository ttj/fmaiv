"""Entailment as unsatisfiability (Z3): validity vs. satisfiability — full solution.

A knowledge base KB *entails* a goal G  (written KB ⊨ G)  when G is true in
every model of KB. The standard way to check that with an SMT/SAT solver is the
refutation (a.k.a. "assert the negation") idiom:

        KB ⊨ G    iff    (KB ∧ ¬G) is UNSAT.

If KB ∧ ¬G is unsatisfiable there is no model of KB in which G fails, so the
entailment is valid. If it is satisfiable, the returned model is a
*counterexample*: a world where every premise holds but the goal does not.

This is the same UNSAT-means-proved idea you used on the counter ("no
counterexample of length N" = the bounded check is UNSAT), here for plain
first-order entailment. Worked example: the classic syllogism.

    Premise 1:  ∀x. Man(x) → Mortal(x)     (all men are mortal)
    Premise 2:  Man(socrates)              (Socrates is a man)
    Goal:       Mortal(socrates)           (therefore Socrates is mortal)

Run:  python z3_entailment.py
Starter: z3_entailment_starter.py
"""
import z3

# An uninterpreted sort "Person", and two predicates Person -> Bool.
Person = z3.DeclareSort("Person")
Man = z3.Function("Man", Person, z3.BoolSort())
Mortal = z3.Function("Mortal", Person, z3.BoolSort())
socrates = z3.Const("socrates", Person)


def entails(kb, goal):
    """Return (True, None) if kb ⊨ goal, else (False, counterexample model)."""
    s = z3.Solver()
    s.add(kb)                     # assume every premise
    s.add(z3.Not(goal))          # ...and the NEGATION of the goal (refutation idiom)
    if s.check() == z3.unsat:    # no model of KB falsifies the goal
        return True, None
    return False, s.model()      # a world where KB holds but the goal fails


if __name__ == "__main__":
    x = z3.Const("x", Person)
    kb = [z3.ForAll([x], z3.Implies(Man(x), Mortal(x))),   # all men are mortal
          Man(socrates)]                                    # Socrates is a man
    goal = Mortal(socrates)                                 # Socrates is mortal

    valid, _ = entails(kb, goal)
    print("KB |= Mortal(socrates) ?", "VALID" if valid else "NOT VALID")
    assert valid, "the syllogism should be valid"

    # Drop premise 2 (we no longer know Socrates is a man). The entailment must
    # fail: Z3 returns a countermodel - a Person who simply isn't a man.
    valid2, cex = entails([kb[0]], goal)
    print("Drop 'Man(socrates)' - still valid?",
          "VALID" if valid2 else "NOT VALID (countermodel found)")
    assert not valid2, "without premise 2 the goal is not entailed"

    print("\nentailment demo: both checks behaved as expected")
