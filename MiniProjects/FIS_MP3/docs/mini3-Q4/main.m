% Main script: RLS and Desired vs. Identified Output Plot

% Define constants
M = 6; % Number of membership functions (fuzzy rules)
num_train = 150; % Number of training data points
total_data_points = 500; % Total number of data points
lambda = 0.99; % Forgetting factor for RLS
initial_weight_variance = 100; % Initial variance for covariance matrix

% Generate data
u_values = linspace(0, 1, total_data_points); % Generate total data points
g_values = arrayfun(@g_u, u_values); % Compute desired output g[u]

% Split data into training and testing sets
train_indices = linspace(1, total_data_points, num_train);
test_indices = setdiff(1:total_data_points, round(train_indices));

% Training data
train_u_values = u_values(round(train_indices));
train_g_values = g_values(round(train_indices));

% Testing data
test_u_values = u_values(test_indices);
test_g_values = g_values(test_indices);

% Initialize fuzzy model parameters
initial_centers = linspace(0, 1, M); % Initial centers for M membership functions
initial_sigmas = 0.1 * ones(1, M); % Initial widths (all set to 0.1)
initial_weights = rand(1, M); % Random initial weights

% Initialize RLS parameters
P = initial_weight_variance * eye(M); % Covariance matrix
theta = initial_weights(:); % Parameter vector (weights)

% Prepare storage for model outputs
fuzzy_values_rls = zeros(size(train_u_values));

% Train model using Recursive Least Squares algorithm
for t = 1:num_train
    % Current input and desired output
    u_t = train_u_values(t);
    g_t = train_g_values(t);
    
    % Calculate the membership functions for the current input
    phi_t = zeros(M, 1); % Feature vector for membership outputs
    for l = 1:M
        phi_t(l) = exp(-((u_t - initial_centers(l))^2) / (2 * initial_sigmas(l)^2));
    end
    
    % Model output (current approximation)
    f_t = phi_t' * theta;
    fuzzy_values_rls(t) = f_t;
    
    % Error between desired and approximated output
    e_t = g_t - f_t;
    
    % Recursive update of parameters
    K_t = (P * phi_t) / (lambda + phi_t' * P * phi_t); % Gain vector
    theta = theta + K_t * e_t; % Update parameters
    P = (P - K_t * phi_t' * P) / lambda; % Update covariance matrix
end

% Compute the model output for the testing data
test_fuzzy_values = zeros(size(test_u_values));
for i = 1:length(test_u_values)
    u = test_u_values(i);
    phi = zeros(M, 1);
    for l = 1:M
        phi(l) = exp(-((u - initial_centers(l))^2) / (2 * initial_sigmas(l)^2));
    end
    test_fuzzy_values(i) = phi' * theta;
end

% Compute the model output for all data points (for plotting purposes)
identified_output = zeros(size(u_values));
for i = 1:length(u_values)
    u = u_values(i);
    phi = zeros(M, 1);
    for l = 1:M
        phi(l) = exp(-((u - initial_centers(l))^2) / (2 * initial_sigmas(l)^2));
    end
    identified_output(i) = phi' * theta;
end

% Calculate Errors
train_errors = train_g_values - fuzzy_values_rls; % Training errors
test_errors = test_g_values - test_fuzzy_values;  % Testing errors

% Plot: Desired Output vs. Identified Output (All Data)
figure;
plot(1:total_data_points, g_values, 'b-', 'LineWidth', 2); hold on; % Desired Output (True g[u])
plot(1:total_data_points, identified_output, 'r--', 'LineWidth', 2); % Identified Model Output
xlabel('Data Points');
ylabel('Output');
legend('Desired Output', 'Identified Model Output', 'Location', 'Best');
title('Plant Output vs. Identified Model Output');
grid on;

% Plot: Training Data vs. Model Output
figure;
plot(train_u_values, train_g_values, 'b-', 'LineWidth', 1.5); hold on; % Training Data
plot(train_u_values, fuzzy_values_rls, 'r--', 'LineWidth', 1.5); % Model Output on Training Data
xlabel('u');
ylabel('Output');
legend('Training Data', 'Model Output (Training)');
title('Training Data vs. Model Output');
grid on;

% Plot: Testing Data vs. Model Output
figure;
plot(test_u_values, test_g_values, 'b-', 'LineWidth', 1.5); hold on; % Testing Data
plot(test_u_values, test_fuzzy_values, 'r--', 'LineWidth', 1.5); % Model Output on Testing Data
xlabel('u');
ylabel('Output');
legend('Testing Data', 'Model Output (Testing)');
title('Testing Data vs. Model Output');
grid on;

% Plot: Training Errors
figure;
plot(train_u_values, train_errors, 'm-', 'LineWidth', 2);
xlabel('u');
ylabel('Error');
title('Training Errors');
grid on;

% Plot: Testing Errors
figure;
plot(test_u_values, test_errors, 'c-', 'LineWidth', 2);
xlabel('u');
ylabel('Error');
title('Testing Errors');
grid on;

% Plot Initial Membership Functions
figure;
u_range = linspace(0, 1, 500); % Fine-grained input range for plotting
colors = lines(M); % Generate M unique colors
hold on;
for l = 1:M
    % Initial membership functions
    initial_membership = exp(-((u_range - initial_centers(l)).^2) / (2 * initial_sigmas(l)^2));
    plot(u_range, initial_membership, 'Color', colors(l, :), 'LineStyle', '--', 'LineWidth', 1.5); % Unique color
end
xlabel('u');
ylabel('Membership Value');
title('Initial Membership Functions');
legend(arrayfun(@(l) sprintf('Membership %d', l), 1:M, 'UniformOutput', false), 'Location', 'Best');
grid on;
hold off;

% Plot Final Membership Functions
figure;
hold on;
for l = 1:M
    % Final membership functions
    final_membership = exp(-((u_range - initial_centers(l)).^2) / (2 * initial_sigmas(l)^2)); % Adjust if parameters change
    plot(u_range, final_membership, 'Color', colors(l, :), 'LineStyle', '-', 'LineWidth', 1.5); % Unique color
end
xlabel('u');
ylabel('Membership Value');
title('Final Membership Functions');
legend(arrayfun(@(l) sprintf('Membership %d', l), 1:M, 'UniformOutput', false), 'Location', 'Best');
grid on;
hold off;
