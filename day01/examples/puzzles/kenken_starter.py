"""KenKen (Calcudoku) as an SMT problem (Z3) — STARTER (fill in the TODOs).

Fill in (1) the Latin-square constraints and (2) the per-operation cage
constraints. When complete, this prints the same grid as `kenken.py` and
reports a unique solution. Do not write any search code.

Operations to support: '+' (sum), '*' (product), '-' (|a-b|, 2 cells),
'/' (max/min, 2 cells, exact), '=' (single given cell).

Run:  python kenken_starter.py
"""
import z3

N = 4

# Each cage: (target, op, [(row, col), ...]).
CAGES = [
    (3,  "+", [(0, 0), (0, 1)]),
    (1,  "-", [(0, 2), (0, 3)]),
    (5,  "+", [(1, 0), (2, 0)]),
    (12, "*", [(1, 1), (1, 2)]),
    (2,  "/", [(1, 3), (2, 3)]),
    (5,  "+", [(2, 1), (2, 2)]),
    (6,  "*", [(3, 0), (3, 1)]),
    (4,  "*", [(3, 2), (3, 3)]),
]


def cage_constraint(x, target, op, cells):
    vs = [x[r][c] for (r, c) in cells]
    # TODO: return a Z3 boolean constraint encoding this cage.
    #   '+' -> z3.Sum(vs) == target
    #   '*' -> product of vs == target
    #   '-' -> two cells a,b with z3.Or(a-b==target, b-a==target)
    #   '/' -> two cells a,b with z3.Or(a==b*target, b==a*target)
    #   '=' -> vs[0] == target
    return z3.BoolVal(True)  # placeholder: no constraint yet


def solve():
    x = [[z3.Int(f"x_{r}_{c}") for c in range(N)] for r in range(N)]
    s = z3.Solver()
    for r in range(N):
        for c in range(N):
            s.add(x[r][c] >= 1, x[r][c] <= N)
        # TODO: every row is a Latin row (distinct values).
    # TODO: every column is distinct.
    for (target, op, cells) in CAGES:
        s.add(cage_constraint(x, target, op, cells))
    if s.check() != z3.sat:
        return None
    m = s.model()
    return [[m.evaluate(x[r][c], model_completion=True).as_long()
             for c in range(N)] for r in range(N)]


def show(grid):
    for row in grid:
        print(" ".join(str(v) for v in row))


if __name__ == "__main__":
    sol = solve()
    if sol is None:
        print("unsat (or constraints incomplete)")
        raise SystemExit(1)
    show(sol)
    rng = set(range(1, N + 1))
    ok = (all(set(sol[r]) == rng for r in range(N))
          and all({sol[r][c] for r in range(N)} == rng for c in range(N)))
    print("\nLatin square:", ok, "(should be True once all TODOs are done)")
