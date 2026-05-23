/-
SlideExamples.lean — the standalone Lean snippets shown on the Day 3 slides,
collected so `lake build` (and scripts/check_examples.sh / CI) compiles and
checks every one. Kept verbatim from the deck, wrapped in a namespace to avoid
clashing with core names. No Mathlib.
-/
namespace SlideExamples

-- "A tiny term-mode proof of each connective" — proofs ARE programs
example (p : Prop) : p → p :=
  fun hp => hp                          -- given a proof of p, hand it straight back

example (p q : Prop) : p → (q → p) :=
  fun hp => fun _ => hp                 -- given p (and anything), return the p

example (p q : Prop) (hp : p) (hq : q) : p ∧ q :=
  ⟨hp, hq⟩

example (p q : Prop) (hp : p) : p ∨ q :=
  Or.inl hp                            -- "left" injection

example : ∃ n : Nat, n + 1 = 4 :=
  ⟨3, rfl⟩                              -- witness 3; rfl proves 3 + 1 = 4

-- "def, theorem, example" + "#print" slides
theorem two_plus_two : 2 + 2 = 4 := by
  rfl

def double (n : Nat) : Nat := n + n

theorem double_zero : double 0 = 0 := rfl

-- "The same induction, in Lean (from scratch)"
theorem zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero =>
    rfl
  | succ k ih =>
    rw [Nat.add_succ]
    rw [ih]

end SlideExamples
