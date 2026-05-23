"""Sudoku as an SMT problem (Z3) — full solution.

A Sudoku is a 9x9 grid. Each cell holds a digit 1..9 such that every row,
every column, and every 3x3 box contains each digit exactly once. Some cells
are given ("clues"); the solver must fill the rest.

SMT encoding:
  - One integer variable c[r][c] per cell, constrained to 1..9.
  - Each row is a set of distinct values (Z3's Distinct).
  - Each column is distinct.
  - Each 3x3 box is distinct.
  - Each clue pins its cell to the given value.

This is the canonical "constraints, not search" example: we never write a
backtracking algorithm — we state what a solution *is* and let Z3 find one.

Run:  python sudoku.py
"""
import z3

# 0 = blank. A well-known puzzle (has a unique solution).
PUZZLE = [
    [5, 3, 0,  0, 7, 0,  0, 0, 0],
    [6, 0, 0,  1, 9, 5,  0, 0, 0],
    [0, 9, 8,  0, 0, 0,  0, 6, 0],

    [8, 0, 0,  0, 6, 0,  0, 0, 3],
    [4, 0, 0,  8, 0, 3,  0, 0, 1],
    [7, 0, 0,  0, 2, 0,  0, 0, 6],

    [0, 6, 0,  0, 0, 0,  2, 8, 0],
    [0, 0, 0,  4, 1, 9,  0, 0, 5],
    [0, 0, 0,  0, 8, 0,  0, 7, 9],
]


def solve(puzzle):
    """Return a solved 9x9 grid (list of lists) or None if unsatisfiable."""
    # An unknown integer for every one of the 81 cells; cells[r][c] is the
    # digit Z3 must choose for row r, column c. (z3.Int(name) = "some integer".)
    cells = [[z3.Int(f"c_{r}_{c}") for c in range(9)] for r in range(9)]
    s = z3.Solver()   # workspace that gathers the rules below

    # Every cell holds a digit 1..9 (two inequalities pin it to that range).
    for r in range(9):
        for c in range(9):
            s.add(cells[r][c] >= 1, cells[r][c] <= 9)

    # Rows distinct. z3.Distinct(list) means "all of these are pairwise
    # different", so a row's 9 cells must be 9 different digits = 1..9.
    for r in range(9):
        s.add(z3.Distinct(cells[r]))

    # Columns distinct: gather the 9 cells going down column c, all different.
    for c in range(9):
        s.add(z3.Distinct([cells[r][c] for r in range(9)]))

    # 3x3 boxes distinct. (br, bc) pick which box; (dr, dc) walk the 9 cells
    # inside it. Each box's 9 cells must also be all different.
    for br in range(3):
        for bc in range(3):
            box = [cells[3 * br + dr][3 * bc + dc]
                   for dr in range(3) for dc in range(3)]
            s.add(z3.Distinct(box))

    # Clues: wherever the puzzle gives a non-zero digit, force that cell to it.
    for r in range(9):
        for c in range(9):
            if puzzle[r][c] != 0:
                s.add(cells[r][c] == puzzle[r][c])

    # Solve. If no assignment satisfies every rule, report no solution.
    if s.check() != z3.sat:
        return None
    m = s.model()   # one valid assignment of all 81 cells
    # Read each cell's chosen value out of the model as a plain Python int
    # (.as_long() turns Z3's integer object into a normal number).
    return [[m.evaluate(cells[r][c]).as_long() for c in range(9)]
            for r in range(9)]


def has_unique_solution(puzzle, solution):
    """True iff no solution other than `solution` exists (blocking-clause trick).

    Idea: rebuild the exact same Sudoku rules, but ALSO forbid the answer we
    already found. If the solver still finds something (sat), a *second*,
    different solution exists, so the puzzle is not unique. If it can find
    nothing (unsat), the answer we have is the only one.
    """
    # Same setup as solve(): 81 unknowns plus the range / row / column / box
    # rules (here the per-cell range and row-distinct are folded into one loop).
    cells = [[z3.Int(f"c_{r}_{c}") for c in range(9)] for r in range(9)]
    s = z3.Solver()
    for r in range(9):
        for c in range(9):
            s.add(cells[r][c] >= 1, cells[r][c] <= 9)
        s.add(z3.Distinct(cells[r]))
    for c in range(9):
        s.add(z3.Distinct([cells[r][c] for r in range(9)]))
    for br in range(3):
        for bc in range(3):
            s.add(z3.Distinct([cells[3 * br + dr][3 * bc + dc]
                               for dr in range(3) for dc in range(3)]))
    for r in range(9):
        for c in range(9):
            if puzzle[r][c] != 0:
                s.add(cells[r][c] == puzzle[r][c])
    # The "blocking clause": z3.Or([... != ...]) says "at least one cell
    # differs from the solution we already have", which rules that exact grid
    # out. If the solver is now unsat, there was no other grid -> unique.
    s.add(z3.Or([cells[r][c] != solution[r][c]
                 for r in range(9) for c in range(9)]))
    return s.check() == z3.unsat


def show(grid):
    # Pretty-print the 9x9 grid with lines between the 3x3 boxes.
    for r in range(9):
        if r in (3, 6):
            print("------+-------+------")
        row = ""
        for c in range(9):
            if c in (3, 6):
                row += "| "
            row += f"{grid[r][c]} "
        print(row.rstrip())


if __name__ == "__main__":
    sol = solve(PUZZLE)
    if sol is None:
        print("unsat: no solution")
        raise SystemExit(1)
    show(sol)
    # Independent sanity check (not trusting Z3 blindly): confirm every row,
    # column, and box is exactly the set {1,...,9}. assert raises if a check fails.
    digits = set(range(1, 10))
    assert all(set(sol[r]) == digits for r in range(9)), "row check failed"
    assert all({sol[r][c] for r in range(9)} == digits for c in range(9)), "col check failed"
    for br in range(3):
        for bc in range(3):
            box = {sol[3 * br + dr][3 * bc + dc] for dr in range(3) for dc in range(3)}
            assert box == digits, "box check failed"
    # Also report whether this puzzle has only one solution (see the trick above).
    print("\nValid solution. Unique:", has_unique_solution(PUZZLE, sol))
