# MATH 157: Numerically Stable Underwater Image Formation Models

This repository contains Lean 4 formalizations for numerically stable models of underwater image formation, radiative transfer, and wideband signal attenuation. Floating-point arithmetic introduces significant precision losses when calculating the differences between numbers of similar magnitude, particularly in exponential and logarithmic decay models. This project bridges standard algebraic formulations with numerically robust equivalents using Lean 4 to formally verify their exact equivalence in the real numbers ($\mathbb{R}$).

---

## Repository Structure

| File | Purpose | Core Concepts |
| :--- | :--- | :--- |
| **`BasicIdentities.lean`** | Foundational stability primitives. | Wrappers for `expm1`, `log1p`, and robust difference-of-exponentials. |
| **`RTE.lean`** | Radiative Transfer Equation. | Verifying stable radiance derivations for underwater light transport. |
| **`Backscatter.lean`** | Veiling light and backscatter. | Formalizing the backscatter term and its asymptotic limits. |
| **`Wideband.lean`** | Wideband spectrum analysis. | Signal integrations, direct attenuation ($\beta_D$), and backscatter ($\beta_B$). |
| **`RevisedModel.lean`** | Final Image Formation Model. | The synthesized underwater image formation model incorporating stable primitives. |

---

## Detailed File Documentation

### 1. `BasicIdentities.lean`
This file establishes the foundational library of numerically stable wrappers and proves their mathematical equivalence to their naive, potentially unstable counterparts.

**Core Mathematical Primitives:**
* **`expm1(x)`**: Corresponds to $\exp(x) - 1$. Avoids catastrophic cancellation when $x \approx 0$.
* **`log1p(x)`**: Corresponds to $\log(1 + x)$. 
* **`stableOneMinusExpNeg(x)`**: Stably computes $1 - \exp(-x)$ via $-\mathrm{expm1}(-x)$.
* **`stableMinusLogOneMinus(x)`**: Stably computes $-\log(1 - x)$ via $-\mathrm{log1p}(-x)$.
* **`stableLogRatio(a, b)`**: Stably computes $\log(a/b)$ when $a \approx b$ by rewriting it as $\log(1 + \frac{a-b}{b})$.

**The `stableExpDiff` Transformation:**
A recurring source of numerical instability is calculating $\exp(-a) - \exp(-b)$ when $a \approx b$. `stableExpDiff` factors out the smaller exponent to guarantee precision.

**Proof Process:**
The central theorem `exp_subexp` proves that:
$$\exp(-a)(1 - \exp(-(b - a))) = \exp(-a) - \exp(-b)$$

This is verified by expanding the multiplication:
$$\exp(-a) - \exp(-a)\exp(-(b - a))$$
Using the law of exponents $\exp(x)\exp(y) = \exp(x+y)$, the second term simplifies cleanly to:
$$\exp(-a - b + a) = \exp(-b)$$

The function `stableExpDiff` employs a piecewise check (`if a ≤ b`) to ensure the factored exponent is always negative, guarding against overflow.

### 2. `RTE.lean`
This module models the Radiative Transfer Equation for a specific directional light source. 

**Original Radiance Model:**
The classical formulation for the radiance $L$ at depth $z$ is:
$$L_{orig} = L_0 \exp(-\beta z) + \frac{L_s \exp(-K_d z \cos\theta)}{\beta - K_d \cos\theta} \left(1 - \exp(-(\beta - K_d \cos\theta)z)\right)$$

**Stable Form & Proof Process:**
The rightmost terms contain a hidden difference of exponentials that causes precision loss in simulation. The theorem `radiance_eq_stable` rewrites the attenuation factor:
$$\exp(-K_d z \cos\theta) \left(1 - \exp(-(\beta - K_d \cos\theta)z)\right)$$
By distributing the leading exponential, this expands to:
$$\exp(-K_d z \cos\theta) - \exp(-\beta z)$$
This matches the exact input signature required for our verified `stableExpDiff(a, b)` where $a = K_d z \cos\theta$ and $b = \beta z$. The stable radiance function is proven mathematically identical:
$$L_{stable} = L_0 \exp(-\beta z) + \frac{L_s}{\beta - K_d \cos\theta} \times \mathrm{stableExpDiff}(K_d z \cos\theta, \beta z)$$

### 3. `Backscatter.lean`
This file isolates the ambient backscatter component of underwater imagery.

**Original Backscatter Model:**
$$B(z) = B_\infty (1 - \exp(-\beta z))$$
where the veiling light limit $B_\infty$ is defined as $\frac{b E}{\beta}$.

**Stability Theorem:**
The theorem `backscatter_eq_stable` replaces the vulnerable $1 - \exp(-\beta z)$ operation with the verified `stableOneMinusExpNeg(\beta z)`.

### 4. `Wideband.lean`
Real-world underwater imaging is wideband (capturing a range of wavelengths $\lambda$), requiring integration across the spectrum.

**Direct Signal Attenuation ($\beta_D$):**
The wideband direct signal is formulated as an integral over the sensor band $[\lambda_1, \lambda_2]$:
$$D(z) = \int_{\lambda_1}^{\lambda_2} S_c(\lambda) \rho(\lambda) E(\lambda) \exp(-\beta(\lambda) z) \, d\lambda$$
The direct attenuation coefficient is derived as:
$$\beta_D = \frac{1}{dz} \log\left( \frac{D(z)}{D(z+dz)} \right)$$
Because $D(z) \approx D(z+dz)$ for small $dz$, the log quotient is unstable. `betaD_eq_stable` applies the logarithm quotient rule ($\log(A/B) = \log(A) - \log(B)$) for strict evaluation:
$$\beta_D = \frac{\log(D(z)) - \log(D(z+dz))}{dz}$$

**Backscatter Attenuation ($\beta_B$):**
The effective backscatter coefficient is dependent on a defined backscatter ratio $R_B$:
$$\beta_B = \frac{-\log(1 - R_B)}{z}$$
Using the theorem `betaB_eq_stable`, this is mapped strictly to the `stableMinusLogOneMinus(R_B)` definition.

### 5. `RevisedModel.lean`
This integrates the findings from wideband analysis and basic RTE derivation into the final robust underwater image formation model.

**Image Formation:**
$$I(z) = J \exp(-\beta_D z) + B_\infty (1 - \exp(-\beta_B z))$$
Where:
* $J$ is the signal intensity.
* $\beta_D$ is the wideband direct attenuation coefficient.
* $B_\infty$ is the wideband veiling light.
* $\beta_B$ is the wideband backscatter coefficient.

**Stability Theorem:**
`imageFormation_eq_stable` simply applies the ring normalizer and algebraic rewriting to substitute the naive expression with the robust `stableOneMinusExpNeg(\beta_B z)`.

---

## Building and Verification
To compile the proofs and verify all stability substitutions mathematically, ensure Lean 4 and Mathlib are installed.

1. Navigate to the project directory.
2. Run `lake build` to verify the proofs in the `MATH_157` namespace.
3. A successful build guarantees that every stable formulation is algebraically identical to the original continuous models.
