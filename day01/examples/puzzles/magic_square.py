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
    M = n * (n * n + 1) // 2
    x = [[z3.Int(f"x_{r}_{c}") for c in range(n)] for r in range(n)]
    s = z3.Solver()
    flat = [x[r][c] for r in range(n) for c in range(n)]
    for v in flat:
        s.add(v >= 1, v <= n * n)
    s.add(z3.Distinct(flat))
    for r in range(n):
        s.add(z3.Sum(x[r]) == M)                                  # rows
    for c in range(n):
        s.add(z3.Sum([x[r][c] for r in range(n)]) == M)           # columns
    s.add(z3.Sum([x[i][i] for i in range(n)]) == M)               # main diagonal
    s.add(z3.Sum([x[i][n - 1 - i] for i in range(n)]) == M)       # anti-diagonal
    if s.check() != z3.sat:
        return None, M
    m = s.model()
    return [[m.evaluate(x[r][c]).as_long() for c in range(n)] for r in range(n)], M


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    grid, M = solve(n)
    if grid is None:
        print(f"N={n}: unsat (no magic square)")
        raise SystemExit(1)
    w = len(str(n * n))
    for row in grid:
        print(" ".join(str(v).rjust(w) for v in row))
    # Self-check.
    assert sorted(v for row in grid for v in row) == list(range(1, n * n + 1))
    assert all(sum(row) == M for row in grid)
    assert all(sum(grid[r][c] for r in range(n)) == M for c in range(n))
    assert sum(grid[i][i] for i in range(n)) == M
    assert sum(grid[i][n - 1 - i] for i in range(n)) == M
    print(f"\nN={n}: valid magic square (constant M={M}).")
