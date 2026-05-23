/-
  Insertion sort, proved to produce a sorted list.
  ================================================

  `Sorted` says "the head is ≤ every later element, and the tail is sorted."
  The proof is the classic two-step induction:
    • `sorted_insert` — inserting into a sorted list keeps it sorted;
    • `sorted_isort`  — insertion sort is sorted, by induction using the above.
  We also prove insertion sort preserves length (a simpler warm-up induction).

  NOTATION CHEAT-SHEET:
    • Prop          — the type of "propositions" (statements that can be true/false).
    • inductive .. : List Nat → Prop — defines a PREDICATE on lists: the listed
                      constructors are the ONLY ways to prove it true.
    • `∀ b, ..`     — "for all b, ..".   `b ∈ l` — "b is a member of list l".
    • `→`           — implies (also the function arrow).   `a ≤ b` — "a at most b".
    • `P ↔ Q`       — "P if and only if Q"; `.mp` is the → direction, `.mpr` the ←.
    • `a :: l`      — list with head a, tail l.   `[x]` — one-element list.
    • Or.inl / Or.inr — build a proof of `P ∨ Q` from the left / right side.
  TACTICS USED HERE:
    • induction l with | nil => .. | cons .. ih => ..
                     — case-split on list shape; `cons` gets induction hyp `ih`.
    • by_cases h : P — classical split into the case P holds and the case ¬P.
    • simp only [..] — simplify using ONLY the listed rules (incl. if_pos/if_neg
                       to pick an if-branch once the condition is known).
    • constructor    — to prove `P ↔ Q`, split into the two implication directions.
    • intro h        — assume a hypothesis / ∀-variable and name it h.
    • exact e        — close the goal with term `e`.
    • rcases h with h | h — destructure an "OR" (or ∃/∧) into named cases.
    • refine ⟨.., ?_⟩ — build a structured value, leaving `?_` holes as new goals.
    • omega          — decide linear arithmetic over Nat/Int.
    • rfl            — goal is true because both sides compute to the same thing.
-/
namespace Sorting

/-- `Sorted l`: the first element is a lower bound for the rest, recursively. -/
-- Two ways to be sorted: `nil` (empty list), or `cons` (head a, tail l) provided
-- a ≤ every member of l AND l is itself sorted.
inductive Sorted : List Nat → Prop where
  | nil  : Sorted []
  | cons (a : Nat) (l : List Nat) :
      (∀ b, b ∈ l → a ≤ b) → Sorted l → Sorted (a :: l)

/-- Insert `x` into a list at the first position keeping order. -/
-- `if c then A else B` chooses A when condition c holds, else B.
def insert (x : Nat) : List Nat → List Nat
  | []      => [x]
  | y :: ys => if x ≤ y then x :: y :: ys else y :: insert x ys

/-- Insertion sort. -/
def isort : List Nat → List Nat
  | []      => []
  | x :: xs => insert x (isort xs)   -- sort the tail, then drop the head into place

/-- Membership in `insert x l` is membership in `l` plus `x` itself. -/
-- Reads: b is in (insert x l)  iff  b is x, or b was already in l.
-- (`List.mem_cons` is the library fact: `b ∈ a::l ↔ b = a ∨ b ∈ l`.)
theorem mem_insert (b x : Nat) (l : List Nat) :
    b ∈ insert x l ↔ b = x ∨ b ∈ l := by
  induction l with                       -- split on l's shape; cons gets `ih` (the claim for tail ys)
  | nil => simp [insert]                 -- l = []: insert x [] = [x]; both sides say `b = x`
  | cons y ys ih =>
    by_cases hxy : x ≤ y                  -- the `insert` def branches on x ≤ y, so split on it
    · simp only [insert, if_pos hxy]      -- case x ≤ y: pick the then-branch, insert = x::y::ys
      constructor                         -- prove the ↔ as two implications
      · intro h                           -- (→) assume b ∈ x::y::ys
        rcases List.mem_cons.mp h with h | h  -- it's `b = x`  OR  `b ∈ y::ys`
        · exact Or.inl h                  -- b = x: take the left side of the goal's ∨
        · exact Or.inr h                  -- b ∈ y::ys: take the right side
      · intro h                           -- (←) assume `b = x ∨ b ∈ y::ys`
        rcases h with h | h               -- split that ∨
        · exact List.mem_cons.mpr (Or.inl h)  -- from b = x, b is the head of x::y::ys
        · exact List.mem_cons.mpr (Or.inr h)  -- from b ∈ y::ys, b is in the tail
    · simp only [insert, if_neg hxy]      -- case ¬(x ≤ y): else-branch, insert = y :: insert x ys
      constructor
      · intro h                           -- (→) assume b ∈ y :: insert x ys
        rcases List.mem_cons.mp h with h | h  -- b = y  OR  b ∈ insert x ys
        · exact Or.inr (List.mem_cons.mpr (Or.inl h))  -- b = y ⇒ b ∈ original y::ys ⇒ right side
        · rcases ih.mp h with h | h       -- use IH on `b ∈ insert x ys`: gives b = x OR b ∈ ys
          · exact Or.inl h                -- b = x ⇒ left side
          · exact Or.inr (List.mem_cons.mpr (Or.inr h))  -- b ∈ ys ⇒ b ∈ y::ys ⇒ right side
      · intro h                           -- (←) assume `b = x ∨ b ∈ y::ys`
        rcases h with h | h
        · exact List.mem_cons.mpr (Or.inr (ih.mpr (Or.inl h)))  -- b = x ⇒ (via IH) b ∈ insert x ys ⇒ tail
        · rcases List.mem_cons.mp h with h | h  -- b ∈ y::ys splits into b = y OR b ∈ ys
          · exact List.mem_cons.mpr (Or.inl h)  -- b = y ⇒ head
          · exact List.mem_cons.mpr (Or.inr (ih.mpr (Or.inr h)))  -- b ∈ ys ⇒ (via IH) into insert x ys

/-- Inserting into a sorted list yields a sorted list. -/
-- This proof recurses on the list shape directly (pattern-match in the header)
-- instead of `induction`; the recursive call `sorted_insert x ys ..` IS the IH.
theorem sorted_insert (x : Nat) : ∀ (l : List Nat), Sorted l → Sorted (insert x l)
  | [], _ => by                          -- l = [] (the Sorted proof is unused): insert gives [x]
      simp only [insert]
      -- `Sorted.cons x [] proof Sorted.nil`: build "[x] is sorted". `by simp`
      -- discharges the vacuous bound (nothing is in []); `Sorted.nil` = [] is sorted.
      exact Sorted.cons x [] (by simp) Sorted.nil
  | y :: ys, h => by                      -- l = y::ys with h : Sorted (y::ys)
      cases h with                        -- take apart h into its pieces (it must be a `cons` proof)
      | cons _ _ hbound hys =>            -- hbound : y ≤ every member of ys ;  hys : Sorted ys
        by_cases hxy : x ≤ y              -- insert branches on x ≤ y
        · simp only [insert, if_pos hxy]  -- x ≤ y: result is x :: y :: ys
          -- Goal: Sorted (x::y::ys). Use cons; `?_` leaves the head-bound as a new goal,
          -- the tail "(y::ys) sorted" is rebuilt from hbound+hys.
          refine Sorted.cons x (y :: ys) ?_ (Sorted.cons y ys hbound hys)
          intro b hb                      -- prove x ≤ b for every b ∈ y::ys
          rcases List.mem_cons.mp hb with rfl | hb  -- b = y (rfl substitutes it) OR b ∈ ys
          · exact hxy                     -- b = y: x ≤ y is exactly hxy
          · have := hbound b hb; omega    -- b ∈ ys: y ≤ b (hbound) and x ≤ y ⇒ x ≤ b by arithmetic
        · simp only [insert, if_neg hxy]  -- ¬(x ≤ y): result is y :: insert x ys
          have hyx : y ≤ x := by omega    -- from ¬(x ≤ y) over Nat we get y ≤ x
          -- head stays y; tail is the recursive insert, proven sorted by the IH `sorted_insert x ys hys`
          refine Sorted.cons y (insert x ys) ?_ (sorted_insert x ys hys)
          intro b hb                      -- prove y ≤ b for every b ∈ insert x ys
          rcases (mem_insert b x ys).mp hb with rfl | hb  -- b = x  OR  b ∈ ys (via mem_insert)
          · exact hyx                     -- b = x: y ≤ x is hyx
          · exact hbound b hb             -- b ∈ ys: y ≤ b directly from hbound

/-- Insertion sort always produces a sorted list. -/
-- Term-mode recursion: empty is sorted; otherwise insert the head into the
-- already-sorted tail (`sorted_isort xs` is the IH) and reuse `sorted_insert`.
theorem sorted_isort : ∀ (l : List Nat), Sorted (isort l)
  | []      => Sorted.nil
  | x :: xs => sorted_insert x (isort xs) (sorted_isort xs)

/-- Insertion preserves length (warm-up induction). -/
-- `.length` is the number of elements; goal: insert adds exactly one.
theorem length_insert (x : Nat) (l : List Nat) :
    (insert x l).length = l.length + 1 := by
  induction l with
  | nil => rfl                           -- l = []: both sides compute to 1, so `rfl` closes it
  | cons y ys ih =>
    by_cases hxy : x ≤ y
    · simp [insert, if_pos hxy]          -- then-branch: x::y::ys has length (y::ys).length + 1
    · simp [insert, if_neg hxy, ih]      -- else-branch: y :: insert x ys; `ih` gives the tail's length

/-- Insertion sort preserves length. -/
theorem length_isort (l : List Nat) : (isort l).length = l.length := by
  induction l with
  | nil => rfl                                  -- isort [] = [], lengths both 0
  | cons x xs ih => simp [isort, length_insert, ih]  -- length(insert x (isort xs)) = (isort xs).length+1 = xs.length+1

end Sorting
