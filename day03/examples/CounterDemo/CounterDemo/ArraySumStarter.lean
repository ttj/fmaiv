/-
  Summing a list — STARTER (replace each `sorry` with a proof).

  The definitions are given. Prove the three theorems. Hints are in comments;
  the worked solution is in `ArraySum.lean`.
-/
namespace ArraySumStarter

def sum : List Nat → Nat
  | [] => 0
  | x :: xs => x + sum xs

-- TODO: induction on `xs`; nil by `simp [sum]`, cons by
--   `simp only [List.cons_append, sum, ih]; omega`.
theorem sum_append (xs ys : List Nat) : sum (xs ++ ys) = sum xs + sum ys := by
  sorry

def sumAcc : Nat → List Nat → Nat
  | acc, []      => acc
  | acc, x :: xs => sumAcc (acc + x) xs

-- TODO (the loop invariant): `induction xs generalizing acc`.
theorem sumAcc_eq (acc : Nat) (xs : List Nat) : sumAcc acc xs = acc + sum xs := by
  sorry

theorem sumAcc_correct (xs : List Nat) : sumAcc 0 xs = sum xs := by
  sorry

end ArraySumStarter
