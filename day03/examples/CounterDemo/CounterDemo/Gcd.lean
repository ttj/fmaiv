/-
  Euclid's GCD — termination by a ranking function.
  =================================================

  Lean accepts a recursive definition automatically only when the recursive
  call is on a structurally smaller argument. Euclid's algorithm recurses on
  `b % (a+1)`, which is NOT structurally smaller, so Lean asks us for a
  *ranking function*: a measure that strictly decreases on every call. Here the
  measure is the first argument `a`, and the decrease is `b % (a+1) < a+1`.
  `termination_by` names the measure; `decreasing_by` discharges the obligation.
  This is exactly the liveness/termination tool from TransitionSystem.lean,
  used here on an ordinary function.
-/
namespace Gcd

def gcd (a b : Nat) : Nat :=
  match a, b with
  | 0,     b => b
  | a + 1, b => gcd (b % (a + 1)) (a + 1)
termination_by a
decreasing_by exact Nat.mod_lt b (Nat.succ_pos a)

theorem gcd_zero_left (b : Nat) : gcd 0 b = b := by
  simp [gcd]

theorem gcd_zero_right (a : Nat) : gcd a 0 = a := by
  cases a with
  | zero   => simp [gcd]
  | succ n => simp [gcd]

-- Concrete checks (computed by the compiler, so well-founded recursion is fine):
example : gcd 48 36 = 12 := by native_decide
example : gcd 1071 462 = 21 := by native_decide

end Gcd
