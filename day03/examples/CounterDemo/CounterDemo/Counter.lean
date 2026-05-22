/-
  The counter as a Lean transition system — full solution.
  ========================================================

  The same "counter to 10" we model-check in Day 2 (counter.smv) and encode in
  Z3 / C / Cryptol, here as a `TransitionSystem` with its safety invariants
  proved. The starter (with the proofs stubbed out) is `CounterStarter.lean`.

  The system: mode ∈ {off, on}, a boolean `press` input, and x : Nat. From off,
  a press flips to on; in on, !press increments x while x < 10; press or x ≥ 10
  returns to (off, 0).

  We prove the three INVARSPECs that hold (matching the three that NuSMV reports
  `true` for counter.smv):
      inv1 :  x ≤ 10
      inv2 :  mode = off → x = 0
      inv3 :  x > 0    → mode = on
  The key idea (the Day-3 insight): `x ≤ 10` alone is NOT inductive — you must
  strengthen it with `mode = off → x = 0`. We prove the strengthened invariant
  inductive, then read each INVARSPEC off it via `invariant_strengthening`.

  Note: the other two specs in counter.smv — `x < 10` and `x ≤ 5` — are NOT
  invariants (x reaches exactly 10), which is why NuSMV reports them false and
  why there is no theorem for them here.
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

/-- The transition system, mirroring `next(...)` in counter.smv. The
    nondeterministic SMV `press` input becomes an existentially-quantified
    `press'` in the step relation. -/
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

/-- The strengthened invariant: `x ≤ 10` conjoined with `mode = off → x = 0`.
    Neither holds inductively on its own; the conjunction does. -/
def counterInv (s : CounterState) : Prop :=
  s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)

/-- BASE CASE: every initial state satisfies the strengthened invariant. -/
theorem counterInv_init :
    ∀ s, CounterTS.init s → counterInv s := by
  intro s ⟨hm, hx⟩
  constructor
  · simp [hx]
  · intro _; exact hx

/-- INDUCTIVE STEP: the strengthened invariant is preserved by every transition.
    Case-split on mode, then press, then (when on and !press) on x < 10. -/
theorem counterInv_step :
    ∀ s s', counterInv s → CounterTS.next s s' → counterInv s' := by
  intro s s' ⟨hx_le, hmode_imp⟩ ⟨press', hpress, hmode_next, hx_next⟩
  cases hm : s.mode with
  | off =>
    have hx0 := hmode_imp hm
    simp [hm, hx0] at hmode_next hx_next
    by_cases hp : s.press = true
    · simp [hp] at hmode_next hx_next
      refine ⟨?_, ?_⟩
      · omega
      · intro hm'; rw [hm'] at hmode_next; exact absurd hmode_next (by decide)
    · simp [hp] at hmode_next hx_next
      refine ⟨?_, ?_⟩
      · omega
      · intro _; exact hx_next
  | on =>
    simp [hm] at hmode_next hx_next
    by_cases hp : s.press = true
    · simp [hp] at hmode_next hx_next
      refine ⟨?_, ?_⟩
      · omega
      · intro _; exact hx_next
    · simp [hp] at hmode_next hx_next
      by_cases hlt : s.x < 10
      · simp [hlt] at hmode_next hx_next
        refine ⟨?_, ?_⟩
        · omega
        · intro hm'; rw [hm'] at hmode_next; exact absurd hmode_next (by decide)
      · have hge : 10 ≤ s.x := Nat.le_of_not_lt hlt
        simp [hlt, hge] at hmode_next hx_next
        refine ⟨?_, ?_⟩
        · omega
        · intro _; exact hx_next

/-- Bundle init- and step-preservation into the InductiveInvariant predicate. -/
theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩

/-- INVARSPEC 1: `x ≤ 10` on every reachable state (first conjunct). -/
theorem CounterTS_inv1_proved :
    Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)

/-- INVARSPEC 2: `mode = off → x = 0` on every reachable state (second conjunct). -/
theorem CounterTS_inv2_proved :
    Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)

/-- INVARSPEC 3: `x > 0 → mode = on` on every reachable state. If mode were off,
    the strengthened invariant forces x = 0, contradicting x > 0. -/
theorem CounterTS_inv3_proved :
    Invariant CounterTS (fun s => s.x > 0 → s.mode = .on) := by
  apply invariant_strengthening CounterTS counterInv
  · exact counterInv_inductive
  · intro s ⟨_, hoff⟩ hxpos
    cases hm : s.mode with
    | off => exact absurd (hoff hm) (by omega)
    | on  => rfl
