# Algorithm

This document describes the sparse-recovery formulation and the Interior Point iteration implemented in the repository.

---

## 1. Sparse Recovery Objective

The original optimization problem is:

```math
\min_x \|x\|_1
\quad \text{subject to} \quad
A_0x = b.
```

The vector $x$ may contain both positive and negative values, so decompose it as:

```math
x = x^+ - x^-,
\qquad
x^+, x^- \ge 0.
```

Define:

```math
z =
\begin{bmatrix}
x^+ \\
x^-
\end{bmatrix},
\qquad
A =
\begin{bmatrix}
A_0 & -A_0
\end{bmatrix},
\qquad
c = \mathbf{1}.
```

The sparse-recovery problem becomes the linear program:

```math
\min_z c^Tz
\quad \text{subject to} \quad
Az = b.
```

---

## 2. Interior Point Iteration

The implementation uses the following parameters:

| Parameter | Meaning | Value |
|---|---|---:|
| $\mu_0$ | Initial barrier parameter | 10 |
| $\rho$ | Barrier reduction factor | 0.6 |
| $\epsilon$ | Diagonal adjustment | 0.001 |
| — | Outer iterations | 20 |
| — | Maximum inner Newton iterations | 100 |
| — | Convergence tolerance | $10^{-9}$ |
| $\alpha$ | Step size | 1 |

For each outer iteration, the barrier parameter is reduced after the first pass:

```math
\mu \leftarrow \rho\mu.
```

Each inner iteration performs the following steps.

### Step 1: Construct the Adjusted Diagonal Matrix

```math
X = \mathrm{diag}(z) + \epsilon I.
```

The $\epsilon I$ term follows the specified method and helps reduce degeneracy in the matrix system.

### Step 2: Solve for the Multiplier Estimate

Solve:

```math
(AX^2A^T)\lambda = AX^2c - \mu AXe.
```

The MATLAB implementation uses the backslash operator:

```matlab
lambda = lhs \ rhs;
```

This solves the linear system without explicitly computing a matrix inverse.

### Step 3: Compute the Newton Direction

```math
p = Xe + \frac{1}{\mu}X^2(A^T\lambda - c).
```

### Step 4: Update the Estimate

```math
z \leftarrow z + \alpha p.
```

The implementation uses:

```math
\alpha = 1,
```

so the update is a pure Newton step.

### Step 5: Check the Stopping Condition

The inner loop stops when:

```math
\|p\|_2 < 10^{-9}.
```

---

## 3. Recover the Signed Vector

After optimization, the 256-dimensional LP variable is split into two 128-dimensional halves:

```math
x_{\mathrm{recovered}} = z_{1:128} - z_{129:256}.
```

Before recombining the positive and negative halves, the demo preserves the original project's thresholding behavior by setting LP-variable entries with magnitude below `0.01` to zero.

---

## 4. Evaluation

The repository reports two complementary types of evaluation.

### Support Recovery

Measures whether the correct nonzero indices were identified.

### Numerical Recovery

Measures how closely the recovered values match the true values using:

- L2 recovery error,
- relative L2 error,
- maximum absolute error.

These metrics are reported separately because a sparse-recovery method may identify the correct locations while still estimating their values inaccurately, or estimate values closely while missing part of the true support.

---

## Related Files

- [`../src/interior_point_solver.m`](../src/interior_point_solver.m) — custom Interior Point solver
- [`../src/recovery_metrics.m`](../src/recovery_metrics.m) — numerical evaluation
- [`design-decisions.md`](design-decisions.md) — implementation and refactoring choices
- [`../README.md`](../README.md) — project overview and results
