/-
  Transition Systems and Inductive Invariants
  ============================================

  WHAT — A general framework for modeling transition systems and proving
         properties about reachable states via inductive invariants. This
         is the same machinery used in NuXMV / model checking, written
         out in Lean 4 so we can prove things about *all* reachable
         states symbolically (not just by enumeration).

  HOW  — We define three pieces and prove three theorems:
           DEFINITIONS
             • TransitionSystem      — init predicate + step relation
             • Reachable (inductive) — closure of init under step
             • InductiveInvariant    — predicate preserved by init + step
             • Invariant             — predicate holding on all reachable
           THEOREMS
             1. inductive_invariant_holds  — inductive invariants are invariants
             2. invariant_strengthening    — strengthen-then-weaken pattern
             3. invariant_conjunction      — invariants are closed under ∧

  TACTICS USED HERE — quick glossary for non-Lean readers:
    • intro x       — pull "x" out of a ∀ or → into the local context
    • induction h   — do case analysis along an inductive definition;
                      `with | ctor … => …` names each case
    • exact e       — close the goal with term `e` (which must already
                      have the right type)
    • constructor   — to prove an `∧` (or other 1-constructor structure),
                      split into one sub-goal per field
    • ⟨_, _⟩         — anonymous constructor for And/Exists/structures
    • h.1 / h.2     — first / second component of an And

  Reading tip: Lean 4 displays the current goal in the InfoView while
  you write a proof; each tactic transforms that goal step-by-step
  until "no goals" is shown. The end-of-line comments below describe
  what each step does to the goal.
-/

/-- A transition system over a state space `State` is given by an
    initial-state predicate and a binary step relation. -/
structure TransitionSystem (State : Type) where
  init : State → Prop          -- "is this state a valid starting state?"
  next : State → State → Prop  -- "can s step to s'?"

/-- The reachable-states relation, defined inductively:
      • every initial state is reachable;
      • if `s` is reachable and `s` steps to `s'`, then `s'` is reachable.
    "Reachable ts s" means there is a finite execution of `ts` ending in s. -/
inductive Reachable {State : Type} (ts : TransitionSystem State) : State → Prop where
  | init (s : State) : ts.init s → Reachable ts s
  | step (s s' : State) : Reachable ts s → ts.next s s' → Reachable ts s'

/-- A predicate `P` is an *inductive invariant* of `ts` when:
      (1) every initial state satisfies `P`, AND
      (2) every transition preserves `P` (P pre-state ⇒ P post-state).
    Inductive invariants are the workhorse of safety verification:
    if you can find one that implies your safety property, you're done. -/
def InductiveInvariant {State : Type} (ts : TransitionSystem State) (P : State → Prop) : Prop :=
  (∀ s, ts.init s → P s) ∧
  (∀ s s', P s → ts.next s s' → P s')

/-- A predicate `P` is an *invariant* of `ts` when it holds on every
    reachable state. (Strictly weaker than InductiveInvariant: an
    invariant need not be preserved by transitions starting in
    *unreachable* states.) -/
def Invariant {State : Type} (ts : TransitionSystem State) (P : State → Prop) : Prop :=
  ∀ s, Reachable ts s → P s

/-- ★ THEOREM 1 — Soundness of the inductive-invariant method.
    If `P` is an inductive invariant of `ts`, then `P` is an invariant
    (it holds on every reachable state).
    STRATEGY: induct on the proof that the state is reachable.
      • base case (init): P holds because P holds on all initial states.
      • step case: by IH P held before; preservation gives it after. -/
theorem inductive_invariant_holds {State : Type}
    (ts : TransitionSystem State) (P : State → Prop)
    (h : InductiveInvariant ts P) : Invariant ts P := by
  intro s hr                                -- name the state s and the reachability proof hr
  induction hr with                         -- analyse hr by which constructor of `Reachable` produced it
  | init s hi => exact h.1 s hi             -- base: hi : init s; h.1 says init ⇒ P, applied to s and hi
  | step s s' _ hstep ih => exact h.2 s s' ih hstep
                                            -- step: ih : P s (the IH); hstep : next s s';
                                            -- h.2 says (P s ∧ next s s') ⇒ P s'

/-- ★ THEOREM 2 — Invariant strengthening.
    If `P` is an inductive invariant and `P` implies `Q` pointwise,
    then `Q` is an invariant. Practical use: prove a strong `P`
    (which is inductive), then read off the weaker `Q` you actually want.
    STRATEGY: chain the previous theorem with the implication. -/
theorem invariant_strengthening {State : Type}
    (ts : TransitionSystem State) (P Q : State → Prop)
    (hind : InductiveInvariant ts P)
    (himp : ∀ s, P s → Q s) : Invariant ts Q := by
  intro s hr                                -- introduce the state s and reachability hr
  exact himp s (inductive_invariant_holds ts P hind s hr)
                                            -- get P s via theorem 1, then apply himp to get Q s

/-- ★ THEOREM 3 — Invariants are closed under conjunction.
    If `P` and `Q` are both inductive invariants, so is `P ∧ Q`.
    STRATEGY: split the conjunctive goal into init- and step-parts,
    then pair component-wise from the two given inductive invariants. -/
theorem invariant_conjunction {State : Type}
    (ts : TransitionSystem State) (P Q : State → Prop)
    (hp : InductiveInvariant ts P)
    (hq : InductiveInvariant ts Q) : InductiveInvariant ts (fun s => P s ∧ Q s) := by
  constructor                               -- split the And goal into two sub-goals
  · intro s hi                              -- sub-goal 1 (init-preservation): assume init s
    exact ⟨hp.1 s hi, hq.1 s hi⟩            -- pair P-on-init and Q-on-init
  · intro s s' ⟨hps, hqs⟩ hn                -- sub-goal 2 (step-preservation): destructure pre-state assumption (P s ∧ Q s)
    exact ⟨hp.2 s s' hps hn, hq.2 s s' hqs hn⟩
                                            -- pair the two step-preservations

/- ------------------------------------------------------------------- -/
/- K-step reachability and k-induction.                                -/
/-                                                                     -/
/- Standard inductive invariants prove properties of ALL reachable     -/
/- states. For convergence results (e.g., "after k rounds, property P  -/
/- holds"), we need to reason about states reachable in exactly k      -/
/- steps. The definitions and theorems below support this.             -/

/-- A state `s` is reachable in exactly `k` steps from an initial state.
    `ReachableInK ts 0 s` means s is an initial state;
    `ReachableInK ts (k+1) s'` means some state reachable in k steps
    can step to s'. -/
inductive ReachableInK {State : Type} (ts : TransitionSystem State) : Nat → State → Prop where
  | init (s : State) : ts.init s → ReachableInK ts 0 s
  | step (k : Nat) (s s' : State) : ReachableInK ts k s → ts.next s s' → ReachableInK ts (k+1) s'

/-- ★ THEOREM 4 — k-step reachable states are reachable.
    Forgets the step count, connecting to the unindexed `Reachable`. -/
theorem reachableInK_reachable {State : Type} (ts : TransitionSystem State) :
    ∀ k s, ReachableInK ts k s → Reachable ts s := by
  intro k s hrk
  induction hrk with
  | init s hi => exact Reachable.init s hi
  | step _ s s' _ hn ih => exact Reachable.step s s' ih hn

/-- Every reachable state is reachable in some number of steps. -/
theorem reachable_iff_reachableInK {State : Type} (ts : TransitionSystem State)
    (s : State) : Reachable ts s ↔ ∃ k, ReachableInK ts k s := by
  constructor
  · intro hr
    induction hr with
    | init s hi => exact ⟨0, .init s hi⟩
    | step s s' _ hn ih =>
      obtain ⟨k, hk⟩ := ih
      exact ⟨k + 1, .step k s s' hk hn⟩
  · intro ⟨k, hk⟩
    exact reachableInK_reachable ts k s hk

/-- ★ THEOREM 5 — Step-indexed invariant.
    If a property `P` (indexed by step count) holds for all k-step
    reachable states, then the unindexed property `∀ k, P k` holds
    on every reachable state.
    Practical use: prove "after k rounds, cells at distance ≤ k have
    correct dist values" by induction on k, then conclude the property
    for all reachable states. -/
theorem step_indexed_invariant {State : Type}
    (ts : TransitionSystem State) (P : Nat → State → Prop)
    (h : ∀ k s, ReachableInK ts k s → P k s) :
    ∀ s, Reachable ts s → ∃ k, P k s := by
  intro s hr
  rw [reachable_iff_reachableInK] at hr
  obtain ⟨k, hk⟩ := hr
  exact ⟨k, h k s hk⟩

/-- ★ THEOREM 6 — K-induction principle.
    A step-indexed property `P` is a step-indexed invariant if:
      (1) it holds on all initial states (at step 0), AND
      (2) if `P k` holds on a k-step reachable state and the state
          steps to s', then `P (k+1)` holds on s'.
    This is the step-indexed analogue of `inductive_invariant_holds`. -/
theorem k_induction {State : Type}
    (ts : TransitionSystem State) (P : Nat → State → Prop)
    (hinit : ∀ s, ts.init s → P 0 s)
    (hstep : ∀ k s s', ReachableInK ts k s → P k s → ts.next s s' → P (k + 1) s') :
    ∀ k s, ReachableInK ts k s → P k s := by
  intro k s hrk
  induction hrk with
  | init s hi => exact hinit s hi
  | step k s s' hrk hn ih => exact hstep k s s' hrk ih hn

/-- If a 1-step inductive invariant Q holds AND a step-indexed property
    P holds for all k-step reachable states satisfying Q, then P holds
    for all k-step reachable states. Combines ordinary invariants with
    step-indexed reasoning. -/
theorem k_induction_with_invariant {State : Type}
    (ts : TransitionSystem State) (Q : State → Prop) (P : Nat → State → Prop)
    (hQ : InductiveInvariant ts Q)
    (hinit : ∀ s, ts.init s → P 0 s)
    (hstep : ∀ k s s', ReachableInK ts k s → Q s → P k s → ts.next s s' → P (k + 1) s') :
    ∀ k s, ReachableInK ts k s → P k s := by
  intro k s hrk
  induction hrk with
  | init s hi => exact hinit s hi
  | step k s s' hrk hn ih =>
    have hqs : Q s := inductive_invariant_holds ts Q hQ s (reachableInK_reachable ts k s hrk)
    exact hstep k s s' hrk hqs ih hn

/- ------------------------------------------------------------------- -/
/- Ranking functions and liveness.                                     -/
/-                                                                     -/
/- Safety properties (invariants) say "nothing bad ever happens."      -/
/- Liveness properties say "something good eventually happens." The    -/
/- standard tool for liveness is a ranking function (variant): a       -/
/- natural-number-valued measure that strictly decreases along          -/
/- transitions, guaranteeing termination / eventual progress.          -/

/-- An infinite execution (trajectory) of a transition system: a
    function from step indices to states, where each consecutive pair
    is related by the transition relation. -/
structure Execution {State : Type} (ts : TransitionSystem State) where
  states : Nat → State
  init_ok : ts.init (states 0)
  step_ok : ∀ k : Nat, ts.next (states k) (states (k + 1))

/-- A ranking function (variant) for liveness. `V : State → Nat` is a
    ranking function under guard `G` if every transition from a state
    satisfying `G` with `V > 0` strictly decreases `V`. -/
def IsRankingFunction {State : Type} (ts : TransitionSystem State)
    (V : State → Nat) (G : State → Prop) : Prop :=
  ∀ s s', G s → V s > 0 → ts.next s s' → V s' < V s

/-- ★ THEOREM 7 — Bounded progress from ranking.
    If `V` is a ranking function under guard `G`, and `G` is an
    invariant, then every execution reaches `V = 0` within `V(s₀)` steps.
    This is the discrete analogue of Lyapunov's theorem. -/
theorem ranking_bounded_progress {State : Type}
    (ts : TransitionSystem State) (V : State → Nat) (G : State → Prop)
    (hrank : IsRankingFunction ts V G)
    (hG : InductiveInvariant ts G)
    (exec : Execution ts) :
    ∃ k : Nat, k ≤ V (exec.states 0) ∧ V (exec.states k) = 0 := by
  have exec_reachable : ∀ k, Reachable ts (exec.states k) := by
    intro k; induction k with
    | zero => exact Reachable.init _ exec.init_ok
    | succ k ih => exact Reachable.step _ _ ih (exec.step_ok k)
  -- Core: from any index j, if V(states j) ≤ fuel, then V reaches 0
  -- within fuel more steps. Induction on fuel avoids strong recursion.
  suffices core : ∀ fuel j : Nat, V (exec.states j) ≤ fuel →
      ∃ k : Nat, k ≤ fuel ∧ V (exec.states (j + k)) = 0 by
    obtain ⟨k, hk, hv⟩ := core _ 0 (Nat.le_refl _)
    exact ⟨k, hk, by simpa using hv⟩
  intro fuel
  induction fuel with
  | zero =>
    intro j hle
    have : V (exec.states j) = 0 := by omega
    exact ⟨0, Nat.le_refl _, by simp_all⟩
  | succ fuel ih =>
    intro j hle
    by_cases hv : V (exec.states j) = 0
    · exact ⟨0, by omega, by simp_all⟩
    · have hGj := inductive_invariant_holds ts G hG _ (exec_reachable j)
      have hdec := hrank _ _ hGj (by omega) (exec.step_ok j)
      have hle' : V (exec.states (j + 1)) ≤ fuel := by omega
      obtain ⟨k', hk', hv'⟩ := ih (j + 1) hle'
      refine ⟨k' + 1, by omega, ?_⟩
      simp only [Nat.add_assoc, Nat.add_comm 1 k'] at hv' ⊢
      exact hv'

/-- A predicate holds *eventually* along an execution: there exists
    some step k at which it holds. -/
def Eventually {State : Type} {ts : TransitionSystem State}
    (exec : Execution ts) (P : State → Prop) : Prop :=
  ∃ k : Nat, P (exec.states k)

/-- ★ THEOREM 8 — Ranking implies eventual progress.
    If `V` is a ranking function under invariant guard `G`, then
    every execution eventually reaches a state where `V = 0`. -/
theorem ranking_implies_eventually {State : Type}
    (ts : TransitionSystem State) (V : State → Nat) (G : State → Prop)
    (hrank : IsRankingFunction ts V G)
    (hG : InductiveInvariant ts G)
    (exec : Execution ts) :
    Eventually exec (fun s => V s = 0) := by
  obtain ⟨k, _, hv⟩ := ranking_bounded_progress ts V G hrank hG exec
  exact ⟨k, hv⟩

/-- A fairness condition on an execution: a predicate `enabled` that,
    whenever it holds at some step, is eventually *discharged* (the
    corresponding `fired` predicate holds at some later step).
    Models Assumption 4 of the paper (token round-robin fairness). -/
def FairFor {State : Type} {ts : TransitionSystem State}
    (exec : Execution ts) (enabled fired : State → Prop) : Prop :=
  ∀ k : Nat, enabled (exec.states k) → ∃ k' : Nat, k' ≥ k ∧ fired (exec.states k')
