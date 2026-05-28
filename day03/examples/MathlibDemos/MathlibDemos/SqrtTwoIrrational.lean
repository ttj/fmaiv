import Mathlib

/-! # √2 is irrational

The classical Euclid argument: assume `√2 = p/q` in lowest terms.
Then `p² = 2q²`, so `2 ∣ p²`, so `2 ∣ p`, so `p = 2k`.
Substituting: `4k² = 2q²`, so `q² = 2k²`, so `2 ∣ q`.
But `gcd(p, q) = 1`, contradiction. ∎
-/

namespace SqrtTwo

/-- Mathlib one-liner: `√p` is irrational for any prime `p`. -/
theorem sqrt_two_irrational : Irrational (Real.sqrt 2) :=
  Nat.Prime.irrational_sqrt (by decide)

/-- The arithmetic content: no coprime pair of naturals `(p, q)` with `q > 0`
    satisfies `p² = 2 q²`. -/
theorem no_coprime_sq_eq_two_mul_sq :
    ¬ ∃ p q : ℕ, 0 < q ∧ Nat.Coprime p q ∧ p ^ 2 = 2 * q ^ 2 := by
  rintro ⟨p, q, _, hcop, hp2⟩
  -- 2 ∣ p² (witnessed by q²).
  have h2dvd_p2 : 2 ∣ p ^ 2 := ⟨q ^ 2, hp2⟩
  -- Primality of 2 lifts: 2 ∣ p.
  have h2dvd_p : 2 ∣ p := Nat.Prime.dvd_of_dvd_pow Nat.prime_two h2dvd_p2
  obtain ⟨k, rfl⟩ := h2dvd_p
  -- (2k)² = 4k² = 2q²  ⇒  q² = 2k².
  have hq2 : q ^ 2 = 2 * k ^ 2 := by
    have hsq : (2 * k) ^ 2 = 4 * k ^ 2 := by ring
    omega
  -- Same lift: 2 ∣ q.
  have h2dvd_q : 2 ∣ q := Nat.Prime.dvd_of_dvd_pow Nat.prime_two ⟨k ^ 2, hq2⟩
  -- 2 ∣ gcd(2k, q) = 1 — done.
  have : 2 ∣ Nat.gcd (2 * k) q := Nat.dvd_gcd ⟨k, rfl⟩ h2dvd_q
  rw [hcop] at this
  omega

end SqrtTwo
