"""Day 1 — bounded reachability of the counter, encoded for Z3.

This is the first time you meet the running example: a counter that
increments x from 0 to a configurable cap while in mode = on, and
returns to mode = off after a press.

We will model-check this with nuXmv on Day 2 and prove invariants
about it in Lean on Day 3. Today we ask a bounded question:

   "Starting from the initial state, is there a sequence of presses
    of length at most N that drives x to a forbidden value?"

For x_cap = 10 the answer should always be unsat for the forbidden
value 11. We try several N to convince ourselves.

The transition system (`counter.smv` shape):
  state = (mode, x), input = press
  init = (off, 0)
  next:
    if mode=off and !press     : (off, x)
    if mode=off and press      : (on,  x)
    if mode=on and !press and x<cap : (on, x+1)
    if mode=on and (press or x>=cap): (off, 0)
"""
import z3

MODE_OFF = 0
MODE_ON = 1
X_CAP = 10
FORBIDDEN_X = 11   # we want to show x=11 is unreachable

def step(s_mode, s_x, press, sp_mode, sp_x):
    """Constraint: (s_mode, s_x) --press--> (sp_mode, sp_x)."""
    return z3.And(
        # mode update
        sp_mode == z3.If(
            z3.And(s_mode == MODE_OFF, z3.Not(press)),
            MODE_OFF,
            z3.If(
                z3.And(s_mode == MODE_OFF, press),
                MODE_ON,
                z3.If(
                    z3.And(s_mode == MODE_ON, z3.Not(press), s_x < X_CAP),
                    MODE_ON,
                    z3.If(
                        z3.And(s_mode == MODE_ON,
                               z3.Or(press, s_x >= X_CAP)),
                        MODE_OFF,
                        s_mode,
                    ),
                ),
            ),
        ),
        # x update
        sp_x == z3.If(
            z3.And(s_mode == MODE_ON, z3.Not(press), s_x < X_CAP),
            s_x + 1,
            z3.If(
                z3.And(s_mode == MODE_ON,
                       z3.Or(press, s_x >= X_CAP)),
                0,
                s_x,
            ),
        ),
    )


def bounded_reach_to(forbidden_x: int, num_steps: int) -> z3.CheckSatResult:
    """Ask: can x reach `forbidden_x` within `num_steps` transitions?

    "Within" = at *some* step k <= num_steps, not only at exactly num_steps.
    That is the "<= N" of bounded model checking: a counterexample of any
    length up to the bound counts.
    """
    s = z3.Solver()
    # One copy of each state variable per step 0..num_steps (the "unrolling").
    mode = [z3.Int(f"mode_{k}") for k in range(num_steps + 1)]
    x = [z3.Int(f"x_{k}") for k in range(num_steps + 1)]
    # One press input per transition (there are num_steps transitions).
    press = [z3.Bool(f"press_{k}") for k in range(num_steps)]

    # initial state: (off, 0)
    s.add(mode[0] == MODE_OFF, x[0] == 0)
    # transition relation for each step: state k --press_k--> state k+1
    for k in range(num_steps):
        s.add(step(mode[k], x[k], press[k], mode[k + 1], x[k + 1]))
    # the bad property: x = forbidden_x at SOME step k <= num_steps.
    # (Asserting it only at the final step would ask "exactly num_steps";
    #  the disjunction over all steps is the honest "<= N" question.)
    s.add(z3.Or([x[k] == forbidden_x for k in range(num_steps + 1)]))

    return s.check()


if __name__ == "__main__":
    print(f"Counter with x_cap={X_CAP}; checking unreachability of x={FORBIDDEN_X}.\n")
    for n in [5, 10, 15, 20, 30]:
        res = bounded_reach_to(FORBIDDEN_X, n)
        verdict = "UNSAT (no path)" if res == z3.unsat else f"{res}"
        print(f"  bound = {n:>2} steps:  {verdict}")
    print("\nBounded model checking only rules out short counterexamples.")
    print("Day 2 will rule them out for all lengths with nuXmv.")
