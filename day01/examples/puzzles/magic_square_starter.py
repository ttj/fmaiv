"""Magic square as an SMT problem (Z3) — STARTER (fill in the TODOs).

Fill in (1) the all-different constraint and (2) the row / column / diagonal
sum constraints. When complete, this prints a valid N x N magic square: every
row, every column, and both main diagonals sum to the magic constant
M = N*(N^2 + 1)/2  (15 for N=3, 34 for N=4). Do not write any search code —
state what a solution *is* and let Z3 find it.

Run:  python magic_square_starter.py [N]   # default N=3
Goal: make the final line report `valid magic square ... ? True`.
Worked solution: magic_square.py
"""
import sys
import z3


def solve(n):
    # The magic constant every line must add up to (15 for n=3, 34 for n=4).
    M = n * (n * n + 1) // 2
    # One unknown integer per cell of the n x n grid.
    x = [[z3.Int(f"x_{r}_{c}") for c in range(n)] for r in range(n)]
    s = z3.Solver()
    # flat = every cell in one list, handy for the "use each number once" rule.
    flat = [x[r][c] for r in range(n) for c in range(n)]
    for v in flat:
        s.add(v >= 1, v <= n * n)     # GIVEN: every value is in 1..n^2

    # TODO (1): use each of 1..n^2 exactly once.
    #   With the 1..n^2 range above, z3.Distinct(flat) forces exactly that.
    #   Add that one constraint here.

    # TODO (2): every row, every column, and both diagonals total M.
    #   rows:       for each r in range(n):  s.add(z3.Sum(x[r]) == M)
    #   columns:    for each c in range(n):  s.add(z3.Sum([x[r][c] for r in range(n)]) == M)
    #   main diag:  s.add(z3.Sum([x[i][i]         for i in range(n)]) == M)
    #   anti diag:  s.add(z3.Sum([x[i][n - 1 - i] for i in range(n)]) == M)
    #
    # Until you add (1) and (2), Z3 returns any in-range grid (not magic), and
    # the self-check at the bottom prints False.

    if s.check() != z3.sat:
        return None, M
    m = s.model()
    # model_completion=True gives a concrete value even for cells Z3 left free.
    return [[m.evaluate(x[r][c], model_completion=True).as_long()
             for c in range(n)] for r in range(n)], M


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    grid, M = solve(n)
    if grid is None:
        print(f"N={n}: unsat (no magic square)")
        raise SystemExit(1)
    w = len(str(n * n))
    for row in grid:
        print(" ".join(str(v).rjust(w) for v in row))
    # Self-check — prints False until the TODOs are done (no crash either way).
    uses_each = sorted(v for row in grid for v in row) == list(range(1, n * n + 1))
    rows_ok = all(sum(row) == M for row in grid)
    cols_ok = all(sum(grid[r][c] for r in range(n)) == M for c in range(n))
    diag_ok = sum(grid[i][i] for i in range(n)) == M
    anti_ok = sum(grid[i][n - 1 - i] for i in range(n)) == M
    valid = uses_each and rows_ok and cols_ok and diag_ok and anti_ok
    print(f"\nN={n}: valid magic square (M={M})? {valid}  "
          f"(should be True once the TODOs are filled in)")
