import MATH_157.BasicIdentities
import Mathlib

open MeasureTheory
open Real

namespace MATH_157

noncomputable section

variable
  (A : ℝ → ℝ)
  (z Δz : ℝ)

/--
Wideband attenuation coefficient.
-/
def betaD : ℝ :=
  Real.log (A z / A (z + Δz)) / Δz

/--
Stable log-difference form.
-/
def betaDStable : ℝ :=
  (Real.log (A z) - Real.log (A (z + Δz)))
    / Δz

theorem betaD_eq_stable
    (hz : 0 < A z)
    (hz' : 0 < A (z + Δz)) :
    betaD A z Δz
      =
    betaDStable A z Δz := by
  unfold betaD betaDStable
  rw [log_div_rewrite hz hz']

/--
Backscatter coefficient.
-/
def betaB (x z : ℝ) : ℝ :=
  -Real.log (1 - x) / z

/--
Equivalent reciprocal form.
-/
def betaBStable (x z : ℝ) : ℝ :=
  Real.log ((1 - x)⁻¹) / z

theorem betaB_eq_stable
    {x z : ℝ}
    (hx : x < 1) :
    betaB x z
      =
    betaBStable x z := by
  unfold betaB betaBStable
  rw [neg_log_one_sub hx]

end

end MATH_157
