# Mathematical Function Reference: Original vs. Stable Formulations

## 1. Core Primitives (`BasicIdentities.lean`)

These are the fundamental building blocks used to eliminate precision loss in exponential and logarithmic operations.

| Concept | Original Formulation | Stable Formulation | Stable Lean Function |
| :--- | :--- | :--- | :--- |
| **Exponential Decay Difference** | $1 - e^{-x}$ | $-\mathrm{expm1}(-x)$ | `stableOneMinusExpNeg(x)` |
| **Logarithmic Addition** | $\log(1 + x)$ | $\mathrm{log1p}(x)$ | `stableLog1p(x)` |
| **Logarithmic Subtraction** | $-\log(1 - x)$ | $-\mathrm{log1p}(-x)$ | `stableMinusLogOneMinus(x)` |
| **Ratio Logarithm** ($a \approx b$) | $\log(\frac{a}{b})$ | $\mathrm{log1p}(\frac{a - b}{b})$ | `stableLogRatio(a, b)` |
| **Difference of Exponentials** ($a \le b$) | $e^{-a} - e^{-b}$ | $e^{-a} \times \mathrm{stableOneMinusExpNeg}(b-a)$ | `stableExpDiff(a, b)` |

> **Note on `stableExpDiff`:** The Lean implementation uses a piecewise check. If $a > b$, it factors out $e^{-b}$ instead and negates the result, ensuring the argument passed to $\mathrm{expm1}$ is always strictly negative to prevent overflow.

---

## 2. Radiative Transfer Equation (`RTE.lean`)

Models the radiance $L$ at depth $z$ for a directional light source, factoring out the hidden difference of exponentials that causes instability at shallow depths or low attenuation.

| Version | Mathematical Equation | Lean Function |
| :--- | :--- | :--- |
| **Original** | $L_0 e^{-\beta z} + \frac{L_s e^{-K_d z \cos\theta}}{\beta - K_d \cos\theta} \left(1 - e^{-(\beta - K_d \cos\theta)z}\right)$ | `radianceOriginal` |
| **Stable** | $L_0 e^{-\beta z} + \frac{L_s}{\beta - K_d \cos\theta} \times \mathrm{stableExpDiff}(K_d z \cos\theta, \beta z)$ | `radianceStable` |

---

## 3. Backscatter Model (`Backscatter.lean`)

Isolates the ambient backscatter component $B(z)$ given a veiling light limit $B_\infty = \frac{b E}{\beta}$.

| Version | Mathematical Equation | Lean Function |
| :--- | :--- | :--- |
| **Original** | $\frac{b E}{\beta} (1 - e^{-\beta z})$ | `backscatterOriginal` |
| **Stable** | $\frac{b E}{\beta} \times \mathrm{stableOneMinusExpNeg}(\beta z)$ | `backscatterStable` |

---

## 4. Wideband Attenuation (`Wideband.lean`)

Addresses the calculation of wideband direct attenuation ($\beta_D$) and backscatter attenuation ($\beta_B$) coefficients derived from spectral integration. 

| Concept | Original Formulation | Stable Formulation | Lean Functions |
| :--- | :--- | :--- | :--- |
| **Direct Attenuation** ($\beta_D$) | $\frac{1}{dz} \log\left( \frac{D(z)}{D(z+dz)} \right)$| $\frac{\mathrm{stableLogRatio}(D(z), D(z+dz))}{dz}$ | `betaDOriginal` <br> `betaDStable` |
| **Backscatter Coefficient** ($\beta_B$) | $\frac{-\log(1 - R_B)}{z}$| $\frac{\mathrm{stableMinusLogOneMinus}(R_B)}{z}$ | `betaBOriginal` <br> `betaBStable` |

> **Note:** For $\beta_D$, evaluating the exact mathematical quotient $D(z) / D(z+dz)$ first, or subtracting their independent logarithms, causes catastrophic cancellation because the values are nearly identical for small $dz$. The stable form uses `stableLogRatio` (which wraps $\mathrm{log1p}$) to maintain the precision of their exact difference.

---

## 5. Final Image Formation Model (`RevisedModel.lean`)

The synthesized model calculating the final intensity $I(z)$ captured by the sensor, leveraging the wideband coefficients.

| Version | Mathematical Equation | Lean Function |
| :--- | :--- | :--- |
| **Original** | $J e^{-\beta_D z} + B_\infty (1 - e^{-\beta_B z})$ | `imageFormationOriginal` |
| **Stable** | $J e^{-\beta_D z} + B_\infty \times \mathrm{stableOneMinusExpNeg}(\beta_B z)$ | `imageFormationStable` |
