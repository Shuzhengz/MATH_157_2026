import Mathlib

namespace MATH_157

open Real

noncomputable section

def expm1 (x : ℝ) : ℝ := Real.exp x - 1
def log1p (x : ℝ) : ℝ := Real.log (1 + x)

def stableOneMinusExpNeg (x : ℝ) : ℝ :=
  -expm1 (-x)

def stableLog1p (x : ℝ) : ℝ :=
  log1p x

def stableLogRatio (a b : ℝ) : ℝ :=
  stableLog1p ((a - b) / b)

def stableMinusLogOneMinus (x : ℝ) : ℝ :=
  -stableLog1p (-x)

def stableExpDiff (a b : ℝ) : ℝ :=
  if a ≤ b then
    Real.exp (-a) * stableOneMinusExpNeg (b - a)
  else
    -(Real.exp (-b) * stableOneMinusExpNeg (a - b))

end

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

theorem exp_subexp (a b : ℝ) :
    Real.exp (-a) * (1 - Real.exp (-(b - a)))
      =
    Real.exp (-a) - Real.exp (-b) := by
  rw [mul_sub, mul_one]
  have h :
      Real.exp (-a) * Real.exp (-(b - a)) = Real.exp (-b) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [h]

theorem stableLogRatio_eq {a b : ℝ} (hb : b ≠ 0) :
    stableLogRatio a b = Real.log (a / b) := by
  unfold stableLogRatio stableLog1p log1p
  have h1 : 1 + (a - b) / b = a / b := by
    field_simp [hb]
    ring
  rw [h1]

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


--------------------------------------------------------------------------------
-- NUMERICAL STABILITY JUSTIFICATION
--------------------------------------------------------------------------------

/-
NOTE: In the exact real numbers (ℝ), `Real.exp x - 1` has no rounding error.
To formally prove "stability," one must model IEEE-754 floating-point arithmetic
and prove relative error bounds, which is outside the scope of exact real analysis.

Instead, we define the mathematical foundation that allows the CPU to execute
`expm1` securely. By representing `expm1` as an infinite Taylor series starting
from n=1, the hardware bypasses the unstable 1 - 1 subtraction entirely.
-/

/--
The Taylor series terms for expm1, analytically bypassing the 0th term (1)
-/
noncomputable def expm1_taylor_term (x : ℝ) (n : ℕ) : ℝ :=
  (x ^ (n + 1)) / ((n + 1).factorial : ℝ)

/-
It reached 200000 somehow
-/
set_option maxHeartbeats 500000

/--
This theorem asserts the algebraic equivalence between the exact real formula
and the infinite polynomial series used by standard math libraries.
-/
theorem expm1_eq_taylor_series (x : ℝ) :
    Filter.Tendsto (fun k => ∑ i ∈ Finset.range k, expm1_taylor_term x i)
      Filter.atTop (nhds (expm1 x)) := by
  let f : ℕ → ℝ := fun n => x ^ n / ((n.factorial : ℕ) : ℝ)

  have hf : HasSum f (Real.exp x) := by
    simpa [f, Real.exp_eq_exp_ℝ] using
      (NormedSpace.expSeries_div_hasSum_exp (x := x))

  have htail : HasSum (fun n : ℕ => f (n + 1)) (Real.exp x - 1) := by
    simpa [f] using
      ((hasSum_nat_add_iff' (f := f) (k := 1) (g := Real.exp x)).2 hf)

  have htail' : HasSum (fun n : ℕ => expm1_taylor_term x n) (expm1 x) := by
    simpa [f, expm1_taylor_term, expm1] using htail

  simpa using htail'.tendsto_sum_nat

end MATH_157
