import Mathlib

/-! # The Pythagorean theorem, three views

The classical statement: in a right triangle with legs `a`, `b` and
hypotenuse `c`, `a² + b² = c²`. Three formal renderings follow, climbing
from concrete arithmetic up to abstract inner-product spaces.
-/

open Real
open scoped InnerProductSpace

namespace Pythagorean

/-- View 1.  Concrete Pythagorean triples — verified by `decide`.
    These are the three smallest *primitive* triples (gcd = 1). -/
example : (3 : ℕ)^2 + 4^2 = 5^2 := by decide
example : (5 : ℕ)^2 + 12^2 = 13^2 := by decide
example : (8 : ℕ)^2 + 15^2 = 17^2 := by decide

/-- View 2.  Two-dimensional Euclidean form: for `v : EuclideanSpace ℝ (Fin 2)`,
    `‖v‖² = v 0 ² + v 1 ²` — the schoolbook "hypotenuse from legs" statement. -/
theorem pythagorean_2d (v : EuclideanSpace ℝ (Fin 2)) :
    ‖v‖^2 = v 0 ^ 2 + v 1 ^ 2 := by
  rw [EuclideanSpace.norm_eq, Real.sq_sqrt (by positivity)]
  simp [Fin.sum_univ_two, sq_abs]

/-- View 3.  In any real inner-product space, orthogonal vectors satisfy
    `‖u + v‖² = ‖u‖² + ‖v‖²` — the full general form of the Pythagorean
    identity. Uses Mathlib's `inner_mul_le_norm_mul_norm` neighbourhood. -/
theorem pythagorean_inner {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (u v : E) (h : ⟪u, v⟫_ℝ = 0) :
    ‖u + v‖^2 = ‖u‖^2 + ‖v‖^2 := by
  rw [@norm_add_sq_real, h]
  ring

end Pythagorean
