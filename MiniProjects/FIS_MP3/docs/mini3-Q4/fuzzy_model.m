function f = fuzzy_model(u, params, M)
    centers = params(1:M); % Centers
    sigmas = params(M+1:2*M); % Widths
    weights = params(2*M+1:end); % Weights

    % Calculate numerator and denominator
    numerator = 0;
    denominator = 0;
    for l = 1:M
        gaussian = exp(-((u - centers(l))^2) / (2 * sigmas(l)^2));
        numerator = numerator + weights(l) * gaussian;
        denominator = denominator + gaussian;
    end
    f = numerator / denominator;
end
