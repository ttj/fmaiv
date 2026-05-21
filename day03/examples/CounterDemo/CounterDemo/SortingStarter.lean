/-
  Insertion sort — STARTER (replace each `sorry`).

  Definitions are given. Prove `mem_insert`, then `sorted_insert`, then
  `sorted_isort`. The membership lemma is the key helper for the head-bound in
  `sorted_insert`. Worked solution: `Sorting.lean`.
-/
namespace SortingStarter

inductive Sorted : List Nat → Prop where
  | nil  : Sorted []
  | cons (a : Nat) (l : List Nat) :
      (∀ b, b ∈ l → a ≤ b) → Sorted l → Sorted (a :: l)

def insert (x : Nat) : List Nat → List Nat
  | []      => [x]
  | y :: ys => if x ≤ y then x :: y :: ys else y :: insert x ys

def isort : List Nat → List Nat
  | []      => []
  | x :: xs => insert x (isort xs)

-- TODO: induction on the list; case-split on `x ≤ y`.
theorem mem_insert (b x : Nat) (l : List Nat) :
    b ∈ insert x l ↔ b = x ∨ b ∈ l := by
  sorry

-- TODO: structural recursion on the list; use `mem_insert` for the head bound.
theorem sorted_insert (x : Nat) : ∀ (l : List Nat), Sorted l → Sorted (insert x l) := by
  sorry

-- TODO: induction using `sorted_insert`.
theorem sorted_isort (l : List Nat) : Sorted (isort l) := by
  sorry

end SortingStarter
