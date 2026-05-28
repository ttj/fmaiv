import Mathlib

open Finset

/-- Expected value of a Binomial(n, θ) random variable is n·θ.
    Stated as the algebraic identity over ℝ. -/
theorem binomial_expectation (n : ℕ) (θ : ℝ) :
    ∑ k ∈ range (n + 1), (k : ℝ) * (n.choose k : ℝ) * θ ^ k * (1 - θ) ^ (n - k) = n * θ := by
  rcases n with _ | m
  · simp
  -- Step 1: reindex k = j + 1 (the k = 0 term vanishes because of the leading factor 0).
  rw [Finset.sum_range_succ'
        (fun k => (k : ℝ) * ((m + 1).choose k : ℝ) * θ ^ k * (1 - θ) ^ ((m + 1) - k)) (m + 1)]
  simp only [Nat.cast_zero, zero_mul, add_zero]
  -- Step 2: rewrite each summand using (j+1)·C(m+1, j+1) = (m+1)·C(m, j) (absorption identity),
  -- θ^(j+1) = θ·θ^j, and (m+1)-(j+1) = m-j.
  have key : ∀ j ∈ range (m + 1),
      ((j + 1 : ℕ) : ℝ) * ((m + 1).choose (j + 1) : ℝ) * θ ^ (j + 1) *
          (1 - θ) ^ ((m + 1) - (j + 1)) =
      ((m + 1 : ℕ) : ℝ) * θ * ((m.choose j : ℝ) * θ ^ j * (1 - θ) ^ (m - j)) := by
    intro j _
    have h1 : (j + 1) * (m + 1).choose (j + 1) = (m + 1) * m.choose j := by
      rw [mul_comm]; exact (Nat.add_one_mul_choose_eq m j).symm
    have h2 : (m + 1) - (j + 1) = m - j := by omega
    have h1R : ((j + 1 : ℕ) : ℝ) * ((m + 1).choose (j + 1) : ℝ) =
               ((m + 1 : ℕ) : ℝ) * (m.choose j : ℝ) := by exact_mod_cast h1
    rw [h2, pow_succ, h1R]
    ring
  rw [sum_congr rfl key, ← mul_sum]
  -- Step 3: residual sum = (θ + (1-θ))^m = 1^m = 1 by binomial theorem.
  have hbinom : ∑ j ∈ range (m + 1), (m.choose j : ℝ) * θ ^ j * (1 - θ) ^ (m - j) = 1 := by
    have h := add_pow θ (1 - θ) m
    have hsum : θ + (1 - θ) = (1 : ℝ) := by ring
    rw [hsum, one_pow] at h
    -- h : 1 = ∑ k ∈ range (m+1), θ^k * (1-θ)^(m-k) * ↑(m.choose k)
    -- Avoid `rw [show (1 : ℝ) = ...]` which clobbers the `1` in `(1 - θ)`.
    calc ∑ j ∈ range (m + 1), (m.choose j : ℝ) * θ ^ j * (1 - θ) ^ (m - j)
        = ∑ k ∈ range (m + 1), θ ^ k * (1 - θ) ^ (m - k) * (m.choose k : ℝ) := by
          refine sum_congr rfl ?_; intros k _; ring
      _ = 1 := h.symm
  rw [hbinom, mul_one]
