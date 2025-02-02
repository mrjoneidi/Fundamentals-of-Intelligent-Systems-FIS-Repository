function error = residuals(params, u_values, g_values, M)
    N = length(u_values);
    error = zeros(N, 1);
    for i = 1:N
        u = u_values(i);
        g = g_values(i);
        f_approx = fuzzy_model(u, params, M);
        error(i) = f_approx - g; % Residual
    end
end