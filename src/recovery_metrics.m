function metrics = recovery_metrics(x_true, x_recovered)
%RECOVERY_METRICS Compute numerical and support-recovery metrics.

    x_true = x_true(:);
    x_recovered = x_recovered(:);

    if numel(x_true) ~= numel(x_recovered)
        error('x_true and x_recovered must have the same length.');
    end

    error_vector = x_recovered - x_true;

    true_support = find(abs(x_true) > 0);
    recovered_support = find(abs(x_recovered) > 0);

    metrics.l2_error = norm(error_vector, 2);
    metrics.relative_l2_error = ...
        metrics.l2_error / max(norm(x_true, 2), eps);
    metrics.max_absolute_error = max(abs(error_vector));

    metrics.true_support_size = numel(true_support);
    metrics.recovered_support_size = numel(recovered_support);
    metrics.correct_support_entries = ...
        numel(intersect(true_support, recovered_support));
end
