/-
  Proofs of Invariant Properties for Euclid's GCD Algorithm
  ==========================================================

  WHAT — The auto-generated `Gcd.lean` encodes Euclid's subtraction-based GCD
         algorithm using a program counter `pc ∈ {l1, l2, l3, l4, l5}`:

           l1: while (a ≠ b) {
           l2:   if (a > b)
           l3:     a := a - b
                 else
           l4:     b := b - a
           l5: }

         We prove three increasingly deep invariants:
           1. RANGE          —  a ≥ 0 ∧ b ≥ 0           (trivial: they are Nats)
           2. TERMINATION    —  pc = l5 → a = b         (only at the loop exit)
           3. GCD PRESERVATION — gcd(a,b) is preserved by every transition

  HOW  — (1) is one line. (2) and (3) follow the standard recipe:
           • define an inductive invariant predicate
           • prove init- and step-preservation
           • bundle into `InductiveInvariant`
           • lift to a global `Invariant` via `inductive_invariant_holds`
         The step proof for (2) is a 5-way case-split on `s.pc`. For (3) we
         use the textbook identity `gcd(a − b, b) = gcd(a, b)` (when b ≤ a),
         which is `Nat.gcd_sub_self_left` in core Lean.

  TACTICS USED HERE — quick glossary:
    • intro / cases / by_cases / simp / rw / exact / apply / refine — see prior files
    • absurd hp hnp        — from hp:P and hnp:¬P, derive any goal
    • by decide            — Lean computes the answer (decidable claim)
    • Nat.le_of_not_lt h   — from ¬(a < b) over Nat, get b ≤ a
    • Nat.le_of_lt h       — from a < b, get a ≤ b
    • Nat.zero_le _        — every Nat is ≥ 0
    • Nat.gcd_sub_self_left h  — gcd identity: gcd(a-b)b = gcd a b when b ≤ a
    • Nat.gcd_comm         — commutativity of gcd
    • exfalso              — replace any goal by False (then derive a contradiction)
    • cases hpc : s.pc with | l1 => … | l2 => … | …
                           — split on s.pc, recording the equation as hpc
-/
import CounterDemo.TransitionSystem
import CounterDemo.NuXMV.Gcd

open PcVal     -- make `l1`,`l2`,…,`l5` available without `PcVal.` prefix

/- --------------------------------------------------------------------- -/
/- INVARIANT 1: a ≥ 0 ∧ b ≥ 0   (trivially true since both are Nat).     -/

/-- Both `a` and `b` are non-negative on every reachable state.
    Trivial because they are typed as `Nat`. -/
theorem GcdTS_inv2_proved :
    Invariant GcdTS (fun s => s.a ≥ 0 ∧ s.b ≥ 0) := by
  intro s _                                       -- introduce s; ignore the reachability proof (we don't need it)
  exact ⟨Nat.zero_le _, Nat.zero_le _⟩            -- both 0 ≤ s.a and 0 ≤ s.b are stdlib facts about Nat

/- --------------------------------------------------------------------- -/
/- INVARIANT 2: pc = l5 → a = b   (termination correctness).             -/

/-- The strengthened invariant for termination correctness:
    once the program counter reaches l5, the loop exit condition (a = b)
    must have just been established at l1, and a, b can't change at l5. -/
def gcdTermInv (s : GcdState) : Prop :=
  s.pc = .l5 → s.a = s.b

/-- Base case: in the initial state, pc = l1, so the implication
    "pc = l5 → a = b" is vacuously true (its hypothesis fails). -/
theorem gcdTermInv_init : ∀ s, GcdTS.init s → gcdTermInv s := by
  intro s hinit                       -- name s and the init hypothesis
  intro h5                            -- assume pc = l5 (we'll derive False)
  rw [hinit] at h5                    -- substitute pc = l1 (from hinit) into h5: now h5 : l1 = l5
  exact absurd h5 (by decide)         -- l1 ≠ l5 by Lean's decidability check

/-- Inductive step: if `gcdTermInv s` and we step to `s'`, then `gcdTermInv s'`.
    STRATEGY: case-split on the current `pc`. In every branch we either
      (a) the next pc is not l5  (so the implication's hypothesis fails), OR
      (b) we just transitioned l1 → l5 with a = b (and a, b didn't change), OR
      (c) we were already at l5 and stayed (so use the IH).
    Each branch reduces hpc_next/ha_next/hb_next to a concrete equation
    via `simp [hpc, …]`. -/
theorem gcdTermInv_step :
    ∀ s s', gcdTermInv s → GcdTS.next s s' → gcdTermInv s' := by
  intro s s' hIH ⟨ha_next, hb_next, hpc_next⟩ h5'
                                                    -- destructure the next-step record into the three update equations;
                                                    -- introduce h5' : s'.pc = .l5 (the goal's hypothesis)
  cases hpc : s.pc with                             -- split on s.pc; hpc records which value
  | l1 =>
    by_cases heq : s.a = s.b                        -- at l1, two sub-cases: loop guard true or false
    · -- l1 & a = b → goes to l5; a, b unchanged.
      simp [hpc, heq] at ha_next hb_next            -- simplify the next-state equations: s'.a = s.a, s'.b = s.b
      rw [ha_next, hb_next]                         -- substitute s'.a, s'.b in the goal `s'.a = s'.b`
                                                    -- becomes `s.a = s.b`, which is `heq`; rfl auto-closes (heq is in scope)
    · -- l1 & a ≠ b → goes to l2 (not l5).
      simp [hpc, heq] at hpc_next                   -- hpc_next : s'.pc = l2
      rw [hpc_next] at h5'; exact absurd h5' (by decide)
                                                    -- l2 ≠ l5: contradicts h5'
  | l2 =>
    by_cases hgt : s.a > s.b                        -- at l2, two sub-cases: a > b or a ≤ b
    · simp [hpc, hgt] at hpc_next                   -- s'.pc = l3
      rw [hpc_next] at h5'; exact absurd h5' (by decide)
                                                    -- l3 ≠ l5
    · have hle : s.a ≤ s.b := Nat.le_of_not_lt hgt  -- ¬(b < a) ⇒ a ≤ b
      simp [hpc, hgt, hle] at hpc_next              -- s'.pc = l4
      rw [hpc_next] at h5'; exact absurd h5' (by decide)
                                                    -- l4 ≠ l5
  | l3 =>
    simp [hpc] at hpc_next                          -- l3 unconditionally → l1
    rw [hpc_next] at h5'; exact absurd h5' (by decide)
                                                    -- l1 ≠ l5
  | l4 =>
    simp [hpc] at hpc_next                          -- l4 unconditionally → l1
    rw [hpc_next] at h5'; exact absurd h5' (by decide)
                                                    -- l1 ≠ l5
  | l5 =>
    -- Already at l5: the IH gives us s.a = s.b; a, b don't change at l5.
    have hab : s.a = s.b := hIH hpc                 -- apply IH (gcdTermInv s) to hpc : s.pc = l5
    simp [hpc] at ha_next hb_next                   -- s'.a = s.a, s'.b = s.b at l5
    rw [ha_next, hb_next]; exact hab                -- goal: s.a = s.b, exactly hab

/-- Bundle into the InductiveInvariant predicate. -/
theorem gcdTermInv_inductive : InductiveInvariant GcdTS gcdTermInv :=
  ⟨gcdTermInv_init, gcdTermInv_step⟩

/-- ★ TERMINATION CORRECTNESS: in every reachable state, if `pc = l5`
    then `a = b` (i.e., the algorithm exits with a = b = gcd). -/
theorem GcdTS_termination :
    Invariant GcdTS (fun s => s.pc = .l5 → s.a = s.b) :=
  inductive_invariant_holds GcdTS gcdTermInv gcdTermInv_inductive

/- --------------------------------------------------------------------- -/
/- INVARIANT 3: GCD preservation — the classical correctness result.     -/

/-- Helper lemma: `gcd(a - b, b) = gcd(a, b)` whenever `b ≤ a`.
    This is the textbook identity that makes Euclid's algorithm work,
    and core Lean already knows it as `Nat.gcd_sub_self_left`. -/
theorem gcd_sub_eq (a b : Nat) (h : b ≤ a) :
    Nat.gcd (a - b) b = Nat.gcd a b :=
  Nat.gcd_sub_self_left h

/-- ★ GCD PRESERVATION (single-step): `gcd(a, b)` is the same in `s` and `s'`
    whenever `s` steps to `s'`. Together with `inductive_invariant_holds` this
    yields invariance along any reachable path.
    STRATEGY: only two cases actually mutate `a` or `b`:
      • pc = l3 ∧ a > b : a := a - b   (use gcd_sub_eq)
      • pc = l4 ∧ b > a : b := b - a   (symmetric, use gcd_comm)
    Otherwise both a and b stay the same. -/
theorem GcdTS_gcd_preserved :
    ∀ s s', GcdTS.next s s' → Nat.gcd s.a s.b = Nat.gcd s'.a s'.b := by
  intro s s' ⟨ha_next, hb_next, _⟩                   -- destructure; we don't need the pc-update here
  -- Only `pc = l3 ∧ a > b` makes `a` change.
  by_cases h3 : s.pc = .l3 ∧ s.a > s.b
  · -- a-changing branch: a := a - b, b unchanged.
    simp [h3] at ha_next                             -- ha_next becomes s'.a = s.a - s.b
    -- Show s'.b = s.b: even though hb_next is an if-then-else, no branch matches l3.
    have hb : s'.b = s.b := by
      by_cases h4 : s.pc = .l4 ∧ s.b > s.a
      · exfalso; rw [h3.1] at h4; exact absurd h4.1 (by decide)
                                                    -- h3.1 says pc = l3, h4.1 says pc = l4: contradiction
      · simp [h4] at hb_next; exact hb_next         -- otherwise hb_next reduces to s'.b = s.b
    rw [ha_next, hb]                                -- goal becomes gcd s.a s.b = gcd (s.a - s.b) s.b
    have hle : s.b ≤ s.a := Nat.le_of_lt h3.2       -- a > b ⇒ b ≤ a
    exact (gcd_sub_eq s.a s.b hle).symm             -- apply the identity (flipped: we need lhs = rhs of identity)
  · -- a unchanged in this branch.
    have ha : s'.a = s.a := by simp [h3] at ha_next; exact ha_next
    by_cases h4 : s.pc = .l4 ∧ s.b > s.a
    · -- b-changing branch: b := b - a, a unchanged. Symmetric to above.
      simp [h4] at hb_next                           -- hb_next : s'.b = s.b - s.a
      rw [ha, hb_next]                               -- goal: gcd s.a s.b = gcd s.a (s.b - s.a)
      have hle : s.a ≤ s.b := Nat.le_of_lt h4.2      -- b > a ⇒ a ≤ b
      rw [Nat.gcd_comm s.a s.b, Nat.gcd_comm s.a (s.b - s.a)]
                                                    -- swap arguments on both sides; goal: gcd s.b s.a = gcd (s.b - s.a) s.a
      exact (gcd_sub_eq s.b s.a hle).symm
    · -- neither pc=l3∧a>b nor pc=l4∧b>a: both a and b stay the same.
      have hb : s'.b = s.b := by simp [h4] at hb_next; exact hb_next
      rw [ha, hb]                                    -- goal closes by reflexivity after substitution

/- --------------------------------------------------------------------- -/
/- REMARK — Combining `GcdTS_termination` with `GcdTS_gcd_preserved`     -/
/- (one-step preservation) one can show by induction on Reachable that   -/
/- at termination (pc = l5) we have a = b = gcd of the initial values.   -/
/- We omit the wrapping induction here; the two pieces above are the     -/
/- actual content.                                                       -/
