/-
  Traffic-light transition system — STARTER (prove the safety invariant).

  The system is given. Prove `safe_inductive` (the init + step preservation),
  then `safe_invariant` follows from the framework. Worked solution:
  `TrafficLight.lean`.

  NOTATION: `inductive T where | a | b` defines a type by listing its values;
  `.green`/`.nsGo` is a dotted constructor (value of the expected type);
  `fun p => e` is an anonymous function; `¬ P` = not P; `P ∧ Q` = P and Q.
  TACTICS you'll need: `constructor` (split an AND goal in two), `intro x`
  (assume/name a variable or hypothesis; a leading `_` marks it unused),
  `cases p` (split into one subgoal per value of p), `t <;> s` (run s on every
  subgoal of t), `simp [..]` (simplify with the listed defs), `subst h`
  (use h : a = b to replace a by b). `sorry` is the placeholder to replace.
-/
import CounterDemo.TransitionSystem

namespace TrafficLightStarter

inductive Light where
  | red | green | yellow
deriving DecidableEq          -- auto-generates an equality test for Light

inductive Phase where
  | nsGo | nsYel | ewGo | ewYel
deriving DecidableEq

-- North-south light per phase (`| _ => .red` is the catch-all).
def ns : Phase → Light
  | .nsGo => .green | .nsYel => .yellow | _ => .red

-- East-west light per phase.
def ew : Phase → Light
  | .ewGo => .green | .ewYel => .yellow | _ => .red

-- The deterministic phase cycle.
def step : Phase → Phase
  | .nsGo => .nsYel | .nsYel => .ewGo | .ewGo => .ewYel | .ewYel => .nsGo

-- The system: only start phase is nsGo; next phase is exactly `step p`.
def ts : TransitionSystem Phase where
  init := fun p => p = Phase.nsGo
  next := fun p p' => p' = step p

-- Safety: the two directions are never green at the same time.
def safe (p : Phase) : Prop := ¬ (ns p = Light.green ∧ ew p = Light.green)

-- GOAL: show `safe` holds at the start AND is preserved by every step.
-- TODO: prove `safe` is an inductive invariant.
-- Hint: `constructor`, then in each part `cases p <;> simp [safe, ns, ew, step]`.
theorem safe_inductive : InductiveInvariant ts safe := by
  sorry   -- PROVE THIS: `constructor` splits into init + step parts. In the init part
          -- `intro p _` then `cases p <;> simp [safe, ns, ew]`. In the step part
          -- `intro p p' _ hn`, `subst hn`, then `cases p <;> simp [safe, ns, ew, step]`.

-- Follows automatically once safe_inductive is proved (no edits needed).
theorem safe_invariant : Invariant ts safe :=
  inductive_invariant_holds ts safe safe_inductive

end TrafficLightStarter
