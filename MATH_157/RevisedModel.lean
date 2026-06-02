import Mathlib
import MATH_157.BasicIdentities

namespace MATH_157

open Real

noncomputable section

/--
Revised image formation model:

I_c = J_c * exp(-betaD * z) + Binf * (1 - exp(-betaB * z))
-/
def imageFormation (J Binf betaD betaB z : ℝ) : ℝ :=
  J * Real.exp (-(betaD * z)) + Binf * (1 - Real.exp (-(betaB * z)))

/--
Stable form, exposing the cancellation-sensitive term.
-/
def imageFormationStable (J Binf betaD betaB z : ℝ) : ℝ :=
  J * Real.exp (-(betaD * z)) + Binf * (-(Real.exp (-(betaB * z)) - 1))

theorem imageFormation_eq_stable
    (J Binf betaD betaB z : ℝ) :
    imageFormation J Binf betaD betaB z
      =
    imageFormationStable J Binf betaD betaB z := by
  unfold imageFormation imageFormationStable
  rw [one_sub_exp_neg]

/--
Equivalent explicit expansion of the stable rewrite.
-/
theorem imageFormation_eq_stable' (J Binf betaD betaB z : ℝ) :
    imageFormation J Binf betaD betaB z
      =
    J * Real.exp (-(betaD * z)) + Binf * (-(Real.exp (-(betaB * z)) - 1)) := by
  rfl

end

end MATH_157
