"""N-Queens as an SMT problem (Z3) — full solution.

Place N queens on an N x N board so that no two attack each other (no shared
row, column, or diagonal).

SMT encoding: one integer variable q[i] per row i giving the *column* of the
queen in that row (so two queens never share a row by construction). Then:
  - columns are distinct (no shared column);
  - no two queens share a diagonal: |q[i] - q[j]| != |i - j| for i < j.

Run:  python nqueens.py            # default N=8
      python nqueens.py 12         # any N
"""
import sys
import z3


def solve(n):
    """Return a list `cols` where cols[i] is the queen's column in row i, or None."""
    q = [z3.Int(f"q_{i}") for i in range(n)]
    s = z3.Solver()
    for i in range(n):
        s.add(q[i] >= 0, q[i] < n)
    s.add(z3.Distinct(q))                      # distinct columns
    for i in range(n):
        for j in range(i + 1, n):
            s.add(z3.Abs(q[i] - q[j]) != j - i)  # distinct diagonals
    if s.check() != z3.sat:
        return None
    m = s.model()
    return [m.evaluate(q[i]).as_long() for i in range(n)]


def show(cols):
    n = len(cols)
    for i in range(n):
        print("".join("Q" if cols[i] == c else "." for c in range(n)))


def is_valid(cols):
    n = len(cols)
    if sorted(cols) != list(range(n)):           # a permutation => rows+cols ok
        return False
    return all(abs(cols[i] - cols[j]) != j - i
               for i in range(n) for j in range(i + 1, n))


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    cols = solve(n)
    if cols is None:
        print(f"N={n}: unsat (no placement exists)")
        raise SystemExit(0 if n in (2, 3) else 1)  # 2,3 genuinely have no solution
    show(cols)
    assert is_valid(cols), "placement is not attack-free"
    print(f"\nN={n}: valid attack-free placement found.")
