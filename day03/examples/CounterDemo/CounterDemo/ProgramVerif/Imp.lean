/-
  IMP: A Minimal Imperative Language with Hoare Logic
  ===================================================

  WHAT — A small imperative language (the standard "IMP" of textbooks):
         arithmetic & boolean expressions, plus skip / assignment /
         sequencing / if / while. We give it a big-step operational
         semantics and prove the six classic Hoare-logic inference
         rules sound w.r.t. that semantics.

  HOW  — Layered:
           1. SYNTAX  — three inductive types: AExp, BExp, Cmd
           2. SEMANTICS
                • aeval / beval — evaluate expressions in a state
                • BigStep        — inductive "c run from s ends in s'"
           3. HOARE LOGIC
                • Assertion      — predicates on states
                • HoareTriple    — partial-correctness specification
                • six theorems  — skip / assign / seq / if / consequence / while
         Each Hoare rule is proved sound by inverting the BigStep
         derivation (`cases hstep`) and reading off what it says.

  TACTICS USED HERE — quick glossary:
    • intro x         — pull `x` out of a ∀ or → into local context
    • exact e         — close goal with term `e`
    • cases hstep     — split on which BigStep constructor produced hstep
    • cases h with | ctor _ _ … args => …  — same, naming each case
    • ⟨a, b⟩           — anonymous constructor for And/structures
    • generalize hw : t = w at h   — abstract `t` to fresh `w`,
        recording `hw : t = w`. Used in hoare_while to keep the
        induction hypothesis available across the recursive call.
    • induction hstep — induct on the BigStep derivation, one case
        per constructor; `with | ... ih => ...` names each branch and
        its inductive hypothesis.
    • by assumption   — close goal with whatever matching hyp is in scope
    • have h : T := …  — name an intermediate fact
-/

/-! ## 1. Syntax & State -/

/-- Program state: a function from variable names to integer values.
    No mutable state machinery — Lean is functional, so we model
    "after-the-update" as a NEW state, not a side effect. -/
def PState := String → Int

/-- Update a state at one variable: `s[x ↦ v]` returns the state that
    agrees with `s` everywhere except `x` now maps to `v`. -/
def update (s : PState) (x : String) (v : Int) : PState :=
  fun y => if y = x then v else s y

notation:100 s "[" x " ↦ " v "]" => update s x v

/-! ### Arithmetic expressions -/

/-- Tree of arithmetic expressions: numerals, variables, +, −, ×. -/
inductive AExp where
  | num : Int → AExp
  | var : String → AExp
  | add : AExp → AExp → AExp
  | sub : AExp → AExp → AExp
  | mul : AExp → AExp → AExp
  deriving Repr

/-- Evaluate an arithmetic expression in a given state. -/
def aeval : AExp → PState → Int
  | .num n,     _ => n
  | .var x,     s => s x
  | .add e1 e2, s => aeval e1 s + aeval e2 s
  | .sub e1 e2, s => aeval e1 s - aeval e2 s
  | .mul e1 e2, s => aeval e1 s * aeval e2 s

/-! ### Boolean expressions -/

/-- Tree of boolean expressions: literals, equality, ≤, <, ¬, ∧. -/
inductive BExp where
  | tt : BExp
  | ff : BExp
  | eq : AExp → AExp → BExp
  | le : AExp → AExp → BExp
  | lt : AExp → AExp → BExp
  | not : BExp → BExp
  | and : BExp → BExp → BExp
  deriving Repr

/-- Evaluate a boolean expression in a given state. -/
def beval : BExp → PState → Bool
  | .tt,        _ => true
  | .ff,        _ => false
  | .eq e1 e2,  s => aeval e1 s == aeval e2 s
  | .le e1 e2,  s => aeval e1 s ≤ aeval e2 s
  | .lt e1 e2,  s => aeval e1 s < aeval e2 s
  | .not b,     s => ! beval b s
  | .and b1 b2, s => beval b1 s && beval b2 s

/-! ### Commands -/

/-- The five standard imperative constructs. -/
inductive Cmd where
  | skip : Cmd
  | assign : String → AExp → Cmd
  | seq : Cmd → Cmd → Cmd
  | ifte : BExp → Cmd → Cmd → Cmd
  | while : BExp → Cmd → Cmd
  deriving Repr

-- Pleasant infix notation matching textbook style.
infixr:30 " ;; " => Cmd.seq        -- c1 ;; c2  for sequencing
infix:40 " ::= " => Cmd.assign     -- "x" ::= e  for assignment

/-! ## 2. Big-Step Operational Semantics

  `BigStep c s s'` means "running `c` in state `s` terminates in `s'`".
  Each constructor is one rule of the operational semantics.
-/
inductive BigStep : Cmd → PState → PState → Prop where
  | skip (s : PState) : BigStep .skip s s
  | assign (s : PState) (x : String) (e : AExp) :
      BigStep (.assign x e) s (s[x ↦ aeval e s])
  | seq (s s' s'' : PState) (c1 c2 : Cmd) :
      BigStep c1 s s' → BigStep c2 s' s'' →
      BigStep (.seq c1 c2) s s''
  | ifte_true (s s' : PState) (b : BExp) (c1 c2 : Cmd) :
      beval b s = true → BigStep c1 s s' →
      BigStep (.ifte b c1 c2) s s'
  | ifte_false (s s' : PState) (b : BExp) (c1 c2 : Cmd) :
      beval b s = false → BigStep c2 s s' →
      BigStep (.ifte b c1 c2) s s'
  | while_false (s : PState) (b : BExp) (c : Cmd) :
      beval b s = false →
      BigStep (.while b c) s s
  | while_true (s s' s'' : PState) (b : BExp) (c : Cmd) :
      beval b s = true →
      BigStep c s s' →
      BigStep (.while b c) s' s'' →
      BigStep (.while b c) s s''

/-! ## 3. Hoare Logic -/

/-- An *assertion* is a predicate on program states. -/
def Assertion := PState → Prop

/-- The partial-correctness Hoare triple `{P} c {Q}`:
    if `P` holds before, and running `c` from there terminates in `s'`,
    then `Q` holds at `s'`. ("Partial" because we say nothing about
    non-terminating runs.) -/
def HoareTriple (P : Assertion) (c : Cmd) (Q : Assertion) : Prop :=
  ∀ s s', P s → BigStep c s s' → Q s'

notation:50 "⦃" P "⦄ " c " ⦃" Q "⦄" => HoareTriple P c Q

/-! ### The six classic Hoare rules — each proved sound. -/

/-- ★ SKIP rule: `{P} skip {P}`.
    STRATEGY: invert the BigStep derivation; the only way to step
    via `skip` is the `skip` constructor, which means s' = s. -/
theorem hoare_skip (P : Assertion) : ⦃P⦄ Cmd.skip ⦃P⦄ := by
  intro s s' hp hstep    -- assume pre-state s, post-state s', hp : P s, hstep : skip steps s ↦ s'
  cases hstep            -- only one BigStep constructor matches `skip`: forces s' = s
  exact hp               -- P s' is now P s, which we have as hp

/-- ★ ASSIGNMENT rule: `{Q[e/x]} x := e {Q}`.
    Read backwards: to ensure Q after `x := e`, require Q with `x`
    replaced by the value of `e` BEFORE the assignment.
    STRATEGY: invert the assign step; the post-state is exactly the
    update mentioned in the precondition, so hp transports directly. -/
theorem hoare_assign (Q : Assertion) (x : String) (e : AExp) :
    ⦃fun s => Q (s[x ↦ aeval e s])⦄ Cmd.assign x e ⦃Q⦄ := by
  intro s s' hp hstep    -- introduce pre/post and the hypothesis hp : Q (s[x ↦ aeval e s])
  cases hstep            -- only the `assign` constructor matches; this fixes s' = s[x ↦ aeval e s]
  exact hp               -- now Q s' = Q (s[x ↦ aeval e s]) = hp

/-- ★ SEQUENCING rule: chain two triples through a midpoint Q. -/
theorem hoare_seq (P Q R : Assertion) (c1 c2 : Cmd)
    (h1 : ⦃P⦄ c1 ⦃Q⦄) (h2 : ⦃Q⦄ c2 ⦃R⦄) :
    ⦃P⦄ (c1 ;; c2) ⦃R⦄ := by
  intro s s' hp hstep                                -- assume pre/post, hp : P s, hstep : (c1;;c2) goes s ↦ s'
  cases hstep with                                   -- only the `seq` constructor produces a sequencing step
  | seq _ smid _ _ _ hs1 hs2 =>
    exact h2 smid s' (h1 s smid hp hs1) hs2          -- chain: get Q at the midpoint smid, then R at s' via h2

/-- ★ IF rule: prove the postcondition along both branches. -/
theorem hoare_if (P Q : Assertion) (b : BExp) (c1 c2 : Cmd)
    (h1 : ⦃fun s => P s ∧ beval b s = true⦄ c1 ⦃Q⦄)
    (h2 : ⦃fun s => P s ∧ beval b s = false⦄ c2 ⦃Q⦄) :
    ⦃P⦄ (Cmd.ifte b c1 c2) ⦃Q⦄ := by
  intro s s' hp hstep                                                          -- standard intros
  cases hstep with                                                             -- two BigStep cases for `ifte`: true / false branch
  | ifte_true  _ _ _ _ _ hb hs1 => exact h1 s s' ⟨hp, hb⟩ hs1                 -- guard true → use h1, packaging hp+hb together
  | ifte_false _ _ _ _ _ hb hs2 => exact h2 s s' ⟨hp, hb⟩ hs2                 -- guard false → use h2 symmetrically

/-- ★ CONSEQUENCE rule: strengthen the precondition and/or weaken the
    postcondition. The "interface adapter" of Hoare logic: it lets
    us re-phrase a triple with logically stronger/weaker assertions. -/
theorem hoare_consequence (P P' Q Q' : Assertion) (c : Cmd)
    (himp_pre : ∀ s, P s → P' s)
    (htriple : ⦃P'⦄ c ⦃Q'⦄)
    (himp_post : ∀ s, Q' s → Q s) :
    ⦃P⦄ c ⦃Q⦄ := by
  intro s s' hp hstep                                                            -- assume pre/post and the running pieces
  exact himp_post s' (htriple s s' (himp_pre s hp) hstep)                        -- adapt: P→P', run, then Q'→Q

/-- ★ WHILE rule (partial correctness, with loop invariant I):
        {I ∧ b} c {I}
        ───────────────────────────────────────────────
        {I} while b do c {I ∧ ¬b}
    STRATEGY: induct on the BigStep derivation of the while loop.
    The trick is the `generalize hw : Cmd.while b c = w at hstep`:
    we abstract the while-shape to a fresh variable `w`, so the
    inductive hypothesis is general enough to cover the recursive
    call inside `while_true`. After induction we re-establish
    `w = while b c` via `cases hw` in each branch and dismiss the
    impossible cases (skip/assign/etc.) with `cases hw`. -/
theorem hoare_while (I : Assertion) (b : BExp) (c : Cmd)
    (hbody : ⦃fun s => I s ∧ beval b s = true⦄ c ⦃I⦄) :
    ⦃I⦄ (Cmd.while b c) ⦃fun s => I s ∧ beval b s = false⦄ := by
  intro s s' hI hstep                                                          -- assume the pre-state s, post s', hI : I s, hstep : while goes s ↦ s'
  -- Generalize the loop expression so the IH applies to the recursive call.
  generalize hw : Cmd.while b c = w at hstep                                   -- replace `Cmd.while b c` by fresh `w` in hstep, recording hw
  induction hstep with                                                         -- induct on the BigStep derivation now indexed by `w`
  | while_false s' b' c' hbf =>                                                -- base: loop guard already false, no body executed
    cases hw                                                                   -- recover w = while b c, identifying b'=b, c'=c
    exact ⟨hI, hbf⟩                                                            -- result: I s ∧ ¬b
  | while_true s₁ smid s₂ b' c' hbt _ _ ih1 ih2 =>                             -- step: guard true, body run, recursive while
    cases hw                                                                   -- again, recover the loop shape
    -- Establish I at the midpoint via the body triple.
    have hImid : I smid := hbody s₁ smid ⟨hI, hbt⟩ (by assumption)             -- body: from (I ∧ b) we got I after one iteration
    exact ih2 hImid rfl                                                        -- continue inductively from smid; rfl confirms the loop shape unchanged
  -- The remaining BigStep constructors can't possibly produce a `while` shape;
  -- `cases hw` shows the assumed equation `(while b c) = (skip / assign / …)`
  -- has no constructor proof, closing each branch by impossibility.
  | skip       => cases hw
  | assign     => cases hw
  | seq        => cases hw
  | ifte_true  => cases hw
  | ifte_false => cases hw
