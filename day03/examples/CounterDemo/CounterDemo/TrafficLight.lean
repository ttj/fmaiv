/-
  A traffic-light intersection as a transition system.
  ====================================================

  The Day-2 model checker proved `!(main = green & side = green)` for the
  traffic_light.smv model. Here is the same system as a Lean transition system
  (using the framework in TransitionSystem.lean), with the same safety property
  proved as an inductive invariant — the count example's pattern, applied to a
  second machine.

  NOTATION CHEAT-SHEET:
    • inductive T where | a | b   — define a new type T by listing its values
                                    (here, the possible lights / phases).
    • `.green`, `.nsGo`           — dotted constructor: a value of the expected
                                    type whose name is `green` / `nsGo`.
    • `fun p => e`                — anonymous function (lambda): input p, output e.
    • `¬ P`                       — "not P".   `P ∧ Q` — "P and Q".
    • `a = b`                     — claim that a equals b.
  TACTICS USED HERE:
    • constructor — to prove an "AND" goal, split it into its two parts.
    • intro x     — assume/name a ∀-variable or hypothesis x (a leading `_` = unused).
    • cases p     — split into one subgoal per value `p` can take.
    • t <;> s     — run tactic `s` on EVERY subgoal that `t` produced.
    • simp [..]   — simplify using the listed definitions (here ns/ew/step/safe).
    • subst h     — given h : a = b, replace a by b everywhere (eliminates a).
-/
import CounterDemo.TransitionSystem

namespace TrafficLight

-- The three colors a light can show:
inductive Light where
  | red | green | yellow
deriving DecidableEq          -- auto-generate an equality test for Light values

/-- The controller cycles through four phases. -/
inductive Phase where
  | nsGo | nsYel | ewGo | ewYel
deriving DecidableEq

/-- North–south light in each phase. -/
-- `| _ => ..` is a catch-all: any phase not listed above maps to red.
def ns : Phase → Light
  | .nsGo  => .green
  | .nsYel => .yellow
  | _      => .red

/-- East–west light in each phase. -/
def ew : Phase → Light
  | .ewGo  => .green
  | .ewYel => .yellow
  | _      => .red

/-- The deterministic phase cycle. -/
def step : Phase → Phase
  | .nsGo  => .nsYel
  | .nsYel => .ewGo
  | .ewGo  => .ewYel
  | .ewYel => .nsGo

/-- The transition system: start in `nsGo`, advance by `step`. -/
-- Fill the framework's two fields: init (the only start phase) and next
-- (the relation "p' is exactly the phase after p").
def ts : TransitionSystem Phase where
  init := fun p => p = Phase.nsGo
  next := fun p p' => p' = step p

/-- Safety property: the two directions are never both green. -/
def safe (p : Phase) : Prop := ¬ (ns p = Light.green ∧ ew p = Light.green)

/-- `safe` is an inductive invariant: it holds initially and is preserved by
    every transition. Both parts are immediate by case analysis on the phase
    (at most one direction is green in any phase). -/
theorem safe_inductive : InductiveInvariant ts safe := by
  constructor                          -- split into: (1) holds at init, (2) preserved by step
  · intro p _hp                        -- part 1: take a phase p and the (unused) proof it's initial
    cases p <;> simp [safe, ns, ew]    -- try all 4 phases; each is dispatched by unfolding the defs
  · intro p p' _hp hn                  -- part 2: take pre-phase p, post-phase p', and hn : p' = step p
    subst hn                           -- replace p' by `step p` everywhere using hn
    cases p <;> simp [safe, ns, ew, step]  -- check all 4 phases; in none are both lights green

/-- Therefore mutual exclusion of green holds on every reachable state. -/
-- Plug the inductive invariant into the framework theorem (term-mode, no `by`).
theorem safe_invariant : Invariant ts safe :=
  inductive_invariant_holds ts safe safe_inductive

end TrafficLight
