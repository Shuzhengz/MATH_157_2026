import MATH_157.BasicIdentities

namespace MATH_157

open Real

variable (L0 Ls beta Kd z theta : ℝ)

noncomputable section

/--
Original RTE
-/
def radianceOriginal : ℝ :=
  L0 * Real.exp (-beta * z)
    + (Ls * Real.exp (-Kd * z * Real.cos theta))
        / (beta - Kd * Real.cos theta)
        * (1 - Real.exp (-(beta - Kd * Real.cos theta) * z))

/--
Rewritten stable RTE
-/
def radianceStable : ℝ :=
  L0 * Real.exp (-beta * z)
    + Ls / (beta - Kd * Real.cos theta)
        * stableExpDiff (Kd * z * Real.cos theta) (beta * z)

end

/--
The stable RTE is equivalent to the original RTE
-/
theorem radiance_eq_stable :
    radianceOriginal L0 Ls beta Kd z theta
      =
    radianceStable L0 Ls beta Kd z theta := by
  unfold radianceOriginal radianceStable
  have hmul :
      (Ls * Real.exp (-Kd * z * Real.cos theta)) / (beta - Kd * Real.cos theta)
        * (1 - Real.exp (-(beta - Kd * Real.cos theta) * z))
      =
      (Ls / (beta - Kd * Real.cos theta))
        * (Real.exp (-Kd * z * Real.cos theta)
            * (1 - Real.exp (-(beta - Kd * Real.cos theta) * z))) := by
    rw [div_eq_mul_inv, div_eq_mul_inv]
    ring
  have hfactor :
      Real.exp (-Kd * z * Real.cos theta)
        * (1 - Real.exp (-(beta - Kd * Real.cos theta) * z))
      =
      stableExpDiff (Kd * z * Real.cos theta) (beta * z) := by
    have h1 :
        Real.exp (-Kd * z * Real.cos theta)
          * (1 - Real.exp (-(beta - Kd * Real.cos theta) * z))
        =
        Real.exp (-Kd * z * Real.cos theta) - Real.exp (-beta * z) := by
      rw [mul_sub, mul_one]
      have h0 :
          Real.exp (-Kd * z * Real.cos theta)
            * Real.exp (-(beta - Kd * Real.cos theta) * z)
          =
          Real.exp (-beta * z) := by
        rw [← Real.exp_add]
        congr 1
        ring
      rw [h0]
    have h2 :
        stableExpDiff (Kd * z * Real.cos theta) (beta * z)
        =
        Real.exp (-Kd * z * Real.cos theta) - Real.exp (-beta * z) := by
      simpa using (stableExpDiff_eq (Kd * z * Real.cos theta) (beta * z))
    exact h1.trans h2.symm
  rw [hmul, hfactor]

end MATH_157
