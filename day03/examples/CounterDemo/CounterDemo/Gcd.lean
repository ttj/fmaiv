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

  TACTICS / KEYWORDS USED HERE (one-liners):
    • termination_by m — name the measure `m` that must shrink each recursive call.
    • decreasing_by ..  — prove that measure actually shrinks (a ranking-function proof).
    • exact e           — close the goal with term `e` (must already have the right type).
    • simp [gcd]        — simplify by unfolding the definition of `gcd`.
    • cases x with | ..  — case-split a value into its constructors (no induction hypothesis).
    • native_decide     — compute the answer in compiled native code and accept it
                          (fast; trusts the compiler — adds one extra trust assumption).
  NOTATION: `a b : Nat` = both a and b are naturals;  `%` = remainder (mod).
-/
namespace Gcd

-- `match a, b with | pat => ..` chooses a branch by the shapes of a and b.
-- `a + 1` as a pattern means "a nonzero Nat", binding `a` to its predecessor.
def gcd (a b : Nat) : Nat :=
  match a, b with
  | 0,     b => b                            -- gcd 0 b = b  (base case)
  | a + 1, b => gcd (b % (a + 1)) (a + 1)    -- Euclid step: recurse on (b mod a+1, a+1)
termination_by a                             -- the shrinking measure is the first argument
decreasing_by exact Nat.mod_lt b (Nat.succ_pos a)
  -- proof obligation: `b % (a+1) < a+1`. `Nat.mod_lt` gives exactly that,
  -- needing `a+1 > 0`, supplied by `Nat.succ_pos a`.

theorem gcd_zero_left (b : Nat) : gcd 0 b = b := by
  simp [gcd]                                 -- unfolds gcd on the `0` case to `b`

theorem gcd_zero_right (a : Nat) : gcd a 0 = a := by
  cases a with                               -- split a into 0 vs successor (gcd matches on a)
  | zero   => simp [gcd]                     -- a = 0: gcd 0 0 = 0
  | succ n => simp [gcd]                     -- a = n+1: one unfold reduces to a

-- Concrete checks (computed by the compiler, so well-founded recursion is fine):
-- `example : Claim := proof` is an anonymous theorem (a sanity check, no name).
example : gcd 48 36 = 12 := by native_decide
example : gcd 1071 462 = 21 := by native_decide

end Gcd
