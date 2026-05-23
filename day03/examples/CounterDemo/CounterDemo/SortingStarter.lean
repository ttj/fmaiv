/-
  Insertion sort — STARTER (replace each `sorry`).

  Definitions are given. Prove `mem_insert`, then `sorted_insert`, then
  `sorted_isort`. The membership lemma is the key helper for the head-bound in
  `sorted_insert`. Worked solution: `Sorting.lean`.

  NOTATION: `Prop` = type of statements; `inductive .. : List Nat → Prop` is a
  PREDICATE (the constructors are the only ways to prove it); `∀ b, ..` for all;
  `b ∈ l` membership; `→` implies; `a ≤ b` at-most; `P ↔ Q` iff (`.mp` is →,
  `.mpr` is ←); `a :: l` head::tail; `Or.inl`/`Or.inr` build a proof of `∨`.
  TACTICS: `induction l with | nil => .. | cons y ys ih => ..` (cons gets IH `ih`);
  `by_cases h : P` (split P vs ¬P); `simp only [..]` (simplify with only those
  rules; `if_pos`/`if_neg` pick an if-branch); `constructor` (split an ↔ into two
  directions); `intro h`, `exact e`, `rcases h with h | h` (destructure an OR),
  `refine ⟨.., ?_⟩` (build a value, leave `?_` goals), `omega` (Nat arithmetic).
-/
namespace SortingStarter

-- Sorted: empty is sorted; or head a with tail l, if a ≤ every member of l and l sorted.
inductive Sorted : List Nat → Prop where
  | nil  : Sorted []
  | cons (a : Nat) (l : List Nat) :
      (∀ b, b ∈ l → a ≤ b) → Sorted l → Sorted (a :: l)

-- Insert x keeping order: stop at the first element y with x ≤ y.
def insert (x : Nat) : List Nat → List Nat
  | []      => [x]
  | y :: ys => if x ≤ y then x :: y :: ys else y :: insert x ys

def isort : List Nat → List Nat
  | []      => []
  | x :: xs => insert x (isort xs)

-- GOAL: b is in (insert x l) iff b = x or b was already in l.
-- (`List.mem_cons` : `b ∈ a::l ↔ b = a ∨ b ∈ l` is the helper library fact.)
-- TODO: induction on the list; case-split on `x ≤ y`.
theorem mem_insert (b x : Nat) (l : List Nat) :
    b ∈ insert x l ↔ b = x ∨ b ∈ l := by
  sorry   -- PROVE THIS: `induction l with`; nil: `simp [insert]`. cons y ys ih:
          -- `by_cases hxy : x ≤ y`, then in each branch `simp only [insert, if_pos hxy]`
          -- (or `if_neg hxy`), `constructor`, and shuffle the OR with `rcases`/`Or.inl`/
          -- `Or.inr` and `List.mem_cons.mp`/`.mpr` (use `ih` in the else-branch).

-- GOAL: inserting x into a sorted list stays sorted.
-- TODO: structural recursion on the list; use `mem_insert` for the head bound.
theorem sorted_insert (x : Nat) : ∀ (l : List Nat), Sorted l → Sorted (insert x l) := by
  sorry   -- PROVE THIS: induct/recurse on l. nil: result [x] via `Sorted.cons`. cons y ys:
          -- `cases` the Sorted proof to get the bound + tail-sorted; `by_cases hxy : x ≤ y`;
          -- build `Sorted.cons ..` with `refine .. ?_`; for the new head-bound `intro b hb`
          -- and case `b` with `rcases` (using `mem_insert` in the else-branch); `omega` for ≤.

-- GOAL: insertion sort always returns a sorted list.
-- TODO: induction using `sorted_insert`.
theorem sorted_isort (l : List Nat) : Sorted (isort l) := by
  sorry   -- PROVE THIS: `induction l with`; nil: `exact Sorted.nil`. cons x xs ih:
          -- `isort (x::xs) = insert x (isort xs)`; apply `sorted_insert x _ ih` (`simp [isort]` may help).

end SortingStarter
