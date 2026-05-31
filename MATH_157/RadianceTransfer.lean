import MATH_157.BasicIdentities

namespace MATH_157

open Real

noncomputable section

variable
  (L₀ Ls β Kd z θ : ℝ)

/--
Original RTE term.
-/
def radianceOriginal : ℝ :=
  L₀ * Real.exp (-β * z)
  +
  (Ls * Real.exp (-Kd * z * Real.cos θ))
    / (β - Kd * Real.cos θ)
      *
    (1 - Real.exp (-(β - Kd * Real.cos θ) * z))

/--
Numerically friendlier form.
-/
def radianceStable : ℝ :=
  L₀ * Real.exp (-β * z)
  +
  Ls / (β - Kd * Real.cos θ)
    *
    ( Real.exp (-Kd * z * Real.cos θ)
      -
      Real.exp (-β * z) )

theorem radiance_eq_stable :
    radianceOriginal L₀ Ls β Kd z θ
      =
    radianceStable L₀ Ls β Kd z θ := by
  unfold radianceOriginal radianceStable

  let a := Kd * z * Real.cos θ
  let b := β * z

  have h :
      Real.exp (-a)
        *
      (1 - Real.exp (-(b - a)))
        =
      Real.exp (-a) - Real.exp (-b) :=
    exp_subexp a b

  have hab :
      (β - Kd * Real.cos θ) * z
        =
      b - a := by
    dsimp [a, b]
    ring

  rw [hab] at h
  dsimp [a, b] at h

  ring_nf
  rw [h]
  ring

end

end MATH_157
