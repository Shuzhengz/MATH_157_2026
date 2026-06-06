import Mathlib
import MATH_157.BasicIdentities

namespace MATH_157

open Real

noncomputable section

/-
For this definition section, I separated the original equation into many different
parts that are not easily written inside this lean file.
Refer to the Wideband.lean section in the included README.md for rendered equations.
-/

def directSignal (Sc rho E beta : ℝ → ℝ) (lambda1 lambda2 z : ℝ) : ℝ :=
  ∫ lam in lambda1..lambda2,
    Sc lam * rho lam * E lam * Real.exp (-beta lam * z)

def directSignalNext (Sc rho E beta : ℝ → ℝ) (lambda1 lambda2 z dz : ℝ) : ℝ :=
  ∫ lam in lambda1..lambda2,
    Sc lam * rho lam * E lam * Real.exp (-beta lam * (z + dz))

def betaDOriginal (Sc rho E beta : ℝ → ℝ) (lambda1 lambda2 z dz : ℝ) : ℝ :=
  Real.log
      (directSignal Sc rho E beta lambda1 lambda2 z /
       directSignalNext Sc rho E beta lambda1 lambda2 z dz) / dz

def betaDStable (Sc rho E beta : ℝ → ℝ) (lambda1 lambda2 z dz : ℝ) : ℝ :=
  (Real.log (directSignal Sc rho E beta lambda1 lambda2 z) -
   Real.log (directSignalNext Sc rho E beta lambda1 lambda2 z dz)) / dz

def backscatterRatio (Sc Binf beta : ℝ → ℝ) (lambda1 lambda2 z : ℝ) : ℝ :=
  (∫ lam in lambda1..lambda2,
      Sc lam * Binf lam * (1 - Real.exp (-beta lam * z))) /
  (∫ lam in lambda1..lambda2, Binf lam * Sc lam)

def betaBOriginal (Sc Binf beta : ℝ → ℝ) (lambda1 lambda2 z : ℝ) : ℝ :=
  -Real.log (1 - backscatterRatio Sc Binf beta lambda1 lambda2 z) / z

def betaBStable (Sc Binf beta : ℝ → ℝ) (lambda1 lambda2 z : ℝ) : ℝ :=
  stableMinusLogOneMinus (backscatterRatio Sc Binf beta lambda1 lambda2 z) / z

end

/--
Proves that the original wideband attenuation coefficient equals to the stable version
-/
theorem betaD_eq_stable
    (Sc rho E beta : ℝ → ℝ) (lambda1 lambda2 z dz : ℝ)
    (hz : 0 < directSignal Sc rho E beta lambda1 lambda2 z)
    (hz' : 0 < directSignalNext Sc rho E beta lambda1 lambda2 z dz) :
    betaDOriginal Sc rho E beta lambda1 lambda2 z dz
      =
    betaDStable Sc rho E beta lambda1 lambda2 z dz := by
  unfold betaDOriginal betaDStable
  have hA : directSignal Sc rho E beta lambda1 lambda2 z ≠ 0 := ne_of_gt hz
  have hB : directSignalNext Sc rho E beta lambda1 lambda2 z dz ≠ 0 := ne_of_gt hz'
  simpa using (congrArg (fun t : ℝ => t / dz) (Real.log_div hA hB))

/--
Proves that the original wideband backscatter coefficient equals to the stable version
-/
theorem betaB_eq_stable
    (Sc Binf beta : ℝ → ℝ) (lambda1 lambda2 z : ℝ) :
    betaBOriginal Sc Binf beta lambda1 lambda2 z
      =
    betaBStable Sc Binf beta lambda1 lambda2 z := by
  unfold betaBOriginal betaBStable
  rw [stableMinusLogOneMinus_eq]

end MATH_157
