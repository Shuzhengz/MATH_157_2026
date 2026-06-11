# MATH 157 2026

Project for UCSD MATH 157, Spring 2026

## Project Background

### FishSense

The FishSense project was created at UC San Diego's Engineers for Exploration as an effort to bring the 
data collection of fish population analytics to citizen scientists. To accurate measure a fish under 
water, extensive equipment of exceeding high cost is needed, which is unrealistic in many circumstances. 
FishSense changes this by utilizing the parallax effect to take accurate measurements with a single 
commercially available under water camera and laser, which lowers the cost of entry exponentially.

However, this system still needs extensive human input as the laser needs to be manually calibrated with 
the camera. Secondly, although lasers under water forms a uniform gaussian distribution, harsh conditions 
means it is currently impossible to get an accurate labeling of the laser reliably, and so human labelers 
have to come in and verify or correct the labels manually. There is also a problem with extensive 
underwater ROV deployments where it would be impossible to calibrate the laser and thus cannot retrieve 
accurate readings.

### Monocular Depth

To fix this, the Monocular Depth project was created, in which we try to create a differentiable underwater 
renderer that can render physically accurate path-traced underwater scenes in the forward path, and using 
these median functions render an existing image under water to get the scene data, and thus the metric 
depth data, in which we can know the length of the fish. This will allow use to utilize essentially any 
under water image and retrieve accurate data without manual efforts, enabling anyone with a camera to be a 
citizen scientist.

### Accuracy and Performance Concerns

Currently, the state-of-the-art reverse-rendering software is Mitsuba 3, however this renderer presents a 
few issues with underwater images that all relate to the accuracy of IEEE 754 single-precision floating 
point 32 operations and the need for higher accuracy floating point 64 operations.

The current most accurate underwater color correction and image formation model is _Sea-thru_ from the 
University of Haifa, in which many light interaction functions involve exceedingly small floating point 
numbers. This can be seen in the equations from the supporting document,
 _A Revised Underwater Image Formation Model_.

We can see many cases where we involve very small values for $n$ in $e^n$, which we suspect would lead to 
numerical stability issues. Some initial tests were conducted where we found an around 0.1‰ chance where 
the difference in value were larger than 10% between fp32 and fp64 operations, which we deemed to be 
unacceptable as an image has millions of light paths, which all have hundreds of interactions. A small 
deviation in the value for our calculation would result a shift in the color it is representing, and also 
an compounding effect for the calculations follow, which is a large problem.

This is an issue with Mitsuba 3 as renderer uses Nvidia's OptiX platform for path-tracing, which has no 
support for the floating point 64 datatype outright. The CUDA implementation does have support, however it 
is exceedingly slow, and this is compounded by the fact that modern Nvidia GPUs in not only the consumer 
space, but also the workstation space have reduced fp64 throughput in favor of increasing lower accuracy 
fp16 and fp8 performance for machine learning use cases. For example, a RTX PRO 6000 Blackwell, the 
fastest Nvidia GPU available for purchase has a 64 times penalty in FP64 performance, which makes it on 
par with a Quadro K6000 from 2013. This means that we either have to figure out if there is some 
mathematical operations that we can do to solve this inaccuracy, or we have to build something else from 
the ground up to support AMD GPUs that do not have this same issue

## Project goals

The goal of this project is to find a way to mathematically reduce numerical stability issue of underwater 
image  formation functions and formulate the proof in LEAN, or a proof in LEAN that an adequate amount of  
techniques fail to do this, and therefore determine if it is possible to use floating point 32 for the  
project.

Because of limitations with available LEAN techniques, we will not be looking into the exact error bounds 
for FP32 and FP64 operations, but instead try to find a way to re-write the formation models so:

1. The functions are proven to be mathematically equivalent to the original
2. Contain as few places where numerical stability issues can occur
3. Optionally have good performance, although the verification of this is outside the scope for the project

Thus, we are here using the assumption that FP32 is sufficient for $x$ ≪ 1 when $x$ is not a power of $e$.

## Scope of work

Specifically, we try to prove that there is a way to rewrite the following functions so that they are 
stable:

### The Radiance Transfer Equation

$L(d;\xi;\lambda) = L_0(d_0;\xi;\lambda)e^{-\beta(\lambda)z} + \frac{L_*(d;\xi;\lambda)e^{-K_d(\lambda)
z\cos\theta}} {\beta(\lambda) - K_d(\lambda)\cos\theta} \left[ 1 - e^{-[\beta(\lambda) - K_d(\lambda)
\cos\theta]z} \right]$

### The Backscatter and Veling Light signals

Backscatter:

$B(z, \lambda) = \frac{b(\lambda)E(d, \lambda)}{\beta(\lambda)} \left( 1 - e^{-\beta(\lambda)z} \right)$

Veiling Light (Backscatter as $z \rArr \infty$)

$B^\infty(\lambda) = \frac{b(\lambda)E(d,\lambda)}{\beta(\lambda)}$

### Wideband Attenuation Coefficients

$\beta_c^D = \ln \left[ \frac{\int_{\lambda_1}^{\lambda_2} S_c(\lambda)\rho(\lambda)E(d,\lambda)e^{-\beta
(\lambda)z}d\lambda}{\int_ {\lambda_1}^{\lambda_2} S_c(\lambda)\rho(\lambda)E(d,\lambda)e^{-\beta(\lambda)
(z+\Delta z)}d\lambda} \right] / \Delta z$

### Wideband Backscatter Coefficient

$\beta_c^B = -\ln \left( 1 - \frac{\int_{\lambda_1}^{\lambda_2} S_c(\lambda) B^\infty(\lambda) (1 - e^
{-\beta(\lambda)z}) d\lambda} {\int_{\lambda_1}^{\lambda_2} B^\infty(\lambda) S_c(\lambda) d\lambda} 
\right) / z$


### Revised Image Formation Model

$I_c = J_c e^{-\beta_c^D (\mathbf{v}_D) \cdot z} + B_c^\infty \left( 1 - e^{-\beta_c^B (\mathbf{v}_B) 
\cdot z} \right)$

## Approach

### The Log Sum Exp trick

My first approach is using the classic log sum trick. Consider the following softmax function commonly
used in machine learning:

Softmax for a vector $x = (x_1, \dots, x_n)$ is:

$\text{softmax}(x_i) = \frac{e^{x_i}}{\sum_{j=1}^n e^{x_j}}$

If some $x_i$ values are very large, $e^{x_i}$ can overflow. If they are very negative, $e^{x_i}$ can 
underflow to zero. For example, directly computing $e^{1000}$ or $e^{1e-1000}$ is beyond the range of 
standard floating-point numbers.

However, Adding or subtracting the same constant from every element does not change 
the softmax result:

$\frac{e^{x_i}}{\sum_{j} e^{x_j}} = \frac{e^{x_i-c}}{\sum_{j} e^{x_j-c}}$

Therefore, if we have

$c = \max x_j$

Then the largest exponent becomes $e^0 = 1$, preventing overflow.

The stable softmax becomes:

$\text{softmax}(x_i) = \frac{e^{x_i - \max(x)}}{\sum_{j} e^{x_j - \max(x)}}$

However, I realized that this is not the correct approach, as we are mostly likely dealing with a 
cancellation problem rather than an overflow problem. For example, in backscatter we have $1 - e^{-\beta z}
$. The log-sum-exp path cannot apply here since there is no sum of exponentials inside a log. In RTE, we 
also have some sort of $e^{-a} - e^{-b}$, which are very close, and is prone to catastrophic 
cancellation to 0, therefore I decided to move on to the expm1 approach.

### `expm1`

Many modern programming languages, including CUDA, have a `expm1` function for very small numbers (in CUDA, 
this function for FP32 numbers is `expm1f()`). This function executes the operation `expm1(x)` $= e^x - 1$, 
and is accurate for $x$ ≪ 1. It does this by not directly computing the values, but instead by using an 
infinity taylor series that is exactly the value of $e^x - 1$.

i.e: $\sum_{i=0}^{k-1} \frac{x^{i+1}}{(i+1)!} = e^x - 1 \quad \text{as } k \to \infty.$

And therefore, by utilizing this, we can approach the project in generally 3 steps:

1. Prove that the taylor series for `expm1` is exact

2. Rewrite the identified formulation models using `expm1` so that they are stable

3. Prove that the stable version of the functions are equivalent to the original

This is possible because LEAN strictly enforces abstraction boundaries, which means that a theorem once 
proven is presumed to be true, and you can use it in a further proof that satisfies the condition, but the 
elements inside the theorems are contained and cannot be accessed by this further proof.

## Results

To a degree, I was able to rewrite the identified functions with `expm1` and other supporting definitions that stem from it, and using LEAN proved that the rewrites are the equivalent of original functions.

Specifically, the LEAN code can be found [in this GitHub repository](https://github.com/Shuzhengz/MATH_157_2026/tree/main/MATH_157), with an included README that explains every definition and the theorems that prove their equality.

### Limitations:

The project does not currently prove:

- FP32 error bounds
- FP64 error bounds
- IEEE-754 correctness

Those require a separate formal floating-point semantics and are outside the scope of this project

There are also lone $e^n$ inside the rewritten equation that I did not think would cause too much of an 
issue in terms of numerical stability, but may cause issues with accuracy. I did not have time to approach 
them, but again I do not believe they would cause as much issue.

#### Performance Concerns

Because `expm1` is based on an infinite taylor series, it may require significant compute resources to run. 
This may be very computationally expensive, and may be even slower than taking the 64 times performance 
penalty on modern Nvidia graphics cards.

However, this is beyond the scope of this project, and a future project benchmarking the performance 
implication is needed to answer this question

## Math Symbol Reference Table

| Variable | Description |
| :--- | :--- |
| $\lambda$ | wavelength |
| $a(\lambda)$ | beam absorption coefficient |
| $b(\lambda)$ | beam scattering coefficient |
| $\beta(\lambda)$ | beam attenuation coefficient: $a(\lambda) + b(\lambda)$ |
| $K_d(\lambda)$ | diffuse downwelling attenuation coefficient |
| $E(z, \lambda)$ | irradiance |
| $L(z, \lambda)$ | radiance |
| $Y$ | luminance |
| $S_c(\lambda)$ | sensor spectral response |
| $\rho(\lambda)$ | reflectance |
| $B^\infty(\lambda)$ | veiling light |
| $c$ | color channels R,G,B |
| $\beta_c$ | wideband attenuation coefficient |
| $B_c^\infty$ | wideband veiling light |
| $I_c$ | RGB image with attenuated signal |
| $J_c$ | RGB image with unattenuated signal |
| $d$ | depth (vertical range) |
| $z$ | range along LOS |
| $\xi$ | direction in 3-space |
| $B$ | backscattered light |
| $D$ | direct transmitted light |
| $F$ | forward scattered light |
| AOP | apparent optical properties |
| IOP | inherent optical properties |
| LOS | line of sight |
| RTE | radiance transfer equation |
| VSF | volume scattering function |

## References and Resources

#### Groundwork disclosure

PhD Student Christopher L. Crutchfield from the Electrical and Computer Engineering department at UCSD laid 
the groundwork with the FishSense project and some ideas for Monocular Depth.

#### LLM usage disclosure

Because this is an AI-open course, I utilized Google Gemini to generate some documentation for the project, 
as well as try to complete theorems that are too hard to tackle by hand and suggesting on intermediate 
approach methods to some problems. This would not have an impact on the results of this project as LEAN 
checks strictly on mathematical theorems. I also used LLM to do some busywork like converting an equation 
into LaTeX, markdown, etc.

No LLM was used to write this paper.

### References

Akkaynak, Derya, et al. “What Is the Space of Attenuation Coefficients in Underwater Computer Vision?” 
*Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR)*, 2017, pp. 
4931–4940. IEEE, https://doi.org/10.1109/CVPR.2017.68.

Akkaynak, Derya, and Tali Treibitz. “A Revised Underwater Image Formation Model.” *Proceedings of the IEEE/
CVF Conference on Computer Vision and Pattern Recognition (CVPR)*, 2018, pp. 6723–6732. IEEE,
https://doi.org/10.1109/CVPR.2018.00703.

Akkaynak, Derya, and Tali Treibitz. “Sea-Thru: A Method for Removing Water From Underwater Images.” 
*Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR)*, 2019, pp. 
1682–1691. IEEE, https://doi.org/10.1109/CVPR.2019.00178.

Nimier-David, Merlin, et al. “Mitsuba 2: A Retargetable Forward and Inverse Renderer.” *ACM Transactions on 
Graphics*, vol. 38, no. 6, 2019, article 203, pp. 1–17. Association for Computing Machinery,
https://doi.org/10.1145/3355089.3356498.
