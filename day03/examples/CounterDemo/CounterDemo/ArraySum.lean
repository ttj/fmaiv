/-
  Summing a list — induction and a loop invariant.
  ===============================================

  A first taste of proving things about a simple "program". `sum` is the
  obvious recursive sum; `sumAcc` is the tail-recursive (accumulator) version
  you would actually write as a loop. The key theorem `sumAcc_eq` is the
  loop invariant: at every step the accumulator equals `acc + sum (rest)`.
  Proving it is induction on the list — the discrete analogue of an
  inductive invariant for a `while` loop.
-/
namespace ArraySum

/-- Recursive sum of a list of naturals. -/
def sum : List Nat → Nat
  | [] => 0
  | x :: xs => x + sum xs

/-- Sum distributes over append (proved by induction on the first list). -/
theorem sum_append (xs ys : List Nat) : sum (xs ++ ys) = sum xs + sum ys := by
  induction xs with
  | nil => simp [sum]
  | cons x xs ih =>
    simp only [List.cons_append, sum, ih]
    omega

/-- Appending a single element adds it to the sum. -/
theorem sum_snoc (xs : List Nat) (x : Nat) : sum (xs ++ [x]) = sum xs + x := by
  rw [sum_append]; simp [sum]

/-- Tail-recursive sum with an accumulator — the "loop" version. -/
def sumAcc : Nat → List Nat → Nat
  | acc, []      => acc
  | acc, x :: xs => sumAcc (acc + x) xs

/-- ★ LOOP INVARIANT: after processing the prefix, the accumulator equals the
    starting accumulator plus the sum of the remaining list. We `generalize acc`
    so the induction hypothesis is available for every accumulator value. -/
theorem sumAcc_eq (acc : Nat) (xs : List Nat) : sumAcc acc xs = acc + sum xs := by
  induction xs generalizing acc with
  | nil => simp [sumAcc, sum]
  | cons x xs ih =>
    simp only [sumAcc, sum, ih]
    omega

/-- The loop computes the same thing as the recursive spec. -/
theorem sumAcc_correct (xs : List Nat) : sumAcc 0 xs = sum xs := by
  rw [sumAcc_eq]; simp

end ArraySum
