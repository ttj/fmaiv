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

-- "The sum of two odd numbers is even" — a constructive parity proof.
-- We define `Even` / `Odd` as existentials (Mathlib-free), then show the
-- textbook witness:  a = 2i+1,  b = 2j+1  ⟹  a + b = 2·(i+j+1).
def Even (n : Nat) : Prop := ∃ k, n = 2 * k
def Odd  (n : Nat) : Prop := ∃ k, n = 2 * k + 1

theorem odd_add_odd_even (a b : Nat) (ha : Odd a) (hb : Odd b) :
    Even (a + b) := by
  cases ha with
  | intro i hi =>
    cases hb with
    | intro j hj =>
      -- hi : a = 2*i + 1   hj : b = 2*j + 1
      -- witness: i + j + 1, since (2i+1) + (2j+1) = 2(i+j+1).
      exact ⟨i + j + 1, by omega⟩

-- "The sum of two odds is even" — second proof, by modular arithmetic.
-- Same theorem, different formulation of parity: `n` is even/odd iff
-- `n % 2` equals 0 / 1. The proof is fully written out — no `omega` —
-- using only two core lemmas:
--   • `Nat.add_mod   : (a + b) % n = (a % n + b % n) % n`
--   • `Nat.mod_self  : n % n = 0`
namespace ModArith

def Even (n : Nat) : Prop := n % 2 = 0
def Odd  (n : Nat) : Prop := n % 2 = 1

theorem odd_add_odd_even (a b : Nat) (ha : Odd a) (hb : Odd b) :
    Even (a + b) := by
  -- Goal (after unfolding `Even`):  (a + b) % 2 = 0.
  show (a + b) % 2 = 0
  -- A four-step calculation, each step justified by a single named lemma.
  -- `calc` forces every intermediate equality to be stated explicitly — no
  -- implicit `rfl`-reduction closes the goal early.
  calc (a + b) % 2
      -- (1) push `% 2` through the addition
      = (a % 2 + b % 2) % 2 := Nat.add_mod a b 2
      -- (2) substitute the two parity hypotheses
    _ = (1 + 1) % 2         := by rw [ha, hb]
      -- (3) `1 + 1` reduces to `2` definitionally
    _ = 2 % 2               := rfl
      -- (4) `Nat.mod_self` finishes:  any `n` satisfies `n % n = 0`
    _ = 0                   := Nat.mod_self 2

end ModArith

-- ────────────────────────────────────────────────────────────────────────
-- Series — partial-sum closed forms
-- ────────────────────────────────────────────────────────────────────────
-- A note on the **harmonic series**:  Σ 1/k  in fact DIVERGES (Oresme, 1350)
-- — group the terms as 1 + 1/2 + (1/3+1/4) + (1/5+…+1/8) + … ; each block
-- is ≥ 1/2, so H(2ⁿ) ≥ 1 + n/2.  Stating "diverges" cleanly in Lean wants
-- `Real` / `Rat` / `Filter.Tendsto` — i.e. Mathlib — which this project
-- doesn't pull in.  The discrete, Mathlib-free angle on "convergence"
-- is **partial-sum closed forms**: when a sum has a tidy closed form,
-- the limit can be read off by inspection.  Two classics follow.

-- Geometric series partial sum:  1 + 2 + 4 + ... + 2^n  =  2^(n+1) - 1.
-- Stated as `geomSum2 n + 1 = 2^(n+1)` to avoid Nat subtraction.
-- Convergence reading: dividing both sides by 2^n gives (geomSum2 n)/2^n
-- = 2 - 1/2^n → 2 as n → ∞, so the related series Σ 1/2^k converges to 2.
def geomSum2 : Nat → Nat
  | 0     => 1
  | n + 1 => geomSum2 n + 2 ^ (n + 1)

theorem geomSum2_eq (n : Nat) : geomSum2 n + 1 = 2 ^ (n + 1) := by
  induction n with
  | zero =>
    -- BASE.  geomSum2 0 + 1 = 1 + 1 = 2 = 2^1.
    rfl
  | succ k ih =>
    -- STEP.  goal:  geomSum2 (k+1) + 1 = 2^(k+2)
    --   ↦  (geomSum2 k + 2^(k+1)) + 1
    --   ↦  (geomSum2 k + 1) + 2^(k+1)              (rearrange)
    --   ↦  2^(k+1) + 2^(k+1)                       (IH)
    --   ↦  2 * 2^(k+1) = 2^(k+2)                   (Nat.pow_succ)
    show geomSum2 k + 2 ^ (k + 1) + 1 = 2 ^ (k + 2)
    have hpow : 2 ^ (k + 2) = 2 ^ (k + 1) + 2 ^ (k + 1) := by
      rw [Nat.pow_succ]   -- 2^(k+2) = 2^(k+1) * 2
      omega                -- x * 2 = x + x
    omega                  -- combines `ih` and `hpow` to close

-- Sum of the first n odd numbers:  1 + 3 + 5 + ... + (2n - 1)  =  n^2.
-- Classic visual induction: each odd number adds an L-shape that completes
-- the next square.  Indexed with k from 0 so the (k+1)-st odd is `2*k + 1`
-- (avoids Nat subtraction in the recursion).
def oddSum : Nat → Nat
  | 0     => 0
  | n + 1 => oddSum n + (2 * n + 1)

theorem oddSum_eq (n : Nat) : oddSum n = n * n := by
  induction n with
  | zero => rfl
  | succ k ih =>
    -- STEP.  goal:  oddSum (k+1) = (k+1) * (k+1)
    --   ↦  oddSum k + (2k + 1)
    --   ↦  k*k + (2k + 1)                          (IH)
    --   ↦  (k+1) * (k+1)                           (since (k+1)² = k² + 2k + 1)
    show oddSum k + (2 * k + 1) = (k + 1) * (k + 1)
    rw [ih]
    -- expand RHS: (k+1)(k+1) = k(k+1) + (k+1) = (k*k + k) + (k+1)
    rw [Nat.succ_mul k (k + 1), Nat.mul_succ k k]
    -- now goal:  k*k + (2k + 1) = k*k + k + (k+1)  — linear; `omega` closes.
    omega

end SlideExamples
