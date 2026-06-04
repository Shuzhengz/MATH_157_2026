import Mathlib

namespace MATH_157

open Real

noncomputable section

/-- `expm1(x) = exp(x) - 1` as a specification wrapper. -/
def expm1 (x : ℝ) : ℝ :=
  Real.exp x - 1

/-- `log1p(x) = log(1 + x)` as a specification wrapper. -/
def log1p (x : ℝ) : ℝ :=
  Real.log (1 + x)

/-- Stable form of `1 - exp(-x)`. -/
def stableOneMinusExpNeg (x : ℝ) : ℝ :=
  -expm1 (-x)

/-- Stable form of `log(1 + x)`. -/
def stableLog1p (x : ℝ) : ℝ :=
  log1p x

/--
Stable difference of exponentials, written in a piecewise form.
This is an algebraic interface, not a floating-point proof.
-/
def stableExpDiff (a b : ℝ) : ℝ :=
  if a ≤ b then
    Real.exp (-a) * stableOneMinusExpNeg (b - a)
  else
    -(Real.exp (-b) * stableOneMinusExpNeg (a - b))

/-- Stable form of `log(a / b)` near `a ≈ b`. -/
def stableLogRatio (a b : ℝ) : ℝ :=
  stableLog1p ((a - b) / b)

/-- Stable form of `-log(1 - x)`. -/
def stableMinusLogOneMinus (x : ℝ) : ℝ :=
  -stableLog1p (-x)

end

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

theorem stableOneMinusExpNeg_eq (x : ℝ) :
    stableOneMinusExpNeg x = 1 - Real.exp (-x) := by
  unfold stableOneMinusExpNeg expm1
  ring

theorem stableLog1p_eq (x : ℝ) :
    stableLog1p x = Real.log (1 + x) := by
  rfl

theorem stableMinusLogOneMinus_eq (x : ℝ) :
    stableMinusLogOneMinus x = -Real.log (1 - x) := by
  unfold stableMinusLogOneMinus stableLog1p log1p
  simp [sub_eq_add_neg]

theorem stableLogRatio_eq {a b : ℝ} (hb : b ≠ 0) :
    stableLogRatio a b = Real.log (a / b) := by
  unfold stableLogRatio stableLog1p log1p
  congr
  field_simp [hb]
  ring

theorem stableExpDiff_eq (a b : ℝ) :
    stableExpDiff a b = Real.exp (-a) - Real.exp (-b) := by
  by_cases h : a ≤ b
  · have h' :
        Real.exp (-a) * stableOneMinusExpNeg (b - a)
          =
        Real.exp (-a) - Real.exp (-b) := by
      rw [stableOneMinusExpNeg_eq]
      exact exp_subexp a b
    simpa [stableExpDiff, h] using h'
  · have h' :
        -(Real.exp (-b) * stableOneMinusExpNeg (a - b))
          =
        Real.exp (-a) - Real.exp (-b) := by
      rw [stableOneMinusExpNeg_eq]
      rw [exp_subexp b a]
      ring
    simpa [stableExpDiff, h] using h'

end MATH_157
