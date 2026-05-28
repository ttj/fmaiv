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

-- "Induction, the way you already know it" — Gauss's sum-of-first-n formula.
-- Stated in the doubled form `2 * sumTo n = n * (n + 1)` to stay over Nat
-- without integer division; equivalent to `sumTo n = n*(n+1)/2` since the
-- right side is always even. Mirrors the slide algebra: substitute the IH,
-- then factor (k+1) out of the two terms on the left.
def sumTo : Nat → Nat
  | 0     => 0
  | n + 1 => sumTo n + (n + 1)

theorem gauss (n : Nat) : 2 * sumTo n = n * (n + 1) := by
  induction n with
  | zero =>
    -- BASE.  goal: 2 * sumTo 0 = 0 * (0 + 1)  — both sides reduce to 0
    rfl
  | succ k ih =>
    -- STEP.  ih   : 2 * sumTo k = k * (k + 1)
    --        goal : 2 * sumTo (k+1) = (k+1) * (k+2)
    show 2 * (sumTo k + (k + 1)) = (k + 1) * (k + 2)
    rw [Nat.mul_add, ih]
    -- now:  k * (k + 1) + 2 * (k + 1) = (k + 1) * (k + 2)
    rw [← Nat.add_mul]
    -- now:  (k + 2) * (k + 1) = (k + 1) * (k + 2)
    exact Nat.mul_comm _ _

end SlideExamples
