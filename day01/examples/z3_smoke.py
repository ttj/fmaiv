"""Day 1 smoke test.

Run this script first. If it prints a Z3 version and a satisfying model
for x + y = 7, your install is good and you are ready for the afternoon.
"""
import z3

print("Z3 version:", z3.get_version_string())

x = z3.Int("x")
y = z3.Int("y")
s = z3.Solver()
s.add(x + y == 7, x > 0, y > 0)
print("solver result:", s.check())
print("model:", s.model())
