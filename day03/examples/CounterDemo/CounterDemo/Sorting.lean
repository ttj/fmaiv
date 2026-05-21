/-
  Insertion sort, proved to produce a sorted list.
  ================================================

  `Sorted` says "the head is ≤ every later element, and the tail is sorted."
  The proof is the classic two-step induction:
    • `sorted_insert` — inserting into a sorted list keeps it sorted;
    • `sorted_isort`  — insertion sort is sorted, by induction using the above.
  We also prove insertion sort preserves length (a simpler warm-up induction).
-/
namespace Sorting

/-- `Sorted l`: the first element is a lower bound for the rest, recursively. -/
inductive Sorted : List Nat → Prop where
  | nil  : Sorted []
  | cons (a : Nat) (l : List Nat) :
      (∀ b, b ∈ l → a ≤ b) → Sorted l → Sorted (a :: l)

/-- Insert `x` into a list at the first position keeping order. -/
def insert (x : Nat) : List Nat → List Nat
  | []      => [x]
  | y :: ys => if x ≤ y then x :: y :: ys else y :: insert x ys

/-- Insertion sort. -/
def isort : List Nat → List Nat
  | []      => []
  | x :: xs => insert x (isort xs)

/-- Membership in `insert x l` is membership in `l` plus `x` itself. -/
theorem mem_insert (b x : Nat) (l : List Nat) :
    b ∈ insert x l ↔ b = x ∨ b ∈ l := by
  induction l with
  | nil => simp [insert]
  | cons y ys ih =>
    by_cases hxy : x ≤ y
    · simp only [insert, if_pos hxy]
      constructor
      · intro h
        rcases List.mem_cons.mp h with h | h
        · exact Or.inl h
        · exact Or.inr h
      · intro h
        rcases h with h | h
        · exact List.mem_cons.mpr (Or.inl h)
        · exact List.mem_cons.mpr (Or.inr h)
    · simp only [insert, if_neg hxy]
      constructor
      · intro h
        rcases List.mem_cons.mp h with h | h
        · exact Or.inr (List.mem_cons.mpr (Or.inl h))
        · rcases ih.mp h with h | h
          · exact Or.inl h
          · exact Or.inr (List.mem_cons.mpr (Or.inr h))
      · intro h
        rcases h with h | h
        · exact List.mem_cons.mpr (Or.inr (ih.mpr (Or.inl h)))
        · rcases List.mem_cons.mp h with h | h
          · exact List.mem_cons.mpr (Or.inl h)
          · exact List.mem_cons.mpr (Or.inr (ih.mpr (Or.inr h)))

/-- Inserting into a sorted list yields a sorted list. -/
theorem sorted_insert (x : Nat) : ∀ (l : List Nat), Sorted l → Sorted (insert x l)
  | [], _ => by
      simp only [insert]
      exact Sorted.cons x [] (by simp) Sorted.nil
  | y :: ys, h => by
      cases h with
      | cons _ _ hbound hys =>
        by_cases hxy : x ≤ y
        · simp only [insert, if_pos hxy]
          refine Sorted.cons x (y :: ys) ?_ (Sorted.cons y ys hbound hys)
          intro b hb
          rcases List.mem_cons.mp hb with rfl | hb
          · exact hxy
          · have := hbound b hb; omega
        · simp only [insert, if_neg hxy]
          have hyx : y ≤ x := by omega
          refine Sorted.cons y (insert x ys) ?_ (sorted_insert x ys hys)
          intro b hb
          rcases (mem_insert b x ys).mp hb with rfl | hb
          · exact hyx
          · exact hbound b hb

/-- Insertion sort always produces a sorted list. -/
theorem sorted_isort : ∀ (l : List Nat), Sorted (isort l)
  | []      => Sorted.nil
  | x :: xs => sorted_insert x (isort xs) (sorted_isort xs)

/-- Insertion preserves length (warm-up induction). -/
theorem length_insert (x : Nat) (l : List Nat) :
    (insert x l).length = l.length + 1 := by
  induction l with
  | nil => rfl
  | cons y ys ih =>
    by_cases hxy : x ≤ y
    · simp [insert, if_pos hxy]
    · simp [insert, if_neg hxy, ih]

/-- Insertion sort preserves length. -/
theorem length_isort (l : List Nat) : (isort l).length = l.length := by
  induction l with
  | nil => rfl
  | cons x xs ih => simp [isort, length_insert, ih]

end Sorting
