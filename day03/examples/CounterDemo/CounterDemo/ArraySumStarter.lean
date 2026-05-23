/-
  Summing a list — STARTER (replace each `sorry` with a proof).

  The definitions are given. Prove the three theorems. Hints are in comments;
  the worked solution is in `ArraySum.lean`.

  NOTATION: `:` has type; `→` function arrow; `[]` empty list; `x :: xs` head::tail;
  `xs ++ ys` append; `a = b` an equality claim.
  TACTICS you'll need: `induction xs with | nil => .. | cons x xs ih => ..`
  (case-split on the list; cons gives induction hyp `ih`), `simp [..]` /
  `simp only [..]` (simplify with the listed rules), `rw [h]` (rewrite by equation h),
  `omega` (finish Nat arithmetic). `sorry` = an accepted-but-unproved placeholder; replace it.
-/
namespace ArraySumStarter

-- Recursive sum: empty list = 0; (head x :: tail xs) = x + sum of the tail.
def sum : List Nat → Nat
  | [] => 0
  | x :: xs => x + sum xs

-- GOAL: sum of an appended list = sum of the two parts.
-- TODO: induction on `xs`; nil by `simp [sum]`, cons by
--   `simp only [List.cons_append, sum, ih]; omega`.
theorem sum_append (xs ys : List Nat) : sum (xs ++ ys) = sum xs + sum ys := by
  sorry   -- PROVE THIS: do `induction xs with`; nil case `simp [sum]`; cons case use `ih` then `omega`

-- Accumulator ("loop") version: `acc` is the running total.
def sumAcc : Nat → List Nat → Nat
  | acc, []      => acc
  | acc, x :: xs => sumAcc (acc + x) xs

-- GOAL (THE LOOP INVARIANT): the accumulator output = starting acc + sum of the list.
-- TODO (the loop invariant): `induction xs generalizing acc`.
theorem sumAcc_eq (acc : Nat) (xs : List Nat) : sumAcc acc xs = acc + sum xs := by
  sorry   -- PROVE THIS: `induction xs generalizing acc with` (so the IH works for ANY acc);
          -- nil: `simp [sumAcc, sum]`; cons: `simp only [sumAcc, sum, ih]` then `omega`.

-- GOAL: the loop with start 0 equals the recursive spec.
theorem sumAcc_correct (xs : List Nat) : sumAcc 0 xs = sum xs := by
  sorry   -- PROVE THIS: `rw [sumAcc_eq]` to use the invariant at acc=0, then `simp` (0 + n = n).

end ArraySumStarter
