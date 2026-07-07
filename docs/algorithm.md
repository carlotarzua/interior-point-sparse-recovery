# Algorithm

## 1. Sparse recovery objective

The original objective is

\[
\min_x \|x\|_1
\quad \text{subject to} \quad
A_0x=b.
\]

The vector \(x\) can contain positive and negative values, so decompose it as

\[
x=x^+-x^-,
\qquad
x^+,x^- \ge 0.
\]

Define

\[
z=
\begin{bmatrix}
x^+\\
x^-
\end{bmatrix},
\qquad
A=
\begin{bmatrix}
A_0 & -A_0
\end{bmatrix},
\qquad
c=\mathbf{1}.
\]

Then solve

\[
\min_z c^Tz
\quad \text{subject to} \quad
Az=b.
\]

## 2. Interior Point iteration

The implementation uses these parameters:

- initial barrier parameter: \(\mu_0=10\)
- barrier reduction factor: \(\rho=0.6\)
- diagonal adjustment: \(\epsilon=0.001\)
- outer iterations: 20
- maximum inner Newton iterations: 100
- convergence tolerance: \(10^{-9}\)
- step size: \(\alpha=1\)

For each outer iteration, reduce the barrier parameter after the first pass:

\[
\mu \leftarrow \rho\mu.
\]

For each inner iteration:

### Construct the adjusted diagonal matrix

\[
X=\operatorname{diag}(z)+\epsilon I.
\]

The \(\epsilon I\) term is part of the specified method and helps avoid degeneracy associated with the matrix system.

### Solve for the multiplier estimate

\[
(AX^2A^T)\lambda
=
AX^2c-\mu AXe.
\]

The MATLAB implementation uses the backslash operator:

```matlab
lambda = lhs \ rhs;
```

This solves the linear system without explicitly computing an inverse.

### Compute the Newton direction

\[
p
=
Xe+\frac{1}{\mu}X^2(A^T\lambda-c).
\]

### Update

\[
z \leftarrow z+\alpha p.
\]

The project uses

\[
\alpha=1,
\]

so the update is a pure Newton step.

### Inner stopping condition

Stop the inner loop when

\[
\|p\|_2 < 10^{-9}.
\]

## 3. Recover the signed vector

After optimization, split the 256-dimensional LP variable into two 128-dimensional halves:

\[
x_{\text{recovered}}
=
z_{1:128}
-
z_{129:256}.
\]

The demo preserves the original project's thresholding behavior by setting LP-variable entries with magnitude below `0.01` to zero before recombining the positive and negative halves.

## 4. Evaluation

The repository reports both:

- **support recovery:** whether the correct nonzero indices were found,
- **numerical recovery:** L2 error, relative L2 error, and maximum absolute error.

This separation matters because a sparse-recovery method can identify the right locations while still estimating their values poorly, or vice versa.
