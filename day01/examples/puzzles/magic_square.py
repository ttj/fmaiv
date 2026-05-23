"""Magic square as an SMT problem (Z3) — full solution (bonus puzzle).

An N x N magic square uses each integer 1..N^2 exactly once, and every row,
every column, and both main diagonals sum to the magic constant
M = N*(N^2 + 1)/2  (M = 15 for N=3, 34 for N=4).

SMT encoding: one integer per cell (1..N^2), all Distinct, and one linear
equation per row, column, and diagonal.

Run:  python magic_square.py [N]   # default N=3
"""
import sys
import z3


def solve(n):
    # The magic constant every line must add up to. // is integer division;
    # the formula n*(n^2+1)/2 always comes out whole. (15 for n=3, 34 for n=4.)
    M = n * (n * n + 1) // 2
    # One unknown integer per cell of the n x n grid.
    x = [[z3.Int(f"x_{r}_{c}") for c in range(n)] for r in range(n)]
    s = z3.Solver()
    # flat = all the cells in one flat list, handy for the "use each number once" rule.
    flat = [x[r][c] for r in range(n) for c in range(n)]
    # Every value is between 1 and n^2.
    for v in flat:
        s.add(v >= 1, v <= n * n)
    # z3.Distinct(flat) = all cells differ; with the 1..n^2 range that forces
    # each of 1,2,...,n^2 to appear exactly once.
    s.add(z3.Distinct(flat))
    # z3.Sum(list) adds the entries. Require each row to total the magic constant M.
    for r in range(n):
        s.add(z3.Sum(x[r]) == M)                                  # rows
    # Same for each column (cells running top to bottom).
    for c in range(n):
        s.add(z3.Sum([x[r][c] for r in range(n)]) == M)           # columns
    # Main diagonal: cells x[0][0], x[1][1], ... also sum to M.
    s.add(z3.Sum([x[i][i] for i in range(n)]) == M)               # main diagonal
    # Anti-diagonal: top-right to bottom-left, x[i][n-1-i], sums to M too.
    s.add(z3.Sum([x[i][n - 1 - i] for i in range(n)]) == M)       # anti-diagonal
    # Solve. If impossible, hand back None (plus M so the caller can still print it).
    if s.check() != z3.sat:
        return None, M
    m = s.model()
    # Read every cell's value out as a plain int.
    return [[m.evaluate(x[r][c]).as_long() for c in range(n)] for r in range(n)], M


if __name__ == "__main__":
    # Grid size from the command line, default 3.
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    grid, M = solve(n)
    if grid is None:
        print(f"N={n}: unsat (no magic square)")
        raise SystemExit(1)
    # w = width of the largest number, so columns line up when printed.
    w = len(str(n * n))
    for row in grid:
        print(" ".join(str(v).rjust(w) for v in row))
    # Independent re-check of all the magic-square properties (asserts fail loudly):
    assert sorted(v for row in grid for v in row) == list(range(1, n * n + 1))  # uses 1..n^2 once
    assert all(sum(row) == M for row in grid)                                   # every row sums to M
    assert all(sum(grid[r][c] for r in range(n)) == M for c in range(n))        # every column sums to M
    assert sum(grid[i][i] for i in range(n)) == M                              # main diagonal
    assert sum(grid[i][n - 1 - i] for i in range(n)) == M                      # anti-diagonal
    print(f"\nN={n}: valid magic square (constant M={M}).")
