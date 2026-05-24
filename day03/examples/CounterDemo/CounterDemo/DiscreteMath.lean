/-
  Discrete Math in Lean 4
  =======================

  WHAT — Basic set theory definitions and a few classic proofs (subset
         transitivity, De Morgan's law, distribution of ∩ over ∪),
         to illustrate Lean's propositions-as-types paradigm and its
         tactic-based proof style on a friendly domain.

  HOW  — Sets are encoded as predicates: `MySet α := α → Prop`. The
         basic operations (∈, ⊆, ∪, ∩, ᶜ, =) all reduce to logical
         connectives on those predicates. Each proof is a few tactics.

  TACTICS USED HERE — quick glossary:
    • intro x        — pull `x` out of a ∀ or → into the local context
    • apply f        — work backwards via f; sub-goals = f's premises
    • exact e        — close the goal with term `e` (already correct type)
    • constructor    — to prove an Iff or And, give one component per sub-goal
    • left / right   — to prove `P ∨ Q`, choose which side to prove
    • cases h with | inl … | inr …  — case-split on an Or hypothesis
    • ⟨a, b⟩          — anonymous constructor for And/Iff/structures
    • h.1 / h.2      — first / second component of an And
-/

/-- We model sets as predicates: a set of elements of type `α`
    is a function `α → Prop` (true if the element is "in" the set). -/
def MySet (α : Type) := α → Prop

namespace MySet

variable {α : Type}

/-- `x ∈ A` iff the predicate `A` holds at `x`. -/
def mem (x : α) (A : MySet α) : Prop := A x

/-- `A ⊆ B` iff every member of `A` is a member of `B`. -/
def subset (A B : MySet α) : Prop := ∀ x, mem x A → mem x B

/-- `x ∈ A ∪ B` iff `x ∈ A` OR `x ∈ B`. -/
def union (A B : MySet α) : MySet α := fun x => mem x A ∨ mem x B

/-- `x ∈ A ∩ B` iff `x ∈ A` AND `x ∈ B`. -/
def inter (A B : MySet α) : MySet α := fun x => mem x A ∧ mem x B

/-- `x ∈ Aᶜ` iff `x ∉ A`. -/
def compl (A : MySet α) : MySet α := fun x => ¬ mem x A

/-- Set equality: `A = B` as sets iff they have exactly the same members. -/
def seteq (A B : MySet α) : Prop := ∀ x, mem x A ↔ mem x B

/-- ★ Subset is transitive: if A ⊆ B and B ⊆ C, then A ⊆ C.
    STRATEGY: take an arbitrary element x ∈ A and chase it through
    the two given subset proofs. -/
theorem subset_trans (A B C : MySet α)
    (hab : subset A B) (hbc : subset B C) : subset A C := by
  intro x hxa             -- pick a witness x and assume hxa : x ∈ A
  apply hbc               -- to show x ∈ C, reduce to showing x ∈ B (hbc says B ⊆ C)
  apply hab               -- to show x ∈ B, reduce to showing x ∈ A (hab says A ⊆ B)
  exact hxa               -- close: hxa is exactly x ∈ A

/-- ★ De Morgan's law for sets: (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ.
    STRATEGY: extensional proof — pick an arbitrary x and prove the
    biconditional in both directions. The forward direction uses the
    fact that "not in A∪B" means "neither in A nor in B"; the reverse
    glues the two negations back together. -/
theorem demorgan_union (A B : MySet α) :
    seteq (compl (union A B)) (inter (compl A) (compl B)) := by
  intro x                       -- pick an arbitrary element x
  constructor                   -- split the Iff into → and ←
  · intro h                     -- (→) assume h : ¬(x ∈ A∪B); want x ∈ Aᶜ ∩ Bᶜ
    constructor                 -- split the And into the two complements
    · intro ha                  -- show x ∈ Aᶜ, i.e. assume ha : x ∈ A and derive False
      apply h                   -- to derive False, feed h something in (A ∪ B)
      left; exact ha            -- pick the left injection: x ∈ A ∪ B because x ∈ A
    · intro hb                  -- symmetric for x ∈ Bᶜ
      apply h
      right; exact hb           -- right injection: x ∈ A ∪ B because x ∈ B
  · intro ⟨hna, hnb⟩ hab        -- (←) assume both negations and that x ∈ A ∪ B; derive False
    cases hab with              -- case-split on which side of the union we have
    | inl ha => exact hna ha    -- if x ∈ A, hna : ¬(x ∈ A) gives False
    | inr hb => exact hnb hb    -- if x ∈ B, hnb : ¬(x ∈ B) gives False

/-- ★ Intersection distributes over union: A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C).
    STRATEGY: pick x and prove the iff in both directions by case-
    splitting on whichever Or appears in the hypothesis. -/
theorem inter_distrib_union (A B C : MySet α) :
    seteq (inter A (union B C)) (union (inter A B) (inter A C)) := by
  intro x                                          -- pick an element x
  constructor                                      -- split the Iff
  · intro ⟨ha, hbc⟩                                -- (→) destructure: ha : x∈A, hbc : x∈B∨C
    cases hbc with                                 -- case on which side of the union
    | inl hb => left; exact ⟨ha, hb⟩               -- x ∈ B → put result on the left, paired with ha
    | inr hc => right; exact ⟨ha, hc⟩              -- x ∈ C → put result on the right, paired with ha
  · intro h                                        -- (←) assume x ∈ (A∩B) ∪ (A∩C)
    cases h with                                   -- case on which intersection we landed in
    | inl hab => exact ⟨hab.1, Or.inl hab.2⟩       -- (A∩B): keep ha, inject hb on the left of B∨C
    | inr hac => exact ⟨hac.1, Or.inr hac.2⟩       -- (A∩C): keep ha, inject hc on the right of B∨C

end MySet
