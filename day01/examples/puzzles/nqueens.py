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
    # Trick that shrinks the problem: instead of a yes/no per square, use one
    # integer per row giving that row's queen column. With exactly one queen
    # per row built in, we never have to forbid two queens in the same row.
    q = [z3.Int(f"q_{i}") for i in range(n)]
    s = z3.Solver()
    # Each queen's column must be a real column index 0..n-1.
    for i in range(n):
        s.add(q[i] >= 0, q[i] < n)
    # No shared column: z3.Distinct(q) forces all the column numbers different.
    s.add(z3.Distinct(q))                      # distinct columns
    # No shared diagonal: two queens are on a diagonal exactly when the gap in
    # columns equals the gap in rows. j - i is the row gap (j > i); z3.Abs(...)
    # is the absolute column gap. Requiring them unequal blocks both diagonals.
    for i in range(n):
        for j in range(i + 1, n):
            s.add(z3.Abs(q[i] - q[j]) != j - i)  # distinct diagonals
    # Solve; unsat means no safe placement exists for this n.
    if s.check() != z3.sat:
        return None
    m = s.model()
    # Pull each row's chosen column out of the model as a plain int.
    return [m.evaluate(q[i]).as_long() for i in range(n)]


def show(cols):
    # Draw the board: in each row, put "Q" at the queen's column, "." elsewhere.
    n = len(cols)
    for i in range(n):
        print("".join("Q" if cols[i] == c else "." for c in range(n)))


def is_valid(cols):
    # Independent check that the placement really is attack-free.
    n = len(cols)
    # If the columns are a permutation of 0..n-1, every row and every column
    # has exactly one queen. (sorted == range checks "each column used once".)
    if sorted(cols) != list(range(n)):           # a permutation => rows+cols ok
        return False
    # Then verify no two queens share a diagonal, same gap test as above.
    return all(abs(cols[i] - cols[j]) != j - i
               for i in range(n) for j in range(i + 1, n))


if __name__ == "__main__":
    # Board size: first command-line argument, or 8 if none given.
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    cols = solve(n)
    if cols is None:
        # unsat. For n=2 and n=3 that is the correct mathematical answer (no
        # arrangement exists), so we exit 0 there and 1 (error) otherwise.
        print(f"N={n}: unsat (no placement exists)")
        raise SystemExit(0 if n in (2, 3) else 1)  # 2,3 genuinely have no solution
    show(cols)
    assert is_valid(cols), "placement is not attack-free"   # double-check Z3's answer
    print(f"\nN={n}: valid attack-free placement found.")
