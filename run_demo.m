%% Interior Point Method for Sparse Recovery
% Portfolio demo
%
% Runs a custom Interior Point Method to recover a 5-sparse vector in R^128
% from 52 linear measurements.
%
% The core solver does not call linprog.

clear;
close all;
clc;

repo_root = fileparts(mfilename('fullpath'));
addpath(fullfile(repo_root, 'src'));

results_dir = fullfile(repo_root, 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

%% Build deterministic problem
[A0, A, b, c, z0, x_true] = build_sparse_recovery_problem();

%% Solver options
options.mu0 = 10;
options.rho = 0.6;
options.epsilon = 0.001;
options.max_outer_iterations = 20;
options.max_inner_iterations = 100;
options.tolerance = 1e-9;
options.alpha = 1;

%% Solve
tic;
[z_opt, history] = interior_point_solver(c, A, b, z0, options);
elapsed_seconds = toc;

%% Recover signed vector
half_n = size(A, 2) / 2;

% Preserve the thresholding logic used in the original project:
% threshold the nonnegative LP variables before recombining x+ - x-.
threshold = 0.01;
z_thresholded = z_opt;
z_thresholded(abs(z_thresholded) < threshold) = 0;

x_recovered = z_thresholded(1:half_n) ...
            - z_thresholded(half_n + 1:end);

%% Evaluate
metrics = recovery_metrics(x_true, x_recovered);

fprintf('\nInterior Point Sparse Recovery\n');
fprintf('==============================\n');
fprintf('Signal dimension:          %d\n', numel(x_true));
fprintf('Measurements:              %d\n', size(A0, 1));
fprintf('True nonzero entries:      %d\n', metrics.true_support_size);
fprintf('Recovered nonzero entries: %d\n', metrics.recovered_support_size);
fprintf('Correct support entries:   %d / %d\n', ...
    metrics.correct_support_entries, metrics.true_support_size);
fprintf('L2 recovery error:         %.9f\n', metrics.l2_error);
fprintf('Relative L2 error:         %.6f%%\n', ...
    100 * metrics.relative_l2_error);
fprintf('Maximum absolute error:    %.9f\n', metrics.max_absolute_error);
fprintf('Outer iterations:          %d\n', history.outer_iterations);
fprintf('Newton steps:              %d\n', history.total_newton_steps);
fprintf('Elapsed time:              %.6f seconds\n\n', elapsed_seconds);

%% Display recovered nonzero entries
support = union(find(abs(x_true) > 0), find(abs(x_recovered) > 0));
result_table = table( ...
    support, ...
    x_true(support), ...
    x_recovered(support), ...
    abs(x_true(support) - x_recovered(support)), ...
    'VariableNames', {'Index', 'TrueValue', 'RecoveredValue', 'AbsoluteError'} ...
);

disp(result_table);

writetable(result_table, fullfile(results_dir, 'latest_nonzero_entries.csv'));

%% Save metrics
metrics_file = fopen(fullfile(results_dir, 'latest_metrics.txt'), 'w');
fprintf(metrics_file, 'signal_dimension=%d\n', numel(x_true));
fprintf(metrics_file, 'measurements=%d\n', size(A0, 1));
fprintf(metrics_file, 'true_support_size=%d\n', metrics.true_support_size);
fprintf(metrics_file, 'recovered_support_size=%d\n', metrics.recovered_support_size);
fprintf(metrics_file, 'correct_support_entries=%d\n', metrics.correct_support_entries);
fprintf(metrics_file, 'l2_error=%.12f\n', metrics.l2_error);
fprintf(metrics_file, 'relative_l2_error=%.12f\n', metrics.relative_l2_error);
fprintf(metrics_file, 'max_absolute_error=%.12f\n', metrics.max_absolute_error);
fprintf(metrics_file, 'outer_iterations=%d\n', history.outer_iterations);
fprintf(metrics_file, 'total_newton_steps=%d\n', history.total_newton_steps);
fprintf(metrics_file, 'elapsed_seconds=%.12f\n', elapsed_seconds);
fclose(metrics_file);

%% Plot true vs recovered vector
fig1 = figure('Visible', 'off');
stem(1:numel(x_true), x_true, 'DisplayName', 'True vector');
hold on;
stem(1:numel(x_recovered), x_recovered, ...
    'DisplayName', 'Recovered vector');
hold off;
grid on;
xlabel('Vector index');
ylabel('Value');
title('True vs Recovered Sparse Vector');
legend('Location', 'best');
exportgraphics(fig1, ...
    fullfile(results_dir, 'latest_recovery_comparison.png'), ...
    'Resolution', 200);
close(fig1);

%% Plot absolute error
fig2 = figure('Visible', 'off');
stem(1:numel(x_true), abs(x_true - x_recovered));
grid on;
xlabel('Vector index');
ylabel('Absolute error');
title('Absolute Recovery Error');
exportgraphics(fig2, ...
    fullfile(results_dir, 'latest_absolute_error.png'), ...
    'Resolution', 200);
close(fig2);

fprintf('Saved fresh results under: %s\n', results_dir);
