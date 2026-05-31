import Mathlib

/-
This file provides proofs to some basic identities that are going to be used to proof rewrites of
relevant functions are correct
-/

namespace MATH_157

/--
A common cancellation-avoiding rewrite:

e^(-a) * (1 - e^(-(b-a))) = e^(-a) - e^(-b)
-/
theorem exp_subexp (a b : ℝ) :
    Real.exp (-a) * (1 - Real.exp (-(b - a)))
      =
    Real.exp (-a) - Real.exp (-b) := by
  rw [mul_sub, mul_one]
  have h :
      Real.exp (-a) * Real.exp (-(b - a))
        =
      Real.exp (-b) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [h]

/--
Log division rewrite proof

log(A/B) = log A - log B
-/
theorem log_div_rewrite
    {A B : ℝ}
    (hA : 0 < A)
    (hB : 0 < B) :
    Real.log (A / B)
      =
    Real.log A - Real.log B := by
  have hA' : A ≠ 0 := ne_of_gt hA
  have hB' : B ≠ 0 := ne_of_gt hB
  simpa using Real.log_div hA' hB'

/--
1 - e^(-x) = -(e^(-x)-1)

This is the algebra behind expm1-based implementations.
-/
theorem one_sub_exp_neg (x : ℝ) :
    1 - Real.exp (-x)
      =
    -(Real.exp (-x) - 1) := by
  ring

/--
Proves the negative log identity that:

-log(1-x) = log((1-x)^(-1))
for x < 1.
-/
theorem neg_log_one_sub
    {x : ℝ}
    (hx : x < 1) :
    -Real.log (1 - x)
      =
    Real.log ((1 - x)⁻¹) := by
  have h : 0 < 1 - x := sub_pos.mpr hx
  rw [Real.log_inv]

end MATH_157
