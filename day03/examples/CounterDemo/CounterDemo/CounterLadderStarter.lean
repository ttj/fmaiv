/-
  A guided tactic "ladder" for the running counter — STARTER.
  ==========================================================

  Replace each `sorry` with a proof. Each rung isolates ONE tactic; the comment
  on each tells you exactly which. Open this file in VS Code (Lean 4 extension)
  and watch the InfoView goal change as you type. Build just this file with:

      cd examples/CounterDemo
      lake build CounterDemo.CounterLadderStarter   -- `sorry` warnings until done

  Climb in order — later rungs reuse earlier skills. Worked solution:
  CounterLadder.lean.
-/
import CounterDemo.Counter

namespace CounterLadderStarter

-- RUNG 1 — `omega` decides linear arithmetic over Nat/Int.
theorem rung1_omega (x : Nat) (h : x < 10) : x + 1 ≤ 10 := by
  sorry   -- one tactic: omega

-- RUNG 2 — an AND hypothesis `h : A ∧ B` splits as `h.1 : A`, `h.2 : B`.
-- `counterInv s` is by definition `s.x ≤ 10 ∧ (s.mode = .off → s.x = 0)`.
theorem rung2_and_elim (s : CounterState) (h : counterInv s) : s.x ≤ 10 := by
  sorry   -- `exact h.1`

-- RUNG 3 — to PROVE an AND, use `constructor`, then a `·` bullet per side.
theorem rung3_and_intro (s : CounterState) (h : s.x = 0) :
    s.x ≤ 10 ∧ s.x = 0 := by
  sorry   -- `constructor` ; first bullet `omega` ; second bullet `exact h`

-- RUNG 4 — modus ponens: `h : P → Q` applied to a proof of P gives Q.
theorem rung4_modus_ponens (s : CounterState)
    (h : s.mode = .off → s.x = 0) (hoff : s.mode = .off) : s.x = 0 := by
  sorry   -- `exact h hoff`

-- RUNG 5 — `cases s.mode with | off => .. | on => ..` splits on the mode and
-- replaces s.mode with the concrete value in the goal.
theorem rung5_cases (s : CounterState) : s.mode = .off ∨ s.mode = .on := by
  sorry   -- `cases s.mode with` ; each branch closes with `exact Or.inl rfl` / `Or.inr rfl`

-- RUNG 6 — CAPSTONE. Every initial state satisfies the strengthened invariant
-- (this is `counterInv_init`). Assemble it from the rungs above.
theorem rung6_base_case : ∀ s, CounterTS.init s → counterInv s := by
  sorry   -- `intro s ⟨hm, hx⟩` ; `constructor` ; `simp [hx]` ; `intro _; exact hx`

end CounterLadderStarter
