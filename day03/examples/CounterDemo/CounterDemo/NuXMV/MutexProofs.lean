/-
  Mutual Exclusion Proof for the 2-Process Mutex Model
  =====================================================

  WHAT — The auto-generated `Mutex.lean` encodes a Peterson-style 2-process
         mutual-exclusion protocol with a shared `turn` variable and per-
         process `flag` variables. Here we prove the safety property
            ¬(process1 = critical ∧ process2 = critical)
         on every reachable state — i.e. genuine mutual exclusion.

  HOW  — Mutual exclusion ALONE is not inductive. We strengthen it with
         two coupling bi-implications:
            (p1 ∈ {waiting, critical})  ↔  (flag1 = true)
            (p2 ∈ {waiting, critical})  ↔  (flag2 = true)
         With these in hand, the punchline argument is:
           "for both processes to enter `critical` simultaneously, both
            were `waiting`, hence flag1 = flag2 = true; the entry
            conditions then demand turn = 1 AND turn = 2 — contradiction."

  PROOF SHAPE
    1. mutexInv               — the strengthened invariant (3 conjuncts)
    2. mutexInv_init          — base case
    3. p1_flag1_coupling      — single-step preservation of the p1↔flag1 bi-imp
    4. p2_flag2_coupling      — symmetric for p2↔flag2
    5. mutexInv_step          — main step: combines (3),(4) and proves mutex
                                via the "both must come from waiting" punchline
    6. mutexInv_inductive     — bundles (2) + (5)
    7. MutexTS_mutual_exclusion — the final invariant via strengthening

  TACTICS USED HERE — quick glossary:
    • intro / exact / refine / cases / simp / rw / by_cases — see prior files
    • rintro ⟨a, b⟩          — `intro` that destructures inline
    • rintro (a | b)         — `intro` that destructures an Or, introducing two sub-goals
    • rcases h with a | b    — destructure h on Or, branching
    • rcases h with ⟨a,b⟩   — destructure h on And/Exists/struct
    • absurd hp hnp          — from hp:P and hnp:¬P, derive any goal
    • by decide              — Lean's decision procedure for decidable claims
    • simp [h] at h₁ h₂      — simplify h₁ and h₂ using h plus the simp set
    • simp_all [defs]        — apply simp to ALL hypotheses + goal, with `defs` as extra rewrites
    • <;> tac                — apply `tac` to every sub-goal produced by the previous tactic
    • Iff intro/elim         — `Iff` is built by `⟨forward, backward⟩` and used via `.mp` / `.mpr`
-/
import CounterDemo.TransitionSystem
import CounterDemo.NuXMV.Mutex

/-- A process is "in the lock region" iff it is waiting OR in critical. -/
def p1InLock (s : MutexState) : Prop :=
  s.process1 = .waiting ∨ s.process1 = .critical

/-- Symmetric for process 2. -/
def p2InLock (s : MutexState) : Prop :=
  s.process2 = .waiting ∨ s.process2 = .critical

/-- The strengthened invariant: two flag-couplings + safety. -/
def mutexInv (s : MutexState) : Prop :=
  (p1InLock s ↔ s.flag1 = true) ∧
  (p2InLock s ↔ s.flag2 = true) ∧
  ¬(s.process1 = .critical ∧ s.process2 = .critical)

/-- Tiny Bool fact we need: if `b ≠ true` then `b = false`. Lean 4 core
    knows this only as a simp-lemma; we package it here for clarity. -/
theorem bool_not_true_eq_false {b : Bool} (h : ¬(b = true)) : b = false := by
  cases b      -- Bool has only two constructors: false, true
  · rfl        -- case b = false: goal is `false = false`
  · exact absurd rfl h    -- case b = true: rfl proves true = true, contradicting h

/- ------------------------------------------------------------------- -/
/- BASE CASE: the invariant holds on every initial state.              -/

/-- mutexInv holds initially (everyone idle, both flags false, no critical). -/
theorem mutexInv_init : ∀ s, MutexTS.init s → mutexInv s := by
  intro s ⟨hp1, hp2, _hturn, hf1, hf2⟩    -- destructure init: p1=idle, p2=idle, turn=1, flag1=false, flag2=false
  refine ⟨?_, ?_, ?_⟩                     -- prove each of the three conjuncts of mutexInv
  · constructor                           -- first conjunct is an Iff: prove both directions
    · intro hlock                         -- (→) assume p1InLock; derive flag1=true
      cases hlock <;> simp_all [p1InLock] -- p1 was either waiting or critical, but hp1 says idle: contradiction
    · intro ht                            -- (←) assume flag1=true; derive p1InLock (false because flag1=false)
      rw [hf1] at ht; exact absurd ht (by decide)   -- substitute flag1=false; "false=true" is absurd
  · constructor                           -- second conjunct: symmetric for p2/flag2
    · intro hlock; cases hlock <;> simp_all [p2InLock]
    · intro ht; rw [hf2] at ht; exact absurd ht (by decide)
  · rintro ⟨h1c, _⟩                       -- third conjunct (mutex): assume both critical, derive False
    rw [hp1] at h1c; exact absurd h1c (by decide)   -- hp1 says p1=idle, contradicting h1c : p1=critical

/- ------------------------------------------------------------------- -/
/- COUPLING LEMMA 1: p1 ∈ {waiting, critical}  ↔  flag1 = true,        -/
/- after a single transition, given the bi-imp held before.            -/

/-- After one transition, the (p1 ∈ lock-region) ↔ (flag1 = true) coupling
    is preserved.
    STRATEGY: case-split on the *current* `s.process1` (idle / waiting /
    critical). In each case, the two if-then-else encoded transitions
    (`hp1_next` and `hf1_next`) collapse via `simp [hidle/hwait/hcrit]`
    into concrete equations, after which the bi-implication's two
    directions discharge by direct rewriting. -/
theorem p1_flag1_coupling (s s' : MutexState)
    (hpre : p1InLock s ↔ s.flag1 = true)
    (hp1_next :
      (if (s.process1 = .idle) then (s'.process1 = .idle ∨ s'.process1 = .waiting)
       else if ((s.process1 = .waiting) ∧ ((s.flag2 = false) ∨ (s.turn = 1)))
            then s'.process1 = .critical
       else if (s.process1 = .critical) then s'.process1 = .idle
       else s'.process1 = s.process1))
    (hf1_next :
      (if ((s.process1 = .idle) ∧ (s'.process1 = .waiting)) then s'.flag1 = true
       else if ((s.process1 = .critical) ∧ (s'.process1 = .idle)) then s'.flag1 = false
       else s'.flag1 = s.flag1)) :
    p1InLock s' ↔ s'.flag1 = true := by
  by_cases hidle : s.process1 = .idle
  · -- ── PRE-STATE = idle ───────────────────────────────────────────
    -- Idle ⇒ ¬p1InLock; combined with hpre that means flag1 = false.
    have hnotlock : ¬ p1InLock s := by
      rintro (hw | hc)                      -- p1InLock unfolds to "p1 = waiting ∨ p1 = critical"
      · rw [hidle] at hw; exact absurd hw (by decide)   -- hw : idle = waiting (impossible)
      · rw [hidle] at hc; exact absurd hc (by decide)   -- hc : idle = critical (impossible)
    have hpre_f1 : s.flag1 = false :=
      bool_not_true_eq_false (fun ht => hnotlock (hpre.mpr ht))
                                            -- if flag1 = true then hpre.mpr gives p1InLock — contradicting hnotlock
    simp [hidle] at hp1_next                -- collapse the if-then-else to "s'.p1 = idle ∨ s'.p1 = waiting"
    rcases hp1_next with h | h              -- two sub-cases: stay idle, or move to waiting
    · -- s'.p1 = idle
      simp [hidle, h] at hf1_next           -- only the else branch fires; hf1_next : s'.flag1 = s.flag1
      rw [hpre_f1] at hf1_next              -- substitute s.flag1 = false; now hf1_next : s'.flag1 = false
      constructor                           -- prove both directions of the conclusion's Iff
      · rintro (hw | hc)                    -- (→) assume p1InLock s' → derive False
        · rw [h] at hw; exact absurd hw (by decide)   -- s'.p1 = idle but hw says waiting
        · rw [h] at hc; exact absurd hc (by decide)   -- ditto for critical
      · intro ht                            -- (←) assume s'.flag1 = true → derive p1InLock
        rw [hf1_next] at ht; exact absurd ht (by decide)   -- but flag1 = false ≠ true
    · -- s'.p1 = waiting
      simp [hidle, h] at hf1_next           -- the "p1 was idle, p1' is waiting" branch fires; flag1' = true
      exact ⟨fun _ => hf1_next, fun _ => Or.inl h⟩
                                            -- (→) flag1' = true unconditionally; (←) p1' = waiting → p1InLock
  · -- ── PRE-STATE ≠ idle: try waiting next ──────────────────────────
    by_cases hwait : s.process1 = .waiting
    · have hpre_f1 : s.flag1 = true := hpre.mp (Or.inl hwait)
                                            -- waiting ∈ lock-region ⇒ flag1 = true
      simp [hidle, hwait] at hp1_next       -- the second-if branch fires; condition is the entry guard
      by_cases hcond : (s.flag2 = false) ∨ (s.turn = 1)
      · simp [hcond] at hp1_next            -- entry condition true → s'.p1 = critical
        simp [hwait, hp1_next] at hf1_next  -- neither flag1-update fires (p1 was waiting, p1' is critical)
        rw [hpre_f1] at hf1_next            -- so flag1' = flag1 = true
        exact ⟨fun _ => hf1_next, fun _ => Or.inr hp1_next⟩
                                            -- s'.p1 = critical so it's in the lock region
      · simp [hcond] at hp1_next            -- entry condition false → s'.p1 = waiting (stays)
        simp [hwait, hp1_next] at hf1_next  -- flag1' = flag1 (no rule fires)
        rw [hpre_f1] at hf1_next            -- so flag1' = true
        exact ⟨fun _ => hf1_next, fun _ => Or.inl hp1_next⟩
    · -- ── PRE-STATE = critical (only remaining case) ────────────────
      have hcrit : s.process1 = .critical := by
        cases h : s.process1                -- enumerate all three constructors of Process1Val
        · exact absurd h hidle              -- ruled out by hidle
        · exact absurd h hwait              -- ruled out by hwait
        · rfl                               -- must be critical
      have _hpre_f1 : s.flag1 = true := hpre.mp (Or.inr hcrit)
                                            -- (named with _ : we don't actually use it; recorded for clarity)
      simp [hidle, hwait, hcrit] at hp1_next   -- third-if fires: s'.p1 = idle
      simp [hcrit, hp1_next] at hf1_next       -- the "p1 was critical, p1' is idle" branch sets flag1' = false
      constructor
      · rintro (hw | hc)
        · rw [hp1_next] at hw; exact absurd hw (by decide)
        · rw [hp1_next] at hc; exact absurd hc (by decide)
      · intro ht; rw [hf1_next] at ht; exact absurd ht (by decide)

/- COUPLING LEMMA 2 — symmetric for process 2 / flag2 / turn = 2.       -/
/- Comments are sparser; the structure is identical to lemma 1 above.   -/
theorem p2_flag2_coupling (s s' : MutexState)
    (hpre : p2InLock s ↔ s.flag2 = true)
    (hp2_next :
      (if (s.process2 = .idle) then (s'.process2 = .idle ∨ s'.process2 = .waiting)
       else if ((s.process2 = .waiting) ∧ ((s.flag1 = false) ∨ (s.turn = 2)))
            then s'.process2 = .critical
       else if (s.process2 = .critical) then s'.process2 = .idle
       else s'.process2 = s.process2))
    (hf2_next :
      (if ((s.process2 = .idle) ∧ (s'.process2 = .waiting)) then s'.flag2 = true
       else if ((s.process2 = .critical) ∧ (s'.process2 = .idle)) then s'.flag2 = false
       else s'.flag2 = s.flag2)) :
    p2InLock s' ↔ s'.flag2 = true := by
  by_cases hidle : s.process2 = .idle
  · -- pre = idle (mirror of p1 case)
    have hnotlock : ¬ p2InLock s := by
      rintro (hw | hc)
      · rw [hidle] at hw; exact absurd hw (by decide)
      · rw [hidle] at hc; exact absurd hc (by decide)
    have hpre_f2 : s.flag2 = false :=
      bool_not_true_eq_false (fun ht => hnotlock (hpre.mpr ht))
    simp [hidle] at hp2_next
    rcases hp2_next with h | h
    · -- stay idle
      simp [hidle, h] at hf2_next
      rw [hpre_f2] at hf2_next
      constructor
      · rintro (hw | hc)
        · rw [h] at hw; exact absurd hw (by decide)
        · rw [h] at hc; exact absurd hc (by decide)
      · intro ht; rw [hf2_next] at ht; exact absurd ht (by decide)
    · -- move idle → waiting; flag2 set to true
      simp [hidle, h] at hf2_next
      exact ⟨fun _ => hf2_next, fun _ => Or.inl h⟩
  · by_cases hwait : s.process2 = .waiting
    · -- pre = waiting (mirror)
      have hpre_f2 : s.flag2 = true := hpre.mp (Or.inl hwait)
      simp [hidle, hwait] at hp2_next
      by_cases hcond : (s.flag1 = false) ∨ (s.turn = 2)
      · simp [hcond] at hp2_next                                 -- enters critical
        simp [hwait, hp2_next] at hf2_next
        rw [hpre_f2] at hf2_next
        exact ⟨fun _ => hf2_next, fun _ => Or.inr hp2_next⟩
      · simp [hcond] at hp2_next                                 -- stays waiting
        simp [hwait, hp2_next] at hf2_next
        rw [hpre_f2] at hf2_next
        exact ⟨fun _ => hf2_next, fun _ => Or.inl hp2_next⟩
    · -- pre = critical
      have hcrit : s.process2 = .critical := by
        cases h : s.process2
        · exact absurd h hidle
        · exact absurd h hwait
        · rfl
      have _hpre_f2 : s.flag2 = true := hpre.mp (Or.inr hcrit)
      simp [hidle, hwait, hcrit] at hp2_next
      simp [hcrit, hp2_next] at hf2_next
      constructor
      · rintro (hw | hc)
        · rw [hp2_next] at hw; exact absurd hw (by decide)
        · rw [hp2_next] at hc; exact absurd hc (by decide)
      · intro ht; rw [hf2_next] at ht; exact absurd ht (by decide)

/- ------------------------------------------------------------------- -/
/- INDUCTIVE STEP for the full mutexInv.                               -/

/-- The strengthened invariant is preserved by every transition.
    The two flag-couplings come from the two coupling lemmas above; the
    "no two criticals" piece is the punchline argument. -/
theorem mutexInv_step :
    ∀ s s', mutexInv s → MutexTS.next s s' → mutexInv s' := by
  intro s s' ⟨hp1_iff, hp2_iff, _hnoboth⟩
      ⟨hp1_next, hp2_next, _hturn_next, hf1_next, hf2_next⟩
                                                    -- destructure: 3 IH conjuncts + 5 transition conjuncts
                                                    -- (we don't need _hnoboth or _hturn_next — recorded for completeness)
  refine ⟨?_, ?_, ?_⟩                               -- split goal into the same three conjuncts
  · exact p1_flag1_coupling s s' hp1_iff hp1_next hf1_next   -- coupling lemma 1
  · exact p2_flag2_coupling s s' hp2_iff hp2_next hf2_next   -- coupling lemma 2
  · -- ── MUTUAL EXCLUSION (the punchline) ───────────────────────────
    rintro ⟨hp1c, hp2c⟩                             -- assume s'.p1 = critical AND s'.p2 = critical; derive False
    -- We claim s.p1 must have been `waiting` (the only constructor that can become critical).
    have hpre_p1 : s.process1 = .waiting ∧ ((s.flag2 = false) ∨ (s.turn = 1)) := by
      by_cases hidle : s.process1 = .idle
      · simp [hidle] at hp1_next                    -- from idle, p1' is idle or waiting (never critical)
        rcases hp1_next with h | h
        · rw [h] at hp1c; exact absurd hp1c (by decide)
        · rw [h] at hp1c; exact absurd hp1c (by decide)
      · by_cases hwait : s.process1 = .waiting
        · simp [hidle, hwait] at hp1_next           -- the entry-condition guarded if-then-else fires
          by_cases hcond : (s.flag2 = false) ∨ (s.turn = 1)
          · exact ⟨hwait, hcond⟩                    -- success: pre was waiting, condition held
          · simp [hcond] at hp1_next                -- if condition didn't hold, p1' = waiting (not critical)
            rw [hp1_next] at hp1c; exact absurd hp1c (by decide)
        · -- pre = critical: would force p1' = idle (not critical)
          have hcrit : s.process1 = .critical := by
            cases h : s.process1
            · exact absurd h hidle
            · exact absurd h hwait
            · rfl
          simp [hidle, hwait, hcrit] at hp1_next
          rw [hp1_next] at hp1c; exact absurd hp1c (by decide)
    -- Symmetric extraction for p2.
    have hpre_p2 : s.process2 = .waiting ∧ ((s.flag1 = false) ∨ (s.turn = 2)) := by
      by_cases hidle : s.process2 = .idle
      · simp [hidle] at hp2_next
        rcases hp2_next with h | h
        · rw [h] at hp2c; exact absurd hp2c (by decide)
        · rw [h] at hp2c; exact absurd hp2c (by decide)
      · by_cases hwait : s.process2 = .waiting
        · simp [hidle, hwait] at hp2_next
          by_cases hcond : (s.flag1 = false) ∨ (s.turn = 2)
          · exact ⟨hwait, hcond⟩
          · simp [hcond] at hp2_next
            rw [hp2_next] at hp2c; exact absurd hp2c (by decide)
        · have hcrit : s.process2 = .critical := by
            cases h : s.process2
            · exact absurd h hidle
            · exact absurd h hwait
            · rfl
          simp [hidle, hwait, hcrit] at hp2_next
          rw [hp2_next] at hp2c; exact absurd hp2c (by decide)
    -- Both processes were `waiting`; by the IH coupling, both flags are true.
    have hf1 : s.flag1 = true := hp1_iff.mp (Or.inl hpre_p1.1)
    have hf2 : s.flag2 = true := hp2_iff.mp (Or.inl hpre_p2.1)
    -- Entry conditions reduce to "turn = 1" and "turn = 2" respectively.
    have ht1 : s.turn = 1 := by
      rcases hpre_p1.2 with h | h
      · rw [hf2] at h; exact absurd h (by decide)   -- flag2 = false branch ruled out by hf2
      · exact h                                     -- so it must be turn = 1
    have ht2 : s.turn = 2 := by
      rcases hpre_p2.2 with h | h
      · rw [hf1] at h; exact absurd h (by decide)   -- symmetric
      · exact h
    rw [ht1] at ht2; exact absurd ht2 (by decide)   -- turn can't be both 1 and 2; the punchline contradiction

/-- Bundle init- and step-preservation. -/
theorem mutexInv_inductive : InductiveInvariant MutexTS mutexInv :=
  ⟨mutexInv_init, mutexInv_step⟩

/- ------------------------------------------------------------------- -/
/- ★ MAIN THEOREM: mutual exclusion on every reachable state.          -/

/-- For every reachable state, the two processes are not simultaneously in
    `critical`. This is the safety property the verification course cares
    about — proved here as a derivable consequence of the strengthened
    inductive invariant. -/
theorem MutexTS_mutual_exclusion :
    Invariant MutexTS (fun s => ¬(s.process1 = .critical ∧ s.process2 = .critical)) :=
  invariant_strengthening MutexTS mutexInv _ mutexInv_inductive (fun _ h => h.2.2)
                                                    -- the third conjunct (h.2.2) of mutexInv IS the safety property
