"""Sudoku as an SMT problem (Z3) — STARTER (fill in the TODOs).

Goal: state what a valid Sudoku solution *is* as Z3 constraints, then let the
solver fill the grid. You should NOT write any search/backtracking code.

Fill in the four TODOs in `solve(...)`. When you are done, running this file
should print the same grid as `sudoku.py` and report a unique solution.

Run:  python sudoku_starter.py
"""
import z3

# 0 = blank.
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
    # 81 unknown integers, one per cell; cells[r][c] is what Z3 will fill in.
    cells = [[z3.Int(f"c_{r}_{c}") for c in range(9)] for r in range(9)]
    s = z3.Solver()   # collects the rules you are about to add with s.add(...)

    # TODO 1: constrain every cell to a digit in 1..9.
    #   Loop over all r, c and add BOTH cells[r][c] >= 1 and cells[r][c] <= 9.
    #         (hint: cells[r][c] >= 1, cells[r][c] <= 9)

    # TODO 2: every row contains distinct values.
    #   For each row r, add that its 9 cells are all different. z3.Distinct(xs)
    #   means "no two of xs are equal", which for digits 1..9 forces a full 1..9.
    #         (hint: z3.Distinct(cells[r]))

    # TODO 3: every column, and every 3x3 box, contains distinct values.
    #   Column c: the cells [cells[0][c], cells[1][c], ...] must be Distinct.
    #   Box: for each of the 9 boxes, gather its 3x3 = 9 cells (top-left corner
    #   is row 3*br, col 3*bc) and make them Distinct too.

    # TODO 4: pin each given clue (puzzle[r][c] != 0) to its value.
    #   Where the puzzle already shows a digit, add cells[r][c] == puzzle[r][c].

    # Once all four TODOs are in, ask Z3 to find an assignment; unsat -> None.
    if s.check() != z3.sat:
        return None
    m = s.model()
    # model_completion=True so unconstrained cells still get a value (you will
    # see zeros / a wrong grid until the TODO constraints are in place).
    return [[m.evaluate(cells[r][c], model_completion=True).as_long()
             for c in range(9)] for r in range(9)]


def show(grid):
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
        print("unsat (or constraints incomplete): no solution found")
        raise SystemExit(1)
    show(sol)
    digits = set(range(1, 10))
    ok = (all(set(sol[r]) == digits for r in range(9))
          and all({sol[r][c] for r in range(9)} == digits for c in range(9)))
    print("\nLooks like a valid Sudoku:" , ok,
          "(should be True once all TODOs are done)")
