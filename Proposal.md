# UCSD MATH 157 Final Project Proposal

Tom Zhang

## Project Background

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

To fix this, FishSense Monocular Depth was created, in which we try to create a differentiable underwater 
renderer that can render physically accurate path-traced underwater scenes in the forward path, and using 
these median functions render an existing image under water to get the scene data, and thus the metric 
depth data, in which we can know the length of the fish. This will allow use to utilize essentially any 
under water image and retrieve accurate data without manual efforts, enabling anyone with a camera to be a 
citizen scientist.

Currently, the state-of-the-art reverse-rendering software is Mitsuba 3, however this renderer presents a 
few issues with underwater images that all relate to the accuracy of IEEE 754 single-precision floating 
point 32 operations and the need for higher accuracy floating point 64 operations.

The current most accurate underwater color correction and image formation model is _Sea-thru_ from the 
University of Haifa, in which many light interaction functions involve exceedingly small floating point 
numbers. Examples from the supporting documentation _A Revised Underwater Image Formation Model_ include:

The Back-scatter Function: $B(z, \lambda) = \frac{b(\lambda)E(d, \lambda)}{\beta(\lambda)} \left( 1 - e^
{-\beta(\lambda)z} \right)$

The Radiance Transfer Equation: $L(d;\xi;\lambda) = L_0(d_0;\xi;\lambda)e^{-\beta(\lambda)z} + \frac{L_*(d;
\xi;\lambda)e^{-K_d(\lambda)z\cos\theta}}{\beta(\lambda) - K_d(\lambda)\cos\theta} \left[ 1 - e^{-[\beta
(\lambda) - K_d(\lambda)\cos\theta]z} \right]$

The image formation model itself: $I_c = J_c e^{-\beta_c^D (\mathbf{v}_D) \cdot z} + B_c^\infty \left( 1 - 
e^{-\beta_c^B (\mathbf{v}_B) \cdot z} \right)$

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
fastest Nvidia GPU avaliable for purchase has a 64 times penalty in FP64 performance, which makes it on 
par with a Quadro K6000 from 2013. This means that we either have to figure out if there is some 
mathematical operations that we can do to solve this inaccuracy, or we have to build something else from 
the ground up to support AMD GPUs that do not have this same issue

## Scope of Work

The goal of this project is to find a way to mathematically reduce the inaccuracy of underwater image 
formation functions and formulate the proof in LEAN, or a proof in LEAN that an adequate amount of 
techniques fail to do this, and therefore determine if it is possible to use floating point 32 for the 
project.

The coding part of the project would be the LEAN formalization for a method that works, or the proof that 
current methods fail. The documentation part of the project would be to simply document formally the 
mathematical techniques and the LEAN code itself.

## Learning Goals

I chose this project because it is tightly related to my research, and it would help me in determining 
next steps as I hope to use this project for my Master's thesis. I hope to apply the lean techniques used 
and also learn about math techniques as I do research on the project.

## Works Cited:

D. Akkaynak and T. Treibitz. A revised underwater image formation model. In Proc. IEEE CVPR, 2018.

Merlin Nimier-David, Delio Vicini, Tizian Zeltner, and Wenzel Jakob. 2019. Mitsuba 2: a retargetable 
forward and inverse renderer. ACM Trans. Graph. 38, 6, Article 203 (December 2019), 17 pages.

