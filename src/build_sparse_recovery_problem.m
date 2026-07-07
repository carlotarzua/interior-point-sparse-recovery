function [A0, A, b, c, z0, x_true] = build_sparse_recovery_problem()
%BUILD_SPARSE_RECOVERY_PROBLEM Construct the deterministic demo instance.
%
% Outputs:
%   A0     - 52-by-128 measurement matrix
%   A      - 52-by-256 LP constraint matrix [A0, -A0]
%   b      - measurement vector
%   c      - LP objective vector of ones
%   z0     - feasible nonnegative initial LP vector
%   x_true - 5-sparse ground-truth vector in R^128
%
% Provenance:
%   The deterministic matrix construction and sparse signal instance follow
%   the original MAT 387/487 course project setup. The portfolio repository
%   documents that provenance explicitly.

    %% Structured 128-by-128 matrix
    H2 = [1 -1; 1 1];
    H3 = [H2 -H2; H2 H2];
    H4 = [H3 -H3; H3 H3];
    H5 = [H4 -H4; H4 H4];
    H6 = [H5 -H5; H5 H5];
    H7 = [H6 -H6; H6 H6];
    H8 = [H7 -H7; H7 H7];

    rows = [ ...
        3, 4, 5, 6, 7, 8, 11, 12, 13, 19, 20, 26, 30, 33, 34, ...
        36, 37, 40, 41, 43, 47, 49, 53, 54, 55, 56, 57, 58, 60, ...
        61, 62, 64, 65, 69, 72, 75, 80, 81, 82, 84, 87, 88, 91, ...
        92, 93, 94, 96, 97, 100, 106, 107, 109 ...
    ];

    A0 = H8(rows, :);

    %% Ground-truth sparse vector
    x_true = zeros(128, 1);
    locations = [109, 107, 55, 30, 43];
    values = [3.2, -4.3, 3.2, -4.3, 3.2];
    x_true(locations) = values;

    b = A0 * x_true;

    %% Feasible initial signed estimate
    % Solve (A0*A0') y = b, then x_initial = A0' y.
    % This avoids forming an explicit inverse.
    gram_matrix = A0 * A0';
    y = gram_matrix \ b;
    x_initial = A0' * y;

    feasibility_error = norm(A0 * x_initial - b, 2);
    if feasibility_error > 0.01
        warning('Initial estimate feasibility error is %.6g.', ...
            feasibility_error);
    end

    %% Convert signed variables to nonnegative LP variables
    A = [A0, -A0];
    c = ones(size(A, 2), 1);

    x_plus = max(x_initial, 0);
    x_minus = max(-x_initial, 0);
    z0 = [x_plus; x_minus];

    lp_feasibility_error = norm(A * z0 - b, 2);
    if lp_feasibility_error > 0.01
        warning('LP initial vector feasibility error is %.6g.', ...
            lp_feasibility_error);
    end
end
