# Interior Point Method for Sparse Recovery

![MATLAB](https://img.shields.io/badge/MATLAB-Numerical%20Computing-orange?style=for-the-badge)
![Optimization](https://img.shields.io/badge/Optimization-Linear%20Programming-blue?style=for-the-badge)
![Numerical Methods](https://img.shields.io/badge/Numerical%20Methods-Newton%20Iteration-6f42c1?style=for-the-badge)

A MATLAB implementation of an **Interior Point Method** for recovering a sparse vector from an underdetermined linear system through **L1-norm minimization**.

This repository is a portfolio-focused refactoring of a university numerical optimization project. It emphasizes the solver implementation, numerical reasoning, reproducible results, and engineering decisions behind the method.

<p align="center">
  <img src="results/recovery_comparison.png" alt="True and recovered sparse vectors" width="900">
</p>

## Problem

Given a measurement matrix \(A_0 \in \mathbb{R}^{52 \times 128}\) and observations

\[
b = A_0 x,
\]

recover an unknown **5-sparse** vector \(x \in \mathbb{R}^{128}\).

The sparse recovery problem is posed as

\[
\min_x \|x\|_1
\quad \text{subject to} \quad
A_0x=b.
\]

Because the original vector may contain positive and negative values, write

\[
x = x^+ - x^-,
\qquad
x^+,x^- \ge 0.
\]

Define

\[
z =
\begin{bmatrix}
x^+ \\
x^-
\end{bmatrix},
\qquad
A =
\begin{bmatrix}
A_0 & -A_0
\end{bmatrix}.
\]

The optimization problem becomes the linear program

\[
\min_z \mathbf{1}^Tz
\quad \text{subject to} \quad
Az=b.
\]

The custom solver then applies an Interior Point iteration with Newton-style updates. The core optimization routine does **not** call MATLAB's `linprog`.

## Results

The reported run recovered the correct five nonzero locations and closely matched their values.

| Metric | Reported result |
|---|---:|
| Signal dimension | 128 |
| Measurements | 52 |
| True nonzero entries | 5 |
| Correct support entries | **5 / 5** |
| L2 recovery error | **0.004598** |
| Relative L2 error | **0.055880%** |
| Maximum absolute error | **0.002500** |
| Outer iterations | 20 |
| Sample runtime | 0.257777 s |

> Runtime is from the original MATLAB run and is machine-dependent. Error metrics above are computed from the thresholded recovered vector shown in that run.

### Recovered nonzero entries

| Index | True value | Recovered value | Absolute error |
|---:|---:|---:|---:|
| 30 | -4.3000 | -4.2975 | 0.0025 |
| 43 | 3.2000 | 3.1982 | 0.0018 |
| 55 | 3.2000 | 3.1979 | 0.0021 |
| 107 | -4.3000 | -4.2982 | 0.0018 |
| 109 | 3.2000 | 3.1980 | 0.0020 |

<p align="center">
  <img src="results/absolute_error.png" alt="Absolute error at recovered nonzero indices" width="760">
</p>

## Repository structure

```text
interior-point-sparse-recovery/
├── README.md
├── run_demo.m
├── src/
│   ├── build_sparse_recovery_problem.m
│   ├── interior_point_solver.m
│   └── recovery_metrics.m
├── results/
│   ├── recovery_comparison.png
│   ├── absolute_error.png
│   ├── recovered_nonzero_entries.csv
│   ├── reported_metrics.json
│   └── sample_output.txt
├── docs/
│   ├── algorithm.md
│   ├── design-decisions.md
│   └── provenance.md
├── NOTICE.md
└── .gitignore
```

## How the solver works

For each outer iteration, the barrier parameter is reduced:

\[
\mu \leftarrow \rho\mu.
\]

For each inner Newton iteration:

1. Construct the adjusted diagonal matrix

   \[
   X = \operatorname{diag}(z) + \epsilon I.
   \]

2. Solve for \(\lambda\):

   \[
   (AX^2A^T)\lambda
   =
   AX^2c - \mu AXe.
   \]

3. Compute the Newton direction:

   \[
   p
   =
   Xe + \frac{1}{\mu}X^2(A^T\lambda-c).
   \]

4. Update the estimate using pure Newton iteration:

   \[
   z \leftarrow z + p.
   \]

5. Stop the inner iteration when

   \[
   \|p\|_2 < 10^{-9}.
   \]

See [`docs/algorithm.md`](docs/algorithm.md) for more detail.

## Run locally

### Requirements

- MATLAB
- No Optimization Toolbox is required for the custom solver

### Run

Clone the repository and execute:

```matlab
run_demo
```

The script:

- builds the deterministic sparse recovery problem,
- runs the custom Interior Point solver,
- reconstructs the signed 128-dimensional vector,
- computes recovery metrics,
- prints a compact result table,
- saves fresh plots and result files under `results/`.

## Engineering decisions

This portfolio version intentionally improves the original single-file submission:

- **Modular solver design:** problem construction, optimization, and metrics are separated.
- **No explicit matrix inverse in the refactored setup:** linear systems use MATLAB's backslash operator.
- **Reproducible problem instance:** the sparse signal and measurement construction are deterministic.
- **Numerical safeguards:** the diagonal matrix uses \(\epsilon I\) regularization as specified by the method.
- **Transparent evaluation:** support recovery and numerical error are reported separately.
- **No black-box LP solver:** the Interior Point iteration is implemented directly.

## Technical skills demonstrated

- MATLAB
- Linear programming
- Convex optimization
- Numerical linear algebra
- Newton methods
- Sparse signal recovery
- Algorithm implementation from mathematical pseudocode
- Numerical error analysis
- Technical documentation

## Portfolio context

This project demonstrates the intersection of **mathematics and computer science**: reformulating a sparse recovery objective as a linear program, implementing a numerical optimization method, and evaluating the solution quantitatively.

For software engineering, machine learning, data science, quantitative, and applied mathematics roles, the most relevant aspects are the direct algorithm implementation, matrix computation, numerical stability considerations, and measurable validation of results.

## Attribution and provenance

This repository is based on a university MAT 387/487 course project. The original course materials supplied the project statement, deterministic problem setup conventions, and algorithm specification. The Interior Point iteration was implemented for the project and then reorganized here into a recruiter-facing portfolio repository.

See [`docs/provenance.md`](docs/provenance.md) and [`NOTICE.md`](NOTICE.md) for a precise statement of scope and attribution.
