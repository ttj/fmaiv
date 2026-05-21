/-
  Euclid's GCD — STARTER (supply the ranking-function proof).

  The recursion is not structural, so Lean needs a measure that decreases.
  `termination_by a` says the measure is the first argument; your job is the
  `decreasing_by` proof that `b % (a+1) < a+1`.
  Hint:  exact Nat.mod_lt b (Nat.succ_pos a)
  Worked solution: `Gcd.lean`.
-/
namespace GcdStarter

def gcd (a b : Nat) : Nat :=
  match a, b with
  | 0,     b => b
  | a + 1, b => gcd (b % (a + 1)) (a + 1)
termination_by a
decreasing_by sorry   -- TODO: prove the measure strictly decreases

-- TODO: prove these (see Gcd.lean).
theorem gcd_zero_left (b : Nat) : gcd 0 b = b := by sorry
theorem gcd_zero_right (a : Nat) : gcd a 0 = a := by sorry

end GcdStarter
