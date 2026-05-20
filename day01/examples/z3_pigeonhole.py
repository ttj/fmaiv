"""Day 1 — pigeonhole principle encoded as SAT.

Place N+1 pigeons into N holes. Each pigeon must go into exactly one
hole; no two pigeons share a hole. The principle says this is unsat
for every N >= 1.

We encode it as propositional SAT inside Z3:
  p[i][j] = "pigeon i is in hole j"
"""
import z3


def pigeonhole(num_pigeons: int, num_holes: int) -> z3.CheckSatResult:
    s = z3.Solver()

    # p[i][j] : Bool
    p = [
        [z3.Bool(f"p_{i}_{j}") for j in range(num_holes)]
        for i in range(num_pigeons)
    ]

    # each pigeon is in at least one hole
    for i in range(num_pigeons):
        s.add(z3.Or(p[i]))

    # no two pigeons share a hole
    for j in range(num_holes):
        for i1 in range(num_pigeons):
            for i2 in range(i1 + 1, num_pigeons):
                s.add(z3.Not(z3.And(p[i1][j], p[i2][j])))

    return s.check()


if __name__ == "__main__":
    for n in [1, 2, 3, 4, 5]:
        result = pigeonhole(n + 1, n)
        print(f"  {n + 1} pigeons into {n} holes: {result}")
    print("\nClassic result: unsat for every n >= 1.")
