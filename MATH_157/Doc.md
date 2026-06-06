# MATH_157

A Lean 4 / Mathlib formalization of exact real-valued underwater image formation identities and their algebraically equivalent stable rewrites.

The project proves exact equalities over $\mathbb{R}$ such as:

- $1 - e^{-x} = -expm1(-x)$
- $\log(a/b) = \log(a) - \log(b)$
- $e^{-a} - e^{-b} = stableExpDiff(a,b)$

The development does **not** prove IEEE-754 error bounds. Instead, it proves that the original underwater imaging equations are mathematically equivalent to forms commonly used in numerically stable implementations.

---

# BasicIdentities.lean

This file contains the reusable algebraic identities.

## `expm1`

Lean definition:

    def expm1 (x : ℝ) : ℝ :=
      Real.exp x - 1

Mathematical meaning:

$expm1(x) = e^x - 1$

---

## `log1p`

Lean definition:

    def log1p (x : ℝ) : ℝ :=
      Real.log (1 + x)

Mathematical meaning:

$log1p(x) = \log(1+x)$

---

## `stableOneMinusExpNeg`

Lean definition:

    def stableOneMinusExpNeg (x : ℝ) : ℝ :=
      -expm1 (-x)

Mathematical meaning:

$1 - e^{-x}$

using the identity

$1 - e^{-x} = -expm1(-x)$.

---

## `stableLogRatio`

Lean definition:

    def stableLogRatio (a b : ℝ) : ℝ :=
      stableLog1p ((a - b) / b)

Mathematical meaning:

$\log(a/b)$

rewritten as

$\log\!\left(1 + \frac{a-b}{b}\right)$.

This is useful when $a \approx b$.

---

## `stableMinusLogOneMinus`

Lean definition:

    def stableMinusLogOneMinus (x : ℝ) : ℝ :=
      -stableLog1p (-x)

Mathematical meaning:

$-\log(1-x)$.

---

## `stableExpDiff`

Lean definition:

    def stableExpDiff (a b : ℝ) : ℝ := ...

Mathematical meaning:

$e^{-a} - e^{-b}$

without directly subtracting exponentials.

If $a \le b$:

$e^{-a} - e^{-b} =
e^{-a}(1-e^{-(b-a)})$

If $b < a$:

$e^{-a} - e^{-b} =
-e^{-b}(1-e^{-(a-b)})$

This avoids cancellation when $a \approx b$.

---

# Backscatter.lean

## `veilingLight`

Represents

$B^\infty = \frac{bE}{\beta}$

where:

- $b$ is the scattering coefficient
- $E$ is irradiance
- $\beta$ is attenuation

---

## `backscatterOriginal`

Represents

$B(z) =
B^\infty(1-e^{-\beta z})$.

---

## `backscatterStable`

Represents

$B(z) =
B^\infty\left(-expm1(-\beta z)\right)$.

---

## `backscatter_eq_stable`

Proves

$\texttt{backscatterOriginal} =
\texttt{backscatterStable}$.

---

# RevisedModel.lean

## `imageFormationOriginal`

Represents

$I =
J e^{-\beta_D z}
+
B^\infty(1-e^{-\beta_B z})$.

---

## `imageFormationStable`

Represents

$I =
J e^{-\beta_D z}
+
B^\infty\left(-expm1(-\beta_B z)\right)$.

---

## `imageFormation_eq_stable`

Proves exact equality between the original and stable formulations.

---

# RTE.lean

## `radianceOriginal`

Represents

$L = L_0 e^{-\beta z}
+
\frac{
L_s e^{-K_d z\cos\theta}
}{
\beta-K_d\cos\theta
}
\left(
1-e^{-(\beta-K_d\cos\theta)z}
\right)$.

---

## `radianceStable`

Represents

$L =
L_0 e^{-\beta z}
+
\frac{L_s}{\beta-K_d\cos\theta}
stableExpDiff
(K_d z\cos\theta,\beta z)$.

---

## `radiance_eq_stable`

Proves exact equality between the two forms.

---

# Wideband.lean

## `directSignal`

Represents

$D(z)=
\int_{\lambda_1}^{\lambda_2}
S_c(\lambda)
\rho(\lambda)
E(\lambda)
e^{-\beta(\lambda)z}
\,d\lambda$.

---

## `directSignalNext`

Represents

$D(z+\Delta z)$.

---

## `betaDOriginal`

Represents

$\beta_c^D =
\frac{
\log(D(z)/D(z+\Delta z))
}{
\Delta z
}$.

---

## `betaDStable`

Represents

$\beta_c^D =
\frac{
\log D(z) - \log D(z+\Delta z)
}{
\Delta z
}$.

---

## `betaD_eq_stable`

Proves

$\beta_c^D(\text{original}) =
\beta_c^D(\text{stable})$.

---

## `backscatterRatio`

Represents

$R =
\frac{
\int
S_c(\lambda)
B^\infty(\lambda)
(1-e^{-\beta(\lambda)z})
\,d\lambda
}{
\int
S_c(\lambda)
B^\infty(\lambda)
\,d\lambda
}$.

---

## `betaBOriginal`

Represents

$\beta_c^B =
-\frac{\log(1-R)}{z}$.

---

## `betaBStable`

Represents

$\beta_c^B=
\frac{
-\log1p(-R)
}{
z
}$.

---

## `betaB_eq_stable`

Proves exact equality between the two forms.

---

# What Is Proven

The project proves exact identities over $\mathbb{R}$, including:

- $1-e^{-x} = -expm1(-x)$
- $\log(a/b)=\log(a)-\log(b)$
- $e^{-a}-e^{-b}=stableExpDiff(a,b)$

and the corresponding identities for:

- backscatter models
- radiance transfer models
- revised image formation models
- wideband attenuation coefficients
- wideband backscatter coefficients

---

# What Is Not Proven

The project does not currently prove:

- FP32 error bounds
- FP64 error bounds
- IEEE-754 correctness

Those require a separate formal floating-point semantics and is outside the scope of this project

---

# Interpretation

The Lean proofs establish that the stable formulations are exactly equal to the original underwater imaging equations over $\mathbb{R}$.

A future project could build on these specifications to formally verify floating-point implementations and 
derive rigorous FP32/FP64 error bounds.
