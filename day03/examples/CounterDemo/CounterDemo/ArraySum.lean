/-
  Summing a list — induction and a loop invariant.
  ===============================================

  A first taste of proving things about a simple "program". `sum` is the
  obvious recursive sum; `sumAcc` is the tail-recursive (accumulator) version
  you would actually write as a loop. The key theorem `sumAcc_eq` is the
  loop invariant: at every step the accumulator equals `acc + sum (rest)`.
  Proving it is induction on the list — the discrete analogue of an
  inductive invariant for a `while` loop.

  NOTATION CHEAT-SHEET (read once):
    • `:`        — "has type". `xs : List Nat` reads "xs is a list of naturals".
    • `→`        — function arrow. `List Nat → Nat` = takes a list, returns a Nat.
    • `[]`       — the empty list;  `x :: xs` — list with head `x`, tail `xs`.
    • `xs ++ ys` — list append (concatenate).
    • `a = b`    — propositional equality (a claim two things are equal).

  TACTICS USED HERE (one-liners):
    • induction x with | nil => .. | cons .. => ..
                  — prove by cases on how the list was built; the `cons` case
                    gets an induction hypothesis `ih` (the result for the tail).
    • simp [..]   — simplify the goal using the listed rewrite rules / defs.
    • simp only [..] — simplify using ONLY the listed rules (no extras).
    • rw [h]      — rewrite the goal left-to-right using equation `h`.
    • omega       — decide goals that are linear arithmetic over Nat/Int.
-/
namespace ArraySum

/-- Recursive sum of a list of naturals. -/
-- `def name : T := ..` defines a value/function of type T.
-- Here `sum` is defined by pattern-matching on the two list shapes:
def sum : List Nat → Nat
  | [] => 0                 -- sum of the empty list is 0
  | x :: xs => x + sum xs   -- sum of (head x :: tail xs) = x + sum of tail

/-- Sum distributes over append (proved by induction on the first list). -/
-- `theorem name (args) : Claim := by ..` states `Claim` and proves it; `by`
-- starts tactic mode (a step-by-step proof script).
theorem sum_append (xs ys : List Nat) : sum (xs ++ ys) = sum xs + sum ys := by
  induction xs with                       -- split on the shape of xs (empty vs head::tail)
  | nil => simp [sum]                      -- xs = []: both sides reduce to `sum ys` by unfolding sum
  | cons x xs ih =>                        -- xs = x::xs; `ih` = the theorem already holds for the tail xs
    simp only [List.cons_append, sum, ih]  -- rewrite using only: append-on-cons, the def of sum, and ih
    omega                                  -- finish the leftover Nat arithmetic equality

/-- Appending a single element adds it to the sum. -/
theorem sum_snoc (xs : List Nat) (x : Nat) : sum (xs ++ [x]) = sum xs + x := by
  rw [sum_append]; simp [sum]              -- rewrite with the lemma above, then simplify `sum [x]` to `x`

/-- Tail-recursive sum with an accumulator — the "loop" version. -/
-- `acc` plays the role of a running total (a loop variable).
def sumAcc : Nat → List Nat → Nat
  | acc, []      => acc                     -- list empty: answer is whatever we accumulated
  | acc, x :: xs => sumAcc (acc + x) xs     -- add head to acc and recurse on the tail (the "loop body")

/-- ★ LOOP INVARIANT: after processing the prefix, the accumulator equals the
    starting accumulator plus the sum of the remaining list. We `generalize acc`
    so the induction hypothesis is available for every accumulator value. -/
theorem sumAcc_eq (acc : Nat) (xs : List Nat) : sumAcc acc xs = acc + sum xs := by
  induction xs generalizing acc with        -- induct on xs; `generalizing acc` keeps the IH usable for ANY acc
  | nil => simp [sumAcc, sum]                -- xs = []: both sides reduce to `acc`
  | cons x xs ih =>                          -- xs = x::xs; ih : ∀ acc, sumAcc acc xs = acc + sum xs
    simp only [sumAcc, sum, ih]              -- unfold one loop step + the spec, then apply ih
    omega                                    -- finish the Nat arithmetic ((acc+x)+.. = acc+(x+..))

/-- The loop computes the same thing as the recursive spec. -/
theorem sumAcc_correct (xs : List Nat) : sumAcc 0 xs = sum xs := by
  rw [sumAcc_eq]; simp                       -- specialize the invariant to acc = 0, then `0 + n` simplifies to `n`

end ArraySum
