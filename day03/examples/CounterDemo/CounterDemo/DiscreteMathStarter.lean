/-
  Discrete Math in Lean 4 — STARTER (replace each `sorry`).
  ========================================================

  A friendly first taste of Lean: basic set theory, with sets encoded as
  predicates (`MySet α := α → Prop`). Prove three classic facts — subset
  transitivity, De Morgan's law, and distribution of ∩ over ∪. Open this file
  in VS Code (Lean 4 extension) and watch the InfoView goal as you type.

  Build just this file (it warns about `sorry` until you finish it):
      cd examples/CounterDemo
      lake build CounterDemo.DiscreteMathStarter

  Worked solution: DiscreteMath.lean. (Vendored from ttj/leansmv.)

  TACTICS: intro x (assume/name) · apply f (work backwards) · exact e (close) ·
  constructor (split Iff/And) · left / right (choose a side of ∨) ·
  cases h with | inl … | inr … (split an ∨) · ⟨a, b⟩ (build And/Iff) · h.1/h.2.
-/

/-- Sets as predicates: a set over `α` is a function `α → Prop`. -/
def MySet (α : Type) := α → Prop

namespace MySet

variable {α : Type}

def mem (x : α) (A : MySet α) : Prop := A x
def subset (A B : MySet α) : Prop := ∀ x, mem x A → mem x B
def union (A B : MySet α) : MySet α := fun x => mem x A ∨ mem x B
def inter (A B : MySet α) : MySet α := fun x => mem x A ∧ mem x B
def compl (A : MySet α) : MySet α := fun x => ¬ mem x A
def seteq (A B : MySet α) : Prop := ∀ x, mem x A ↔ mem x B

-- GOAL: subset is transitive.
theorem subset_trans (A B C : MySet α)
    (hab : subset A B) (hbc : subset B C) : subset A C := by
  sorry   -- `intro x hxa` ; `apply hbc` ; `apply hab` ; `exact hxa`

-- GOAL: De Morgan for sets — (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ.
theorem demorgan_union (A B : MySet α) :
    seteq (compl (union A B)) (inter (compl A) (compl B)) := by
  sorry   -- `intro x` ; `constructor` ; (→) `intro h; constructor` then for each side
          -- `intro ha; apply h; left/right; exact ha`. (←) `intro ⟨hna,hnb⟩ hab;
          -- cases hab with | inl ha => exact hna ha | inr hb => exact hnb hb`.

-- GOAL: ∩ distributes over ∪ — A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C).
theorem inter_distrib_union (A B C : MySet α) :
    seteq (inter A (union B C)) (union (inter A B) (inter A C)) := by
  sorry   -- `intro x; constructor`. (→) `intro ⟨ha, hbc⟩; cases hbc with
          -- | inl hb => left; exact ⟨ha, hb⟩ | inr hc => right; exact ⟨ha, hc⟩`.
          -- (←) `intro h; cases h with | inl hab => exact ⟨hab.1, Or.inl hab.2⟩
          -- | inr hac => exact ⟨hac.1, Or.inr hac.2⟩`.

end MySet
