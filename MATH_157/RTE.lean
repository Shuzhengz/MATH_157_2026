import Mathlib

namespace MATH_157

open Real

noncomputable section

variable
  (L₀ Ls β Kd z θ : ℝ)

/--
Original radiance transfer equation.
-/
def radianceOriginal : ℝ :=
  L₀ * Real.exp (-β * z)
  +
  (Ls * Real.exp (-Kd * z * Real.cos θ))
    / (β - Kd * Real.cos θ)
    * (1 - Real.exp (-(β - Kd * Real.cos θ) * z))

/--
Stable rewrite form.
-/
def radianceStable : ℝ :=
  L₀ * Real.exp (-β * z)
  +
  Ls / (β - Kd * Real.cos θ)
    * (Real.exp (-Kd * z * Real.cos θ) - Real.exp (-β * z))

theorem radiance_eq_stable :
    radianceOriginal L₀ Ls β Kd z θ
      =
    radianceStable L₀ Ls β Kd z θ := by
  unfold radianceOriginal radianceStable
  have hmul :
      (Ls * Real.exp (-Kd * z * Real.cos θ)) / (β - Kd * Real.cos θ)
        =
      Ls / (β - Kd * Real.cos θ) * Real.exp (-Kd * z * Real.cos θ) := by
    rw [div_eq_mul_inv, div_eq_mul_inv]
    ring
  have hterm :
      Real.exp (-Kd * z * Real.cos θ) *
        (1 - Real.exp (-(β - Kd * Real.cos θ) * z))
      =
      Real.exp (-Kd * z * Real.cos θ) - Real.exp (-β * z) := by
    rw [mul_sub, mul_one]
    have h0 :
        Real.exp (-Kd * z * Real.cos θ) *
          Real.exp (-(β - Kd * Real.cos θ) * z)
        =
        Real.exp (-β * z) := by
      rw [← Real.exp_add]
      congr 1
      ring
    rw [h0]
  rw [hmul, mul_assoc, hterm]

end

end MATH_157
