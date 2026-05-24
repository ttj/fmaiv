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
  Note on inductiveness: for THIS counter `x ≤ 10` is actually inductive on its
  own — the increment is guarded by `x < 10`, so `x' = x + 1 ≤ 10` falls out
  directly (and inv2/inv3 are individually inductive too). We still prove the
  bundled invariant `counterInv = x ≤ 10 ∧ (mode = off → x = 0)` and read each
  INVARSPEC off it via `invariant_strengthening` — one inductive argument yields
  all three. The strengthening *technique* (find a stronger inductive Ψ that
  implies your property) is essential in general; the case where it is genuinely
  FORCED is the two-counter underflow example in the Day-3 slides, not this one.

  Note: the other two specs in counter.smv — `x < 10` and `x ≤ 5` — are NOT
  invariants (x reaches exactly 10), which is why NuSMV reports them false and
  why there is no theorem for them here.

  NOTATION CHEAT-SHEET:
    • inductive .. — define a type by listing its values (here off / on).
    • structure .. where f1:.. f2:.. — a record bundling several fields together;
      `s.mode`, `s.x` read fields out of a state `s`.
    • `.off`       — dotted constructor: the value `off` of the expected type.
    • `s.mode = .off ∧ s.x = 0` — "mode is off AND x is 0" (`∧` = and).
    • `∃ press' : Bool, ..` — "there exists a Bool press' such that .." (the
      nondeterministic input is modeled as something we can choose).
    • `h.1` / `h.2` — first / second component of an "AND" hypothesis h.
    • `⟨a, b⟩`      — anonymous constructor: package a and b into an ∧/structure.
    • `fun s => P s` — anonymous function (here: a predicate on states).
  TACTICS USED HERE:
    • intro h        — assume a hypothesis / ∀-variable, name it h.
    • constructor    — split an "AND" goal into its two parts.
    • simp [h]       — simplify the goal with rule/fact h; `simp [h] at H` rewrites
                       hypothesis H instead of the goal.
    • cases hm : s.mode with .. — split on the value of s.mode, recording the
                       chosen value as the equation `hm` (e.g. hm : s.mode = off).
    • by_cases hp : P — classical split: case P true vs case P false.
    • refine ⟨?_, ?_⟩ — start building an AND, leaving each part as a `?_` hole/goal.
    • omega          — decide linear arithmetic over Nat/Int.
    • rw [h] at H     — rewrite hypothesis H left-to-right using equation h.
    • absurd h hn     — from h : P and hn : ¬P, conclude anything (contradiction).
    • decide          — settle a decidable statement by computing its truth value.
    • rfl             — close `a = a` (both sides equal by computation).
-/
import CounterDemo.TransitionSystem

-- The mode is a two-value type: off or on.
inductive ModeVal where
  | off
  | on
  deriving DecidableEq, Repr   -- auto: an equality test (DecidableEq) and a printer (Repr)

open ModeVal                   -- lets us write `off`/`on` (and `.off`) without the `ModeVal.` prefix

-- A state bundles three fields: the mode, the latest `press` input, and counter x.
structure CounterState where
  mode : ModeVal
  press : Bool
  x : Nat
  deriving DecidableEq, Repr

/-- The transition system, mirroring `next(...)` in counter.smv. The
    nondeterministic SMV `press` input becomes an existentially-quantified
    `press'` in the step relation. -/
def CounterTS : TransitionSystem CounterState where
  -- a start state: mode off and x = 0
  init s := s.mode = .off ∧ s.x = 0
  -- the step relation: s can go to s' when there is some next input press' s.t.
  -- s'.press records it AND s'.mode / s'.x follow the if-then-else rules below.
  next s s' :=
    ∃ press' : Bool,
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

/-- The bundled invariant: `x ≤ 10` conjoined with `mode = off → x = 0`. Each
    conjunct is already inductive on its own for this counter (see the header
    note); we bundle them so one inductive argument discharges all three
    INVARSPECs via `invariant_strengthening`. -/
def counterInv (s : CounterState) : Prop :=
  s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)

/-- BASE CASE: every initial state satisfies the strengthened invariant. -/
theorem counterInv_init :
    ∀ s, CounterTS.init s → counterInv s := by
  intro s ⟨hm, hx⟩            -- take state s and split the init hypothesis: hm : mode=off, hx : x=0
  constructor                 -- counterInv is an AND; prove its two parts
  · simp [hx]                 -- part 1 (x ≤ 10): rewrite x to 0, then 0 ≤ 10 holds
  · intro _; exact hx         -- part 2 (mode=off → x=0): assume the (unneeded) mode fact, give hx

/-- INDUCTIVE STEP: the strengthened invariant is preserved by every transition.
    Case-split on mode, then press, then (when on and !press) on x < 10. -/
theorem counterInv_step :
    ∀ s s', counterInv s → CounterTS.next s s' → counterInv s' := by
  -- take s, s'; destructure the invariant-on-s (hx_le : x≤10, hmode_imp : off→x=0)
  -- and the transition (press' input, hpress, plus hmode_next/hx_next: the rules for s'.mode/s'.x).
  intro s s' ⟨hx_le, hmode_imp⟩ ⟨press', hpress, hmode_next, hx_next⟩
  cases hm : s.mode with                 -- split on the current mode; hm records which it is
  | off =>
    have hx0 := hmode_imp hm             -- since mode=off, the invariant gives us x = 0
    simp [hm, hx0] at hmode_next hx_next  -- plug mode=off and x=0 into the if-rules, simplifying them
    by_cases hp : s.press = true         -- the rules still depend on press; split on it
    · simp [hp] at hmode_next hx_next     -- press=true: mode→on, x stays 0
      refine ⟨?_, ?_⟩                     -- prove counterInv s' = (x'≤10) ∧ (off→x'=0)
      · omega                            -- x' ≤ 10 follows arithmetically (x'=0)
      · intro hm'; rw [hm'] at hmode_next; exact absurd hmode_next (by decide)
                                          -- assume s'.mode=off; but rules force s'.mode=on, so off=on
                                          -- is impossible (`by decide`), and absurd closes any goal
    · simp [hp] at hmode_next hx_next     -- press=false: mode stays off, x stays 0
      refine ⟨?_, ?_⟩
      · omega                            -- x' ≤ 10
      · intro _; exact hx_next           -- off→x'=0: hx_next already says x'=0
  | on =>
    simp [hm] at hmode_next hx_next       -- mode=on: simplify the if-rules with that fact
    by_cases hp : s.press = true
    · simp [hp] at hmode_next hx_next     -- on & press=true: reset branch, x'=0, mode→off
      refine ⟨?_, ?_⟩
      · omega                            -- x' ≤ 10
      · intro _; exact hx_next           -- off→x'=0 holds since x'=0
    · simp [hp] at hmode_next hx_next     -- on & press=false: behavior depends on x<10
      by_cases hlt : s.x < 10
      · simp [hlt] at hmode_next hx_next  -- x<10: increment branch, x'=x+1, mode→on
        refine ⟨?_, ?_⟩
        · omega                          -- x'=x+1 and x<10 give x' ≤ 10
        · intro hm'; rw [hm'] at hmode_next; exact absurd hmode_next (by decide)
                                          -- mode is on here, so s'.mode=off is contradictory
      · have hge : 10 ≤ s.x := Nat.le_of_not_lt hlt  -- ¬(x<10) means x ≥ 10
        simp [hlt, hge] at hmode_next hx_next        -- x≥10: reset branch, x'=0, mode→off
        refine ⟨?_, ?_⟩
        · omega                          -- x' ≤ 10 (x'=0)
        · intro _; exact hx_next         -- off→x'=0 holds since x'=0

/-- Bundle init- and step-preservation into the InductiveInvariant predicate. -/
-- InductiveInvariant is an AND of the two facts; `⟨_, _⟩` pairs them (term mode).
theorem counterInv_inductive : InductiveInvariant CounterTS counterInv :=
  ⟨counterInv_init, counterInv_step⟩

/-- INVARSPEC 1: `x ≤ 10` on every reachable state (first conjunct). -/
-- `invariant_strengthening` (from the framework): a strong inductive invariant
-- plus an implication gives a weaker invariant. Here `fun _ h => h.1` is the
-- implication "counterInv s → x ≤ 10" (just take the first half of the AND).
theorem CounterTS_inv1_proved :
    Invariant CounterTS (fun s => s.x ≤ 10) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.1)

/-- INVARSPEC 2: `mode = off → x = 0` on every reachable state (second conjunct). -/
-- Same recipe; `fun _ h => h.2` extracts the second half of counterInv.
theorem CounterTS_inv2_proved :
    Invariant CounterTS (fun s => s.mode = .off → s.x = 0) :=
  invariant_strengthening CounterTS counterInv _ counterInv_inductive (fun _ h => h.2)

/-- INVARSPEC 3: `x > 0 → mode = on` on every reachable state. If mode were off,
    the strengthened invariant forces x = 0, contradicting x > 0. -/
theorem CounterTS_inv3_proved :
    Invariant CounterTS (fun s => s.x > 0 → s.mode = .on) := by
  apply invariant_strengthening CounterTS counterInv   -- reduce goal to the premises of that lemma
  · exact counterInv_inductive                         -- premise 1: counterInv is inductive (proved above)
  · intro s ⟨_, hoff⟩ hxpos                             -- premise 2: assume counterInv s (hoff : off→x=0) and hxpos : x>0
    cases hm : s.mode with                              -- split on the mode
    | off => exact absurd (hoff hm) (by omega)          -- off ⇒ x=0 (hoff hm), contradicting x>0; absurd finishes
    | on  => rfl                                        -- on ⇒ goal is `on = on`, true by rfl
