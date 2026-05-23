/-
  Euclid's GCD — STARTER (supply the ranking-function proof).

  The recursion is not structural, so Lean needs a measure that decreases.
  `termination_by a` says the measure is the first argument; your job is the
  `decreasing_by` proof that `b % (a+1) < a+1`.
  Hint:  exact Nat.mod_lt b (Nat.succ_pos a)
  Worked solution: `Gcd.lean`.

  NOTATION: `a b : Nat` both are naturals; `%` = remainder (mod); in a pattern,
  `a + 1` means "a nonzero Nat" (binding a to its predecessor).
  KEYWORDS/TACTICS: `termination_by m` names the shrinking measure m;
  `decreasing_by ..` proves it shrinks (a ranking-function proof); `exact e`
  closes a goal with term e; `simp [gcd]` unfolds gcd; `cases x with | ..`
  case-splits a value. `sorry` is a placeholder you must replace.
-/
namespace GcdStarter

-- gcd via Euclid: gcd 0 b = b; otherwise recurse on (b mod (a+1), a+1).
def gcd (a b : Nat) : Nat :=
  match a, b with
  | 0,     b => b
  | a + 1, b => gcd (b % (a + 1)) (a + 1)
termination_by a                          -- the measure that must shrink each call is the first arg
decreasing_by sorry   -- TODO: prove the measure strictly decreases.
                      -- Goal here is `b % (a+1) < a+1`. Use `exact Nat.mod_lt b (Nat.succ_pos a)`
                      -- (Nat.mod_lt needs the divisor positive; Nat.succ_pos a supplies a+1 > 0).

-- GOAL: gcd 0 b = b.  TODO: `simp [gcd]` unfolds the first match arm.
theorem gcd_zero_left (b : Nat) : gcd 0 b = b := by sorry
-- GOAL: gcd a 0 = a.  TODO: `cases a with | zero => simp [gcd] | succ n => simp [gcd]`
-- (gcd matches on its first argument, so split a into 0 vs successor).
theorem gcd_zero_right (a : Nat) : gcd a 0 = a := by sorry

end GcdStarter
