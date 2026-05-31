import MATH_157.BasicIdentities

namespace MATH_157

open Real

noncomputable section

variable
  (b E β z : ℝ)

/--
Veiling light.
-/
def B∞ : ℝ :=
  b * E / β

/--
Original backscatter equation.
-/
def backscatter : ℝ :=
  b * E / β
    *
  (1 - Real.exp (-β * z))

/--
Factored form.
-/
def backscatterFactored : ℝ :=
  B∞ b E β
    *
  (1 - Real.exp (-β * z))

theorem backscatter_eq_factored :
    backscatter b E β z
      =
    backscatterFactored b E β z := by
  unfold backscatter backscatterFactored B∞

/--
Algebraic precursor to expm1 evaluation.
-/
theorem backscatter_expm1_style :
    backscatter b E β z
      =
    B∞ b E β
      *
      (-(Real.exp (-β * z) - 1)) := by
  unfold backscatter B∞
  rw [one_sub_exp_neg]
  ring

end

end MATH_157
