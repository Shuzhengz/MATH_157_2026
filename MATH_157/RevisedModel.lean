import MATH_157.BasicIdentities

namespace MATH_157

open Real

variable (J Binf betaD betaB z : ℝ)

noncomputable section

/-- Original image formation model -/
def imageFormationOriginal : ℝ :=
  J * Real.exp (-betaD * z) + Binf * (1 - Real.exp (-betaB * z))

/-- Rewritten stable image formation model -/
def imageFormationStable : ℝ :=
  J * Real.exp (-betaD * z) + Binf * stableOneMinusExpNeg (betaB * z)

end

/-- Original model equals to the stable model -/
theorem imageFormation_eq_stable :
    imageFormationOriginal J Binf betaD betaB z
      =
    imageFormationStable J Binf betaD betaB z := by
  unfold imageFormationOriginal imageFormationStable
  rw [stableOneMinusExpNeg_eq]
  congr 2
  ring_nf

end MATH_157
