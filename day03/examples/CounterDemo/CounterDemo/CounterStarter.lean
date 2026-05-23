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

  NOTATION: `structure .. where` is a record; `s.mode`/`s.x` read its fields;
  `.off` is a dotted constructor; `∧` and; `∃ p : Bool, ..` "there is a Bool p s.t.";
  `h.1`/`h.2` the two halves of an AND; `⟨a, b⟩` packs an AND/structure.
  TACTICS: `intro h` (assume/name), `constructor` (split an AND goal),
  `cases hm : s.mode with` (split on the mode, recording it as `hm`),
  `by_cases hp : P` (split P vs ¬P), `simp [h] at H` (simplify hypothesis H),
  `refine ⟨?_, ?_⟩` (build an AND leaving holes), `omega` (Nat arithmetic),
  `rw [h] at H`, `absurd h hn` (contradiction), `decide`, `rfl`.
-/
import CounterDemo.TransitionSystem

-- Mode: two values, off or on.
inductive ModeVal where
  | off
  | on
  deriving DecidableEq, Repr   -- auto equality test + printer

open ModeVal                   -- write off/on without the ModeVal. prefix

-- A state = mode + latest press input + counter x.
structure CounterState where
  mode : ModeVal
  press : Bool
  x : Nat
  deriving DecidableEq, Repr

-- The transition system: init = (off, x=0); next encodes the press/increment/reset rules.
def CounterTS : TransitionSystem CounterState where
  init s := s.mode = .off ∧ s.x = 0
  next s s' :=
    ∃ press' : Bool,                       -- pick the next nondeterministic input
    s'.press = press' ∧
    -- next mode: press flips off↔on; in on, count up while x<10, else reset to off
    (if ((s.mode = .off) ∧ (s.press = false)) then s'.mode = .off
    else if ((s.mode = .off) ∧ (s.press = true)) then s'.mode = .on
    else if (((s.mode = .on) ∧ (s.press = false)) ∧ (s.x < 10)) then s'.mode = .on
    else if ((s.mode = .on) ∧ ((s.press = true) ∨ (s.x ≥ 10))) then s'.mode = .off
    else s'.mode = s.mode)
    ∧
    -- next x: +1 when on & !press & x<10; reset to 0 on press-or-x≥10; otherwise unchanged
    (if (((s.mode = .on) ∧ (s.press = false)) ∧ (s.x < 10)) then s'.x = (s.x + 1)
    else if ((s.mode = .on) ∧ ((s.press = true) ∨ (s.x ≥ 10))) then s'.x = 0
    else s'.x = s.x)

/-- The strengthened invariant (`x ≤ 10` is not inductive alone). -/
-- Two parts: x ≤ 10, AND (whenever mode is off, x is 0).
def counterInv (s : CounterState) : Prop :=
  s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)

-- GOAL: every initial state satisfies counterInv.
-- TODO: prove the base case (init states satisfy counterInv).
theorem counterInv_init :
    ∀ s, CounterTS.init s → counterInv s := by
  sorry   -- PROVE THIS: `intro s ⟨hm, hx⟩` (hm : mode=off, hx : x=0), `constructor`,
          -- part 1 `simp [hx]` (0 ≤ 10), part 2 `intro _; exact hx`.

-- GOAL: every transition preserves counterInv (the inductive step).
-- TODO: prove preservation by every transition.
theorem counterInv_step :
    ∀ s s', counterInv s → CounterTS.next s s' → counterInv s' := by
  sorry   -- PROVE THIS: `intro s s' ⟨hx_le, hmode_imp⟩ ⟨press', hpress, hmode_next, hx_next⟩`,
          -- then `cases hm : s.mode with` → `by_cases hp : s.press = true` → (when on & !press)
          -- `by_cases hlt : s.x < 10`. In each leaf: `simp [..] at hmode_next hx_next` to collapse
          -- the if-then-else, `refine ⟨?_, ?_⟩`, `omega` for x' ≤ 10, and for the off→x'=0 part
          -- either `intro _; exact hx_next` or derive a contradiction (`rw`/`absurd`/`decide`).

-- Bundles the two facts above into one (no edits needed once they're proved).
theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩

-- These follow once the two lemmas above are proved (no edits needed).
theorem CounterTS_inv1_proved :
    Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)

theorem CounterTS_inv2_proved :
    Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)
