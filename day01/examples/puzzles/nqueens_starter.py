"""N-Queens as an SMT problem (Z3) — STARTER (fill in the TODOs).

Encode "no two queens attack each other" with q[i] = column of the queen in
row i. Fill the three TODOs; when complete, `python nqueens_starter.py 8`
prints a valid board.

Run:  python nqueens_starter.py [N]
"""
import sys
import z3


def solve(n):
    q = [z3.Int(f"q_{i}") for i in range(n)]
    s = z3.Solver()

    # TODO 1: each q[i] is a column in 0..n-1.

    # TODO 2: all columns distinct (no two queens in the same column).
    #         (hint: z3.Distinct(q))

    # TODO 3: no two queens on the same diagonal.
    #         (hint: for i < j, z3.Abs(q[i] - q[j]) != j - i)

    if s.check() != z3.sat:
        return None
    m = s.model()
    return [m.evaluate(q[i], model_completion=True).as_long() for i in range(n)]


def show(cols):
    n = len(cols)
    for i in range(n):
        print("".join("Q" if cols[i] == c else "." for c in range(n)))


def is_valid(cols):
    n = len(cols)
    if sorted(cols) != list(range(n)):
        return False
    return all(abs(cols[i] - cols[j]) != j - i
               for i in range(n) for j in range(i + 1, n))


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    cols = solve(n)
    if cols is None:
        print(f"N={n}: unsat / constraints incomplete")
        raise SystemExit(1)
    show(cols)
    print(f"\nN={n}: valid =", is_valid(cols), "(should be True once TODOs are done)")
