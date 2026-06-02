import Mathlib

namespace MATH_157

open Real

noncomputable section

variable (b E β z : ℝ)

/--
Veiling light:
B∞ = b E / β
-/
def veilingLight : ℝ :=
  b * E / β

/--
Original backscatter equation:
B(z) = bE/β * (1 - exp(-β z))
-/
def backscatter : ℝ :=
  b * E / β * (1 - Real.exp (-β * z))

/--
Factored form using the veiling-light constant.
-/
def backscatterFactored : ℝ :=
  veilingLight b E β * (1 - Real.exp (-β * z))

theorem backscatter_eq_factored :
    backscatter b E β z = backscatterFactored b E β z := by
  rfl

/--
Algebraic rewrite behind expm1-style evaluation.
-/
theorem backscatter_expm1_style :
    backscatter b E β z
      =
    veilingLight b E β * (-(Real.exp (-β * z) - 1)) := by
  unfold backscatter veilingLight
  ring

/--
Stable form using the identity 1 - e^(-x) = -(e^(-x) - 1).
-/
theorem one_sub_exp_neg (x : ℝ) :
    1 - Real.exp (-x) = -(Real.exp (-x) - 1) := by
  ring

end

end MATH_157
