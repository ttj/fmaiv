/-
  The counter as a Lean transition system — STARTER (replace each `sorry`).

  Prove the strengthened invariant inductive: `counterInv_init` (holds at the
  start) and `counterInv_step` (preserved by every transition). Once those are
  done, the three INVARSPEC theorems below already follow by strengthening.
  Worked solution: `Counter.lean`.

  Hint for `counterInv_step`: destructure the hypotheses, then
    cases hm : s.mode  →  by_cases hp : s.press = true  →  by_cases hlt : s.x < 10
  using `simp [...] at hmode_next hx_next` to reduce the if-then-else, and
  `omega` for the arithmetic.
-/
import CounterDemo.TransitionSystem

inductive ModeVal where
  | off
  | on
  deriving DecidableEq, Repr

open ModeVal

structure CounterState where
  mode : ModeVal
  press : Bool
  x : Nat
  deriving DecidableEq, Repr

def CounterTS : TransitionSystem CounterState where
  init s := s.mode = .off ∧ s.x = 0
  next s s' :=
    ∃ press' : Bool,
    s'.press = press' ∧
    (if ((s.mode = .off) ∧ (s.press = false)) then s'.mode = .off
    else if ((s.mode = .off) ∧ (s.press = true)) then s'.mode = .on
    else if (((s.mode = .on) ∧ (s.press = false)) ∧ (s.x < 10)) then s'.mode = .on
    else if ((s.mode = .on) ∧ ((s.press = true) ∨ (s.x ≥ 10))) then s'.mode = .off
    else s'.mode = s.mode)
    ∧
    (if (((s.mode = .on) ∧ (s.press = false)) ∧ (s.x < 10)) then s'.x = (s.x + 1)
    else if ((s.mode = .on) ∧ ((s.press = true) ∨ (s.x ≥ 10))) then s'.x = 0
    else s'.x = s.x)

/-- The strengthened invariant (`x ≤ 10` is not inductive alone). -/
def counterInv (s : CounterState) : Prop :=
  s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)

-- TODO: prove the base case (init states satisfy counterInv).
theorem counterInv_init :
    ∀ s, CounterTS.init s → counterInv s := by
  sorry

-- TODO: prove preservation by every transition.
theorem counterInv_step :
    ∀ s s', counterInv s → CounterTS.next s s' → counterInv s' := by
  sorry

theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩

-- These follow once the two lemmas above are proved (no edits needed).
theorem CounterTS_inv1_proved :
    Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)

theorem CounterTS_inv2_proved :
    Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)
