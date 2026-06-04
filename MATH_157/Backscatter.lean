import MATH_157.BasicIdentities

namespace MATH_157

open Real

noncomputable section

variable (b E beta z : ℝ)

/-- Veiling light. -/
def veilingLight : ℝ :=
  b * E / beta

/-- Original backscatter term. -/
def backscatterOriginal : ℝ :=
  veilingLight b E beta * (1 - Real.exp (-(beta * z)))

/-- Stable backscatter term. -/
def backscatterStable : ℝ :=
  veilingLight b E beta * stableOneMinusExpNeg (beta * z)

theorem backscatter_eq_stable :
    backscatterOriginal b E beta z = backscatterStable b E beta z := by
  unfold backscatterOriginal backscatterStable veilingLight
  rw [stableOneMinusExpNeg_eq]

theorem veilingLightLimit_eq :
    veilingLight b E beta = b * E / beta := by
  rfl

end

end MATH_157
