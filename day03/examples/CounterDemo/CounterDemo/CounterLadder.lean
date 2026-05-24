/-
  A guided tactic "ladder" for the running counter — full solution.
  =================================================================

  Day 3 jumps quickly to full inductive proofs. This file is the on-ramp:
  six short "rungs", each isolating ONE tactic or idea, climbing to the real
  base case of the counter's inductive invariant (`counterInv_init` from
  Counter.lean). Think of it as a Natural-Number-Game level set, but on our
  own running example.

  Do them in order — each rung uses a skill from the one before:
    rung1  omega           — close pure arithmetic
    rung2  h.1 / h.2       — take one side of an AND hypothesis
    rung3  constructor      — prove an AND goal, one bullet per side
    rung4  modus ponens     — apply an implication hypothesis (h hoff)
    rung5  cases            — split on the mode (off / on)
    rung6  CAPSTONE         — assemble the base case from the rungs above

  Starter (with each rung left as a stub to fill): CounterLadderStarter.lean
  Next climb after this: the inductive STEP, `counterInv_step` in Counter.lean.
-/
import CounterDemo.Counter

namespace CounterLadder

-- RUNG 1 — `omega` decides linear arithmetic over Nat/Int. No setup needed.
theorem rung1_omega (x : Nat) (h : x < 10) : x + 1 ≤ 10 := by
  omega

-- RUNG 2 — an AND hypothesis `h : A ∧ B` splits as `h.1 : A` and `h.2 : B`.
-- `counterInv s` is by definition `s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)`.
theorem rung2_and_elim (s : CounterState) (h : counterInv s) : s.x ≤ 10 := by
  exact h.1

-- RUNG 3 — to PROVE an AND, `constructor` makes one sub-goal per side; address
-- each with a `·` bullet. (Here the second side is exactly the hypothesis h.)
theorem rung3_and_intro (s : CounterState) (h : s.x = 0) :
    s.x ≤ 10 ∧ s.x = 0 := by
  constructor
  · omega
  · exact h

-- RUNG 4 — modus ponens: an implication `h : P → Q` applied to a proof of P
-- gives Q. Just write `h hoff`.
theorem rung4_modus_ponens (s : CounterState)
    (h : s.mode = .off → s.x = 0) (hoff : s.mode = .off) : s.x = 0 := by
  exact h hoff

-- RUNG 5 — `cases hm : s.mode with` splits the proof into one branch per value
-- of the mode, recording the choice as `hm` (e.g. `hm : s.mode = off`).
theorem rung5_cases (s : CounterState) : s.mode = .off ∨ s.mode = .on := by
  cases hm : s.mode with
  | off => exact Or.inl hm
  | on  => exact Or.inr hm

-- RUNG 6 — CAPSTONE. Every initial state satisfies the strengthened invariant.
-- This IS `counterInv_init` (Counter.lean), now assembled from the rungs:
-- split the init hypothesis (mode = off, x = 0), then prove the AND.
theorem rung6_base_case : ∀ s, CounterTS.init s → counterInv s := by
  intro s ⟨hm, hx⟩            -- hm : s.mode = .off,  hx : s.x = 0
  constructor                 -- counterInv is an AND; prove both sides
  · simp [hx]                 -- x ≤ 10 : rewrite x to 0, then 0 ≤ 10
  · intro _; exact hx         -- mode = off → x = 0 : hand back hx

end CounterLadder
