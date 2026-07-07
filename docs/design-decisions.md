# Design Decisions

This document explains the changes made when transforming the original course submission into a portfolio-quality repository.

## Modular structure

The original submission was a single MATLAB program. The portfolio version separates responsibilities:

- `build_sparse_recovery_problem.m` constructs the deterministic instance.
- `interior_point_solver.m` contains the optimization routine.
- `recovery_metrics.m` evaluates the solution.
- `run_demo.m` orchestrates the experiment and exports results.

This makes the numerical method easier to review, test, and discuss in an interview.

## Linear solves instead of explicit inverses

The refactored initialization solves

```matlab
y = gram_matrix \ b;
x_initial = A0' * y;
```

instead of explicitly computing `inv(gram_matrix)`.

This is a more standard numerical-computing practice because it avoids materializing an inverse when the actual goal is to solve a linear system.

## No black-box LP call

The core optimization routine directly implements the Interior Point iteration. It does not delegate the solution to `linprog`.

That distinction is central to the portfolio value of the project: the repository demonstrates implementation of the numerical method itself.

## Transparent provenance

The deterministic matrix construction and project specification originated in a university course project. The repository says so explicitly rather than presenting all setup code as independently invented.

The portfolio claim is narrower and stronger:

> Implemented the Interior Point iteration, refactored the project into modular MATLAB code, and evaluated sparse-recovery accuracy quantitatively.

## Reported versus fresh results

The images and metrics committed under `results/` correspond to the original submitted run.

Running `run_demo.m` creates fresh files prefixed with `latest_`. Runtime can vary by machine and MATLAB environment.

## Thresholding

The demo keeps the original project's threshold value of `0.01` and applies it to the 256-dimensional LP variable before reconstructing the signed vector.

Keeping this choice explicit makes the evaluation reproducible and avoids silently changing the reported method.
