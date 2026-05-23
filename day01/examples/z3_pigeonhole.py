"""Day 1 — pigeonhole principle encoded as SAT.

Place N+1 pigeons into N holes. Each pigeon must go into exactly one
hole; no two pigeons share a hole. The principle says this is unsat
for every N >= 1.

We encode it as propositional SAT inside Z3:
  p[i][j] = "pigeon i is in hole j"

"SAT" just means the facts are all true/false statements (no arithmetic),
and Z3 looks for a true/false assignment that satisfies them. "unsat" here
means: no matter how you try, you cannot fit the pigeons -- which is exactly
the pigeonhole principle, proven mechanically.

Run:  python z3_pigeonhole.py
"""
import z3


def pigeonhole(num_pigeons: int, num_holes: int) -> z3.CheckSatResult:
    # Fresh solver to collect this puzzle's constraints.
    s = z3.Solver()

    # One Boolean variable per (pigeon, hole) pair. z3.Bool(name) is an
    # unknown that Z3 sets to True or False; p[i][j] True means
    # "pigeon i sits in hole j". p is a grid of these True/False unknowns.
    p = [
        [z3.Bool(f"p_{i}_{j}") for j in range(num_holes)]
        for i in range(num_pigeons)
    ]

    # Each pigeon must be in at least one hole. z3.Or(p[i]) is "at least one
    # of pigeon i's hole-variables is True" -- i.e. pigeon i is placed somewhere.
    for i in range(num_pigeons):
        s.add(z3.Or(p[i]))

    # No two pigeons share a hole. For every hole j and every pair of
    # distinct pigeons (i1, i2), forbid both sitting in j at once:
    # z3.And(...) = "both True"; z3.Not(...) = "that is not allowed".
    for j in range(num_holes):
        for i1 in range(num_pigeons):
            for i2 in range(i1 + 1, num_pigeons):   # i2 > i1 avoids checking a pair twice
                s.add(z3.Not(z3.And(p[i1][j], p[i2][j])))

    # Ask Z3: is there any True/False placement meeting all the rules?
    return s.check()


if __name__ == "__main__":
    # Try N = 1..5, each time stuffing N+1 pigeons into N holes (one too many).
    for n in [1, 2, 3, 4, 5]:
        result = pigeonhole(n + 1, n)
        print(f"  {n + 1} pigeons into {n} holes: {result}")
    print("\nClassic result: unsat for every n >= 1.")
