function [z, history] = interior_point_solver(c, A, b, z0, options)
%INTERIOR_POINT_SOLVER Solve the LP with a custom Interior Point iteration.
%
%   minimize    c' * z
%   subject to  A * z = b
%
% Inputs:
%   c       - objective vector
%   A       - equality-constraint matrix
%   b       - equality-constraint right-hand side
%   z0      - initial estimate
%   options - struct with optional fields:
%             mu0, rho, epsilon, max_outer_iterations,
%             max_inner_iterations, tolerance, alpha
%
% Outputs:
%   z       - final LP variable estimate
%   history - iteration diagnostics
%
% The update follows the algorithm specified for the original project:
%
%   X = diag(z) + epsilon*I
%
%   (A*X^2*A')*lambda = A*X^2*c - mu*A*X*e
%
%   p = X*e + (1/mu)*X^2*(A'*lambda - c)
%
%   z <- z + alpha*p
%
% With alpha = 1, the method uses pure Newton iteration.

    if nargin < 5
        options = struct();
    end

    options = set_default(options, 'mu0', 10);
    options = set_default(options, 'rho', 0.6);
    options = set_default(options, 'epsilon', 0.001);
    options = set_default(options, 'max_outer_iterations', 20);
    options = set_default(options, 'max_inner_iterations', 100);
    options = set_default(options, 'tolerance', 1e-9);
    options = set_default(options, 'alpha', 1);

    n = numel(z0);

    if size(A, 2) ~= n
        error('A must have one column per element of z0.');
    end
    if numel(c) ~= n
        error('c and z0 must have the same number of elements.');
    end
    if size(A, 1) ~= numel(b)
        error('The number of rows in A must match the length of b.');
    end

    z = z0(:);
    c = c(:);
    b = b(:);

    e = ones(n, 1);
    I = eye(n);

    mu = options.mu0;

    history.mu = zeros(options.max_outer_iterations, 1);
    history.inner_iterations = zeros(options.max_outer_iterations, 1);
    history.final_step_norm = zeros(options.max_outer_iterations, 1);
    history.total_newton_steps = 0;

    for outer = 1:options.max_outer_iterations
        if outer > 1
            mu = mu * options.rho;
        end

        history.mu(outer) = mu;
        step_norm = NaN;

        for inner = 1:options.max_inner_iterations
            X = diag(z) + options.epsilon * I;
            X2 = X * X;

            lhs = A * X2 * A';
            rhs = A * X2 * c - mu * A * X * e;

            % MATLAB's backslash operator solves the linear system without
            % explicitly forming a matrix inverse.
            lambda = lhs \ rhs;

            p = X * e + (1 / mu) * X2 * (A' * lambda - c);
            z = z + options.alpha * p;

            step_norm = norm(p, 2);
            history.total_newton_steps = ...
                history.total_newton_steps + 1;

            if step_norm < options.tolerance
                break;
            end
        end

        history.inner_iterations(outer) = inner;
        history.final_step_norm(outer) = step_norm;
    end

    history.outer_iterations = options.max_outer_iterations;
end

function options = set_default(options, field_name, default_value)
%SET_DEFAULT Add a default option only when the field is missing or empty.
    if ~isfield(options, field_name) || isempty(options.(field_name))
        options.(field_name) = default_value;
    end
end
