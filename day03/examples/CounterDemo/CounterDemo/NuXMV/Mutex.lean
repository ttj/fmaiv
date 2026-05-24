/-
  Mutex — auto-generated from `mutex.smv`
  =========================================

  This file was produced by `scripts/smv2lean.py` from the SMV
  source `mutex.smv`. It contains:

    • Lean encodings of the SMV variable types (enums become
      `inductive`s, booleans become `Bool`, ranges become `Nat`).
    • A `State` structure holding all variables of the model.
    • A `TransitionSystem` value (`<name>TS`) capturing the SMV
      `init` and `next` clauses. Nondeterministic SMV inputs
      become existentially-quantified variables in `next`.
    • For each `INVARSPEC` in the SMV, a Lean `theorem` STUB whose
      body is `sorry`. These stubs are placeholders — the real
      proofs (where we have them) live in `CounterDemo.NuXMV.MutexProofs`.

  Do NOT hand-edit this file: it will be overwritten by the next
  run of `smv2lean.py`. Add proofs in the corresponding
  `*Proofs.lean` file instead.
-/
import CounterDemo.TransitionSystem

inductive Process1Val where
  | idle
  | waiting
  | critical
  deriving DecidableEq, Repr

open Process1Val

inductive Process2Val where
  | idle
  | waiting
  | critical
  deriving DecidableEq, Repr

open Process2Val

structure MutexState where
  process1 : Process1Val
  process2 : Process2Val
  turn : Nat
  flag1 : Bool
  flag2 : Bool
  deriving DecidableEq, Repr

def MutexTS : TransitionSystem MutexState where
  init s := s.process1 = .idle ∧ s.process2 = .idle ∧ s.turn = 1 ∧ s.flag1 = false ∧ s.flag2 = false
  next s s' :=
    (if (s.process1 = .idle) then (s'.process1 = .idle ∨ s'.process1 = .waiting)
    else if ((s.process1 = .waiting) ∧ ((s.flag2 = false) ∨ (s.turn = 1))) then s'.process1 = .critical
    else if (s.process1 = .critical) then s'.process1 = .idle
    else s'.process1 = s.process1)
    ∧
    (if (s.process2 = .idle) then (s'.process2 = .idle ∨ s'.process2 = .waiting)
    else if ((s.process2 = .waiting) ∧ ((s.flag1 = false) ∨ (s.turn = 2))) then s'.process2 = .critical
    else if (s.process2 = .critical) then s'.process2 = .idle
    else s'.process2 = s.process2)
    ∧
    (if (s.process1 = .critical) then s'.turn = 2
    else if (s.process2 = .critical) then s'.turn = 1
    else s'.turn = s.turn)
    ∧
    (if ((s.process1 = .idle) ∧ (s'.process1 = .waiting)) then s'.flag1 = true
    else if ((s.process1 = .critical) ∧ (s'.process1 = .idle)) then s'.flag1 = false
    else s'.flag1 = s.flag1)
    ∧
    (if ((s.process2 = .idle) ∧ (s'.process2 = .waiting)) then s'.flag2 = true
    else if ((s.process2 = .critical) ∧ (s'.process2 = .idle)) then s'.flag2 = false
    else s'.flag2 = s.flag2)

-- INVARSPEC (from mutex.smv): !(((process1 = critical) & (process2 = critical)))
theorem MutexTS_inv1 :
    Invariant MutexTS (fun s => (¬((s.process1 = .critical) ∧ (s.process2 = .critical)))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.MutexProofs.
  sorry

-- INVARSPEC (from mutex.smv): ((process1 = critical) -> (!(flag2) | (turn = 1)))
theorem MutexTS_inv2 :
    Invariant MutexTS (fun s => ((s.process1 = .critical) → ((s.flag2 = false) ∨ (s.turn = 1)))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.MutexProofs.
  sorry

-- INVARSPEC (from mutex.smv): ((process2 = critical) -> (!(flag1) | (turn = 2)))
theorem MutexTS_inv3 :
    Invariant MutexTS (fun s => ((s.process2 = .critical) → ((s.flag1 = false) ∨ (s.turn = 2)))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.MutexProofs.
  sorry

-- INVARSPEC (from mutex.smv): (((process1 = idle) | (process1 = waiting)) | (process1 = critical))
theorem MutexTS_inv4 :
    Invariant MutexTS (fun s => (((s.process1 = .idle) ∨ (s.process1 = .waiting)) ∨ (s.process1 = .critical))) := by
  -- placeholder; real proof (if any) is in CounterDemo.NuXMV.MutexProofs.
  sorry

