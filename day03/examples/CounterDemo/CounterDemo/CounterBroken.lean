/-
  "Break the proof" diagnostic — Day 3 Part C.
  ===========================================

  Days 1, 2, and 4 each end with a deliberate bug whose counterexample you read.
  Here is the Day-3 analogue, but the "bug" is a WRONG INVARIANT: we claim the
  counter satisfies `x ≤ 5`. It does not — x reaches 10. Your job is to *try*
  the inductive proof, find the EXACT case where it gets stuck, and read off the
  counterexample.

  This file is meant to NOT go through: `badInv_step` is a false statement, so it
  stays `sorry`. Open it in VS Code and replace the `sorry` with the same case
  tree as `counterInv_step` (Counter.lean) to watch where it breaks.

  Build just this file (it will warn about `sorry`, as intended):
      cd examples/CounterDemo
      lake build CounterDemo.CounterBroken
-/
import CounterDemo.Counter

namespace CounterBroken

-- The FALSE candidate invariant.
def badInv (s : CounterState) : Prop := s.x ≤ 5

-- The inductive STEP cannot be proved — and that failure is the lesson.
-- Replace `sorry` with the case tree from `counterInv_step`:
--   intro s s' hbad ⟨press', hpress, hmode_next, hx_next⟩
--   cases hm : s.mode  →  by_cases hp : s.press = true  →  by_cases hlt : s.x < 10
-- In the (on, ¬press, x < 10) branch the hypotheses give  s'.x = s.x + 1  with
-- only  s.x ≤ 5  available, so the goal  s'.x ≤ 5  is UNPROVABLE: `omega` fails
-- because s.x could be 5, making s'.x = 6. That stuck goal is the whole point.
theorem badInv_step :
    ∀ s s', badInv s → CounterTS.next s s' → badInv s' := by
  sorry

/-
  DIAGNOSIS — answer in this comment (no Lean required):

    1. Which branch gets stuck?   mode = ____ , press = ____ , x < 10 ? ____

    2. Counterexample trace. Starting from the initial state (mode = off, x = 0),
       give the shortest input sequence (a list of `press` values) that drives
       the counter to a state with x = 6 > 5. How many steps is it?

    3. Why does the REAL invariant `counterInv` (Counter.lean) go through where
       this one fails? (Hint: it bounds x by 10 — exactly where the increment
       guard `x < 10` stops firing — and adds the strengthening `mode = off →
       x = 0`. The bound 5 is simply not preserved by the increment.)
-/

end CounterBroken
