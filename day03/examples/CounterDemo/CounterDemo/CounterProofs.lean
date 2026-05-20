/-
  Proofs of Invariant Properties for the Counter Model
  =====================================================

  WHAT — The auto-generated `Counter.lean` defines a small NuXMV-style
         transition system (mode ∈ {off,on}, press : Bool, x : Nat ≤ 25)
         and stubs out three INVARSPEC theorems with `sorry`. Here we
         REPLACE those stubs with real proofs:
           inv1 :  x ≤ 10
           inv2 :  mode = off → x = 0
           inv3 :  x > 0    → mode = on

  HOW  — Mutual exclusion of these three properties alone is *not*
         enough to be inductive. We define a STRENGTHENED invariant
            counterInv s ≡  (s.x ≤ 10) ∧ (s.mode = off → s.x = 0)
         prove it inductive (init + step preservation), and then derive
         each individual INVARSPEC by `invariant_strengthening`.

  PROOF SHAPE — three steps:
    1. counterInv_init       — base case: invariant holds at start
    2. counterInv_step       — preserved by every transition
                               (case-split on mode, then on press, then on x<10)
    3. wrap into InductiveInvariant and read off each spec via strengthening

  TACTICS USED HERE — quick glossary:
    • intro / exact / refine / cases — see TransitionSystem.lean
    • by_cases h : P     — split into two branches (h : P) and (h : ¬P)
    • simp [hp] at h     — simplify h using hp as a rewrite rule + simp set
    • omega              — discharge linear-arithmetic goals over Nat / Int
    • absurd hp hnp      — from hp : P and hnp : ¬P, derive any goal
    • by decide          — Lean computes the answer for a decidable claim
    • cases hm : s.mode with | off => … | on => …
                         — split on s.mode, naming the equation as hm
                           (so subsequent `simp [hm]` substitutes mode=off, etc.)
-/
import CounterDemo.TransitionSystem
import CounterDemo.Counter

open ModeVal     -- bring `off`, `on` into scope so we can write `.off` / `.on`

/-- The strengthened invariant we'll prove inductive.
    Combines INVARSPEC 1 (`x ≤ 10`) with INVARSPEC 2 (`mode=off → x=0`).
    Neither holds inductively on its own; the conjunction does. -/
def counterInv (s : CounterState) : Prop :=
  s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)

/-- BASE CASE: every initial state satisfies the strengthened invariant.
    Initial state has `mode = off` and `x = 0`, so both clauses are trivial. -/
theorem counterInv_init :
    ∀ s, CounterTS.init s → counterInv s := by
  intro s ⟨hm, hx⟩         -- destructure init: hm : mode = off, hx : x = 0
  constructor              -- split goal counterInv = "x ≤ 10 ∧ (mode=off → x=0)" into two parts
  · simp [hx]              -- first part: x ≤ 10. Substitute hx (x = 0) and simp closes it.
  · intro _; exact hx      -- second part: assume mode=off (anonymous), conclude x=0 directly via hx

/-- INDUCTIVE STEP: the strengthened invariant is preserved by every transition.
    The big case-split tree:  mode=off / on  →  press=true / false  →  (when on, !press) x<10 / x≥10.
    `simp [...] at ...` reduces the if-then-else encoded transition to a single
    equation per branch; then we discharge with `omega` or by direct rewriting. -/
theorem counterInv_step :
    ∀ s s', counterInv s → CounterTS.next s s' → counterInv s' := by
  intro s s' ⟨hx_le, hmode_imp⟩ ⟨press', hpress, hmode_next, hx_next⟩
                                    -- destructure: counterInv s and the transition's conjuncts
                                    --   press' is the chosen value for the input variable
                                    --   hmode_next, hx_next are the unsimplified if-then-else equations
  cases hm : s.mode with            -- split on the current mode; hm records which branch
  | off =>
    have hx0 := hmode_imp hm        -- hmode_imp says mode=off → x=0; combined with hm get x=0
    simp [hm, hx0] at hmode_next hx_next
                                    -- substitute mode=off and x=0 in the if-then-else hypotheses
    by_cases hp : s.press = true    -- now the only thing left to vary is press
    · simp [hp] at hmode_next hx_next
                                    -- press=true branch: hmode_next reduces to s'.mode = on, hx_next to s'.x = 0
      refine ⟨?_, ?_⟩               -- prove counterInv s' = "s'.x ≤ 10 ∧ (s'.mode=off → s'.x = 0)"
      · omega                       -- s'.x = 0, so s'.x ≤ 10 by arithmetic
      · intro hm'; rw [hm'] at hmode_next; exact absurd hmode_next (by decide)
                                    -- if s'.mode = off, contradicts hmode_next : s'.mode = on
    · simp [hp] at hmode_next hx_next
                                    -- press=false branch: stays off, x stays 0
      refine ⟨?_, ?_⟩
      · omega                       -- s'.x = 0 again
      · intro _; exact hx_next      -- assume s'.mode = off; we have s'.x = 0 directly
  | on =>
    simp [hm] at hmode_next hx_next -- substitute mode=on
    by_cases hp : s.press = true
    · -- press=true: mode → off, x → 0
      simp [hp] at hmode_next hx_next
      refine ⟨?_, ?_⟩
      · omega                       -- s'.x = 0 ⇒ ≤ 10
      · intro _; exact hx_next      -- s'.mode = off so we need s'.x = 0, which we have
    · -- press=false: behaviour depends on whether x < 10
      simp [hp] at hmode_next hx_next
      by_cases hlt : s.x < 10
      · simp [hlt] at hmode_next hx_next
                                    -- on, !press, x<10: increment x, stay on
        refine ⟨?_, ?_⟩
        · omega                     -- new x = old x + 1, and old x < 10 ⇒ new x ≤ 10
        · intro hm'; rw [hm'] at hmode_next; exact absurd hmode_next (by decide)
                                    -- s'.mode = off contradicts s'.mode = on
      · -- x ≥ 10 branch (last remaining case)
        have hge : 10 ≤ s.x := Nat.le_of_not_lt hlt
                                    -- from ¬(x < 10) we get 10 ≤ x
        simp [hlt, hge] at hmode_next hx_next
                                    -- on, !press, x ≥ 10: switches off, resets x to 0
        refine ⟨?_, ?_⟩
        · omega                     -- s'.x = 0 ≤ 10
        · intro _; exact hx_next    -- s'.mode = off ⇒ s'.x = 0, which we have

/-- Bundle init- and step-preservation into the InductiveInvariant predicate. -/
theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩

/- ------------------------------------------------------------------- -/
/- Now derive each individual INVARSPEC from the strengthened invariant. -/

/-- INVARSPEC 1: `x ≤ 10` on every reachable state.
    Trivially the first conjunct of counterInv, via strengthening. -/
theorem CounterTS_inv1_proved :
    Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)
                                    -- pull out the first component (h.1) of counterInv at every reachable state

/-- INVARSPEC 2: `mode = off → x = 0` on every reachable state.
    The second conjunct of counterInv, via strengthening. -/
theorem CounterTS_inv2_proved :
    Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)
                                    -- pull out h.2

/-- INVARSPEC 3: `x > 0 → mode = on` on every reachable state.
    Equivalent to the contrapositive of inv2. We strengthen via counterInv
    and discharge by case-splitting on what mode actually is.
    STRATEGY: assume x > 0; mode is either off or on; if off, then x = 0
    by the strengthened invariant, contradicting x > 0; otherwise mode = on. -/
theorem CounterTS_inv3_proved :
    Invariant CounterTS (fun s => s.x > 0 → s.mode = .on) := by
  apply invariant_strengthening CounterTS counterInv     -- strengthen via counterInv
  · exact counterInv_inductive                           -- the strong invariant is inductive
  · intro s ⟨_, hoff⟩ hxpos                              -- _hxle, hoff : mode=off → x=0; hxpos : x > 0
    cases hm : s.mode with                               -- enumerate the mode values
    | off => exact absurd (hoff hm) (by omega)           -- mode=off ⇒ x=0, contradicting hxpos
    | on  => rfl                                         -- mode=on ⇒ goal is mode = on, trivially
