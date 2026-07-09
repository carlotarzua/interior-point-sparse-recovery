# Design Decisions

This document explains the main implementation and refactoring choices used in the repository.

---

## Modular Structure

The original submission was a single MATLAB program. The current repository separates responsibilities across focused files:

| File | Responsibility |
|---|---|
| `build_sparse_recovery_problem.m` | Constructs the deterministic problem instance |
| `interior_point_solver.m` | Implements the optimization routine |
| `recovery_metrics.m` | Evaluates the recovered solution |
| `run_demo.m` | Orchestrates the experiment and exports results |

This structure improves readability and makes each part of the numerical method easier to inspect independently.

---

## Linear Solves Instead of Explicit Inverses

The refactored initialization solves

```matlab
y = gram_matrix \ b;
x_initial = A0' * y;
```

instead of explicitly computing

```matlab
inv(gram_matrix)
```

when the actual objective is to solve a linear system.

Using MATLAB's backslash operator is a more standard numerical-computing approach because it avoids forming an explicit inverse unnecessarily.

---

## No Black-Box LP Call

The core optimization routine directly implements the Interior Point iteration.

It does **not** delegate the problem to MATLAB's `linprog`.

This keeps the focus on the numerical method itself:

- barrier-parameter updates,
- matrix construction,
- multiplier-system solution,
- Newton-direction computation,
- iterative updates,
- convergence checks.

---

## Reproducible Problem Instance

The problem instance is deterministic.

The repository fixes:

- the measurement-matrix construction,
- the sparse-vector locations,
- the sparse-vector values,
- the algorithm parameters.

This makes the reported experiment reproducible across runs, aside from machine-dependent runtime.

---

## Transparent Provenance

The deterministic matrix construction and project specification originated in a university course project.

The repository states this explicitly rather than presenting all setup code as independently invented.

The work represented here includes:

- implementation of the Interior Point iteration,
- modular refactoring of the MATLAB code,
- quantitative recovery evaluation,
- result visualizations,
- technical documentation.

For more detail, see [`provenance.md`](provenance.md) and [`../NOTICE.md`](../NOTICE.md).

---

## Reported Results vs. Fresh Results

The images and metrics committed under `results/` correspond to the reported MATLAB run used for the project results.

Running

```matlab
run_demo
```

creates fresh files prefixed with `latest_`, including:

```text
latest_recovery_comparison.png
latest_absolute_error.png
latest_nonzero_entries.csv
latest_metrics.txt
```

Runtime may vary by machine and MATLAB environment.

---

## Thresholding

The demo preserves the original project's threshold value of

```text
0.01
```

and applies it to the 256-dimensional LP variable before reconstructing the signed vector.

This choice is documented explicitly so the recovery process remains reproducible and the reported evaluation does not silently change.

---

## Numerical Regularization

The solver constructs

$$
X = \operatorname{diag}(z) + \epsilon I
$$

with

$$
\epsilon = 0.001.
$$

This diagonal adjustment follows the specified method and helps reduce numerical degeneracy in the associated matrix system.

---

## Evaluation Strategy

The repository separates:

- **support recovery** — whether the correct nonzero indices were found,
- **numerical accuracy** — how close the recovered values are to the true values.

This is more informative than reporting only a visual comparison or a single error metric.

---

## Related Files

- [`algorithm.md`](algorithm.md) — mathematical formulation and solver steps
- [`../src/interior_point_solver.m`](../src/interior_point_solver.m) — solver implementation
- [`../src/recovery_metrics.m`](../src/recovery_metrics.m) — evaluation metrics
- [`../README.md`](../README.md) — project overview and results
