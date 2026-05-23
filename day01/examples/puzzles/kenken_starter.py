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
    # vs = the cell variables belonging to this cage.
    vs = [x[r][c] for (r, c) in cells]
    # TODO: look at `op` and return the matching Z3 boolean constraint.
    #   Use an if/elif chain on op and return one constraint per case:
    #   '+' -> z3.Sum(vs) == target
    #   '*' -> product of vs == target   (loop to multiply; z3 has no list-product)
    #   '-' -> two cells a,b with z3.Or(a-b==target, b-a==target)   (order unknown)
    #   '/' -> two cells a,b with z3.Or(a==b*target, b==a*target)   (exact, either order)
    #   '=' -> vs[0] == target
    # Until you implement it, this returns "always true", i.e. no real
    # restriction -- so the grid below will look wrong until you fill this in.
    return z3.BoolVal(True)  # placeholder: no constraint yet


def solve():
    # One unknown integer per cell of the N x N grid.
    x = [[z3.Int(f"x_{r}_{c}") for c in range(N)] for r in range(N)]
    s = z3.Solver()
    for r in range(N):
        for c in range(N):
            s.add(x[r][c] >= 1, x[r][c] <= N)   # each cell is a digit 1..N
        # TODO: every row is a Latin row (distinct values).
        #   Add z3.Distinct(x[r]) here so a row never repeats a digit.
    # TODO: every column is distinct.
    #   For each column c, add z3.Distinct([x[r][c] for r in range(N)]).
    # Add each cage's arithmetic rule (works once cage_constraint is done).
    for (target, op, cells) in CAGES:
        s.add(cage_constraint(x, target, op, cells))
    if s.check() != z3.sat:
        return None
    m = s.model()
    return [[m.evaluate(x[r][c], model_completion=True).as_long()
             for c in range(N)] for r in range(N)]


_OP_SYM = {"+": "+", "-": "-", "*": "x", "/": "/", "=": ""}


def render(grid=None):
    """Draw the KenKen with cage borders and clues (top-left cell of each cage).
    With `grid`, also fill in digits. `x` = multiply, `/` = divide."""
    cage_of, clue, anchor = {}, {}, {}
    for idx, (t, op, cells) in enumerate(CAGES):
        clue[idx] = f"{t}{_OP_SYM[op]}"
        anchor[idx] = min(cells)
        for cell in cells:
            cage_of[cell] = idx

    W = 6
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
        print("\nunsat (or constraints incomplete)")
        raise SystemExit(1)
    print("\nYour current solution:\n")
    print(render(sol))
    rng = set(range(1, N + 1))
    ok = (all(set(sol[r]) == rng for r in range(N))
          and all({sol[r][c] for r in range(N)} == rng for c in range(N)))
    print("\nLatin square:", ok, "(should be True once all TODOs are done)")
