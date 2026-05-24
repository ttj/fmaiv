"""Entailment as unsatisfiability (Z3) — STARTER (fill in the one TODO).

A knowledge base KB *entails* a goal G (KB ⊨ G) when G holds in every model of
KB. Check it with the refutation idiom:

        KB ⊨ G    iff    (KB ∧ ¬G) is UNSAT.

Your job: complete `entails` so it uses that idiom. When correct, the first
check prints VALID and the second prints NOT VALID (a countermodel).

Run:  python z3_entailment_starter.py
Worked solution: z3_entailment.py
"""
import z3

Person = z3.DeclareSort("Person")
Man = z3.Function("Man", Person, z3.BoolSort())
Mortal = z3.Function("Mortal", Person, z3.BoolSort())
socrates = z3.Const("socrates", Person)


def entails(kb, goal):
    """Return (True, None) if kb ⊨ goal, else (False, counterexample model)."""
    s = z3.Solver()
    s.add(kb)                     # assume every premise
    # TODO: add the NEGATION of the goal — this is the whole trick.
    #   KB ⊨ goal  iff  (KB ∧ ¬goal) is UNSAT.   Add:   s.add(z3.Not(goal))
    # Until you do, you are testing plain satisfiability of KB (almost always
    # SAT), so a valid argument is reported "NOT VALID".
    if s.check() == z3.unsat:
        return True, None
    return False, s.model()


if __name__ == "__main__":
    x = z3.Const("x", Person)
    kb = [z3.ForAll([x], z3.Implies(Man(x), Mortal(x))),   # all men are mortal
          Man(socrates)]                                    # Socrates is a man
    goal = Mortal(socrates)                                 # Socrates is mortal

    valid, _ = entails(kb, goal)
    print("KB |= Mortal(socrates) ?", "VALID" if valid else "NOT VALID",
          " (should be VALID once the TODO is filled in)")

    valid2, _ = entails([kb[0]], goal)
    print("Drop 'Man(socrates)' - still valid?",
          "VALID" if valid2 else "NOT VALID (countermodel found)",
          " (should be NOT VALID)")
