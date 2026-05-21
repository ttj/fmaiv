"""KenKen (a.k.a. Calcudoku) as an SMT problem (Z3) — full solution.

A KenKen is an N x N Latin square (every row and column holds 1..N exactly
once) partitioned into "cages". Each cage has a target value and an arithmetic
operation; the cage's cells must combine, under that operation, to the target:
  '+'  sum of the cells  == target
  '*'  product           == target
  '-'  |a - b|           == target   (exactly two cells)
  '/'  max/min           == target   (exactly two cells, exact division)
  '='  single cell       == target   (a given clue)

SMT encoding: one integer variable per cell (1..N), Distinct per row/column,
and one constraint per cage. As with Sudoku, we *describe* a valid solution
and let Z3 search.

Run:  python kenken.py
"""
import z3

N = 4

# Each cage: (target, op, [(row, col), ...]). Cells are 0-indexed.
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


def _cage_constraint(x, target, op, cells):
    vs = [x[r][c] for (r, c) in cells]
    if op == "+":
        return z3.Sum(vs) == target
    if op == "*":
        prod = vs[0]
        for v in vs[1:]:
            prod = prod * v
        return prod == target
    if op == "-":
        a, b = vs
        return z3.Or(a - b == target, b - a == target)
    if op == "/":
        a, b = vs
        # exact division either way, avoiding Z3 integer-division pitfalls
        return z3.Or(a == b * target, b == a * target)
    if op == "=":
        return vs[0] == target
    raise ValueError(f"unknown op {op!r}")


def _base_solver():
    x = [[z3.Int(f"x_{r}_{c}") for c in range(N)] for r in range(N)]
    s = z3.Solver()
    for r in range(N):
        for c in range(N):
            s.add(x[r][c] >= 1, x[r][c] <= N)
        s.add(z3.Distinct(x[r]))                       # rows
    for c in range(N):
        s.add(z3.Distinct([x[r][c] for r in range(N)]))  # columns
    for (target, op, cells) in CAGES:
        s.add(_cage_constraint(x, target, op, cells))
    return s, x


def solve():
    s, x = _base_solver()
    if s.check() != z3.sat:
        return None
    m = s.model()
    return [[m.evaluate(x[r][c]).as_long() for c in range(N)] for r in range(N)]


def is_unique(solution):
    s, x = _base_solver()
    s.add(z3.Or([x[r][c] != solution[r][c]
                 for r in range(N) for c in range(N)]))
    return s.check() == z3.unsat


_OP_SYM = {"+": "+", "-": "-", "*": "x", "/": "/", "=": ""}


def render(grid=None):
    """Draw the KenKen with cage borders and clues. With `grid`, also fills in
    the digits (so the same function shows the input puzzle and the solution).
    Clue notation: target then operation, e.g. `3+`, `12x` (times), `2/` (divide)
    shown in the top-left cell of each cage. `x` = multiply, `/` = divide."""
    cage_of, clue, anchor = {}, {}, {}
    for idx, (t, op, cells) in enumerate(CAGES):
        clue[idx] = f"{t}{_OP_SYM[op]}"
        anchor[idx] = min(cells)               # top-left cell of the cage
        for cell in cells:
            cage_of[cell] = idx

    W = 6                                       # cell inner width
    hbound = lambda r, c: r == 0 or r == N or cage_of[(r - 1, c)] != cage_of[(r, c)]
    vbound = lambda r, c: c == 0 or c == N or cage_of[(r, c - 1)] != cage_of[(r, c)]

    def corner(r, c):
        seg = ((0 <= c - 1 <= N - 1 and hbound(r, c - 1)) or
               (c <= N - 1 and hbound(r, c)) or
               (0 <= r - 1 <= N - 1 and vbound(r - 1, c)) or
               (r <= N - 1 and vbound(r, c)))
        return "+" if seg else " "

    def hline(r):
        return "".join(corner(r, c) + ("-" * W if hbound(r, c) else " " * W)
                       for c in range(N)) + corner(r, N)

    lines = []
    for r in range(N):
        lines.append(hline(r))
        top, bot = "", ""
        for c in range(N):
            edge = "|" if vbound(r, c) else " "
            idx = cage_of[(r, c)]
            cl = clue[idx] if anchor[idx] == (r, c) else ""
            dg = str(grid[r][c]) if grid is not None else ""
            top += edge + f" {cl:<{W - 1}}"
            bot += edge + f"{dg:^{W}}"
        lines.append(top + "|")
        lines.append(bot + "|")
    lines.append(hline(N))
    return "\n".join(lines)


if __name__ == "__main__":
    print("Puzzle (clues = target then op; x = times, / = divide):\n")
    print(render())

    sol = solve()
    if sol is None:
        print("\nunsat: no solution")
        raise SystemExit(1)

    print("\nSolution:\n")
    print(render(sol))

    # Self-checks: Latin square + every cage satisfied.
    rng = set(range(1, N + 1))
    assert all(set(sol[r]) == rng for r in range(N)), "row not a permutation"
    assert all({sol[r][c] for r in range(N)} == rng for c in range(N)), "col not a permutation"
    chk = z3.Solver()
    xs = [[z3.IntVal(sol[r][c]) for c in range(N)] for r in range(N)]
    for (t, op, cells) in CAGES:
        chk.add(_cage_constraint(xs, t, op, cells))
    assert chk.check() == z3.sat, "a cage constraint is violated"
    print("\nValid solution. Unique:", is_unique(sol))
