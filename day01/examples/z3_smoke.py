"""Day 1 smoke test.

Run this script first. If it prints a Z3 version and a satisfying model
for x + y = 7, your install is good and you are ready for the afternoon.

Z3 is an "SMT solver": you hand it a list of math/logic facts you want to
be true at the same time, and it either finds concrete values that make
them all true ("sat", satisfiable) or proves no such values exist ("unsat").
You never write a search loop yourself -- you just state the facts.

Run:  python z3_smoke.py
"""
import z3

# Print the installed Z3 version, just to confirm the library loaded.
print("Z3 version:", z3.get_version_string())

# Create two unknown integers. z3.Int("x") makes a symbol named "x" whose
# value Z3 will try to figure out -- think "let x be some whole number".
x = z3.Int("x")
y = z3.Int("y")
# A Solver is the workspace that collects our facts and does the reasoning.
s = z3.Solver()
# Add three facts that must hold simultaneously: x + y equals 7, and both
# are strictly positive. s.add(...) just records constraints; it solves nothing yet.
s.add(x + y == 7, x > 0, y > 0)
# s.check() does the actual work and returns "sat" (a solution exists) or
# "unsat" (impossible). Here it should print sat.
print("solver result:", s.check())
# s.model() returns one concrete assignment of x and y that satisfies every
# fact above (e.g. x=1, y=6). Only valid to call after check() returned sat.
print("model:", s.model())
