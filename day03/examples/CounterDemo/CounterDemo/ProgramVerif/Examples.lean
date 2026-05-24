/-
  Verified Program Examples
  =========================

  WHAT — Two short verified programs in our IMP language:
           1. swap        — three assignments, no loop. Trivial Hoare proof.
           2. countProg   — `i := 0; while i < n: i := i + 1`. Uses
                            the while rule with a loop invariant.

  HOW  — Each example follows the same recipe:
           • DEFINE the program as a Lean `Cmd` value.
           • STATE the Hoare triple {pre} prog {post}.
           • PROVE it by `cases` on the `BigStep` derivation,
             reading off what each constructor gives us.
         The loop example also factors out
           • a loop INVARIANT predicate (`countInv`)
           • a body PRESERVATION lemma
         so the main proof just glues these together via `hoare_while`.

  TACTICS USED HERE — quick glossary:
    • intro …             — pull universally-quantified vars and hypotheses into scope
    • cases hstep         — invert hstep by which BigStep constructor produced it
    • cases hstep with | ctor _ _ … => …  — name the constructor and bound vars
    • simp [defs] at h    — unfold definitions / simplify with `simp` rules at h
    • simp [defs] at *    — apply simp everywhere in the context
    • refine ⟨?_, ?_, ?_⟩  — split a 3-tuple goal into three sub-goals
    • omega               — closes goals about linear integer arithmetic
    • rw [h]              — rewrite using equation h (left → right)
    • obtain ⟨…⟩ := h     — destructure h (And/Exists/etc.) inline
    • have h := …         — name an intermediate fact
-/
import CounterDemo.ProgramVerif.Imp

/-! ## Example 1 — Variable Swap

  Python:    t = x; x = y; y = t
  Lean Cmd:  "t" ::= var "x" ;; "x" ::= var "y" ;; "y" ::= var "t"
  We prove:  {x = a ∧ y = b} swap {x = b ∧ y = a}.
-/

/-- Three-assignment swap of `x` and `y` via temp variable `t`. -/
def swap : Cmd :=
  "t" ::= AExp.var "x" ;;
  "x" ::= AExp.var "y" ;;
  "y" ::= AExp.var "t"

/-- ★ swap really swaps: starting with `x = a ∧ y = b` we end with `x = b ∧ y = a`.
    STRATEGY: there are no loops, so the proof just unwinds the
    `seq`/`assign` BigStep constructors three times and then computes. -/
theorem swap_correct (a b : Int) :
    ⦃fun s => s "x" = a ∧ s "y" = b⦄ swap ⦃fun s => s "x" = b ∧ s "y" = a⦄ := by
  intro s s' ⟨hx, hy⟩ hstep                                     -- pre/post + (x=a, y=b) destructured + the run
  -- The program is `seq (assign t x) (seq (assign x y) (assign y t))`.
  -- Each `cases` peels one layer off the BigStep derivation.
  cases hstep with                                              -- top-level: must be `seq`
  | seq _ _ _ _ _ h1 hrest =>
    cases h1                                                    -- the first sub-step is `assign`; substitutes the new state
    cases hrest with                                            -- second layer: another `seq`
    | seq _ _ _ _ _ h2 h3 =>
      cases h2                                                  -- second `assign`
      cases h3                                                  -- third `assign`
      simp [aeval, update, hx, hy]                              -- compute final state values, plug in hx, hy; goal closes

/-! ## Example 2 — Counting Loop

  Python:
    i = 0
    while i < n:
        i = i + 1
    -- post: i == n   (assuming n ≥ 0 to begin with)

  We use a loop-invariant proof. The invariant is
    countInv n st ≡  0 ≤ st"i"  ∧  st"i" ≤ n  ∧  st"n" = n
  i.e. "i is between 0 and n, and n hasn't changed".
-/

/-- The counting program written as an IMP `Cmd`. -/
def countProg : Cmd :=
  "i" ::= AExp.num 0 ;;
  Cmd.while (BExp.lt (AExp.var "i") (AExp.var "n"))
    ("i" ::= AExp.add (AExp.var "i") (AExp.num 1))

/-- Loop invariant for `countProg`, parameterised by the target value `n`. -/
def countInv (n : Int) : Assertion :=
  fun st => 0 ≤ st "i" ∧ st "i" ≤ n ∧ st "n" = n

/-- ★ Body preservation: the loop body `i := i+1` preserves `countInv`,
    given that the loop guard `i < n` was true on entry.
    STRATEGY: invert the assignment, simplify, then split the
    three-way conjunction and discharge each piece arithmetically. -/
theorem count_body_preserves (n : Int) :
    ⦃fun st => countInv n st ∧ beval (BExp.lt (AExp.var "i") (AExp.var "n")) st = true⦄
      ("i" ::= AExp.add (AExp.var "i") (AExp.num 1))
    ⦃countInv n⦄ := by
  intro st st' ⟨⟨hge, hle, hn⟩, hb⟩ hstep                       -- destructure: (0 ≤ i, i ≤ n, n=n) ∧ (i < n) ∧ the step
  cases hstep                                                   -- only `assign` matches; substitutes st' = st["i" ↦ i+1]
  simp [aeval, beval, update, countInv] at *                    -- unfold the eval/update/invariant in every hypothesis & goal
  refine ⟨?_, ?_, ?_⟩                                           -- split goal "0 ≤ i+1 ∧ i+1 ≤ n ∧ n = n" into 3 sub-goals
  · omega                                                       -- 0 ≤ i+1 from 0 ≤ i
  · rw [hn] at hb                                               -- rewrite n inside hb : i < st"n"  to  hb : i < n
    omega                                                       -- i < n ⇒ i+1 ≤ n
  · exact hn                                                    -- n = n was already a hypothesis

/-- ★ Full correctness: starting with `st"n" = n` and `0 ≤ n`, the program
    `countProg` terminates in a state with `i = n`.
    STRATEGY: peel off the initial `i := 0` assignment, establish that
    the invariant holds at the loop entry, apply `hoare_while`, and
    extract `i = n` from the post-condition (invariant ∧ ¬guard). -/
theorem countProg_correct (n : Int) (hn : 0 ≤ n) :
    ⦃fun st => st "n" = n⦄ countProg ⦃fun st => st "i" = n⦄ := by
  intro st st' hpre hstep                                                     -- standard intros
  cases hstep with                                                            -- top-level `seq` of init+loop
  | seq _ _ _ _ _ h_init h_loop =>
    cases h_init                                                              -- first half: `i := 0`; substitutes the new state
    -- After `i := 0`, the invariant holds.
    have hinit : countInv n (st["i" ↦ aeval (AExp.num 0) st]) := by
      simp [countInv, update, aeval]                                          -- unfold; goal becomes 0 ≤ 0 ∧ 0 ≤ n ∧ st"n" = n
      exact ⟨hn, hpre⟩                                                        -- close with our two assumptions
    -- Apply the while-rule with `countInv n` as the loop invariant.
    have hloop := hoare_while (countInv n)
      (BExp.lt (AExp.var "i") (AExp.var "n")) _ (count_body_preserves n)
    have hres := hloop _ st' hinit h_loop                                     -- run the loop: get (countInv ∧ guard-false) at st'
    -- Post-condition of `hoare_while`: invariant AND ¬guard.
    obtain ⟨⟨_, hle, hnn⟩, hbf⟩ := hres                                       -- destructure into i ≤ n, n=n, and ¬(i < n)
    simp [beval, aeval] at hbf                                                -- unfold ¬guard to plain Int comparison
    rw [hnn] at hbf                                                           -- replace st"n" by n in hbf
    omega                                                                     -- i ≤ n ∧ ¬(i < n) ⇒ i = n
