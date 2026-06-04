import MATH_157.BasicIdentities

namespace MATH_157

open Real

variable (J Binf betaD betaB z : ℝ)

noncomputable section

def imageFormationOriginal : ℝ :=
  J * Real.exp (-betaD * z) + Binf * (1 - Real.exp (-betaB * z))

def imageFormationStable : ℝ :=
  J * Real.exp (-betaD * z) + Binf * stableOneMinusExpNeg (betaB * z)

end

theorem imageFormation_eq_stable :
    imageFormationOriginal J Binf betaD betaB z
      =
    imageFormationStable J Binf betaD betaB z := by
  unfold imageFormationOriginal imageFormationStable
  rw [stableOneMinusExpNeg_eq]
  congr 2
  ring_nf

end MATH_157
