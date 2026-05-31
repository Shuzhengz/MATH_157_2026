import MATH_157.BasicIdentities

namespace MATH_157

open Real

noncomputable section

variable
  (J B∞ βD βB z : ℝ)

/--
Revised image formation model.
-/
def imageFormation : ℝ :=
  J * Real.exp (-βD * z)
  +
  B∞ * (1 - Real.exp (-βB * z))

/--
Version exposing cancellation-sensitive term.
-/
def imageFormationStable : ℝ :=
  J * Real.exp (-βD * z)
  +
  B∞ * (-(Real.exp (-βB * z) - 1))

theorem imageFormation_eq_stable :
    imageFormation J B∞ βD βB z
      =
    imageFormationStable J B∞ βD βB z := by
  unfold imageFormation imageFormationStable
  rw [one_sub_exp_neg]
  ring

end

end MATH_157
