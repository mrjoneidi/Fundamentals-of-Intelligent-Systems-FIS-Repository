fis = readfis('m2.fis'); % Load the fuzzy inference system from the file

% Simulation parameters
sim_time = 20; % Simulation time in seconds
dt = 0.01; % Time step
t = 0:dt:sim_time; % Time vector
ref = ones(size(t)); % Reference signal (step input)
error = zeros(size(t)); % Error signal
d_error = zeros(size(t)); % Derivative of error
control_signal = zeros(size(t)); % Control signal
output = zeros(size(t)); % System output

% Initial conditions
prev_error = 0;
integral_error = 0;

for k = 2:length(t)
    % Compute error
    error(k) = ref(k) - output(k-1);
    d_error(k) = (error(k) - prev_error) / dt;
    integral_error = integral_error + error(k) * dt;

    % Evaluate fuzzy PID
    fuzzy_input = [error(k), d_error(k)];
    fuzzy_output = evalfis(fuzzy_input, fis); % Evaluate the FIS

    Kp = fuzzy_output(1);
    Ki = fuzzy_output(2);
    Kd = fuzzy_output(3);

    % Compute control signal
    control_signal(k) = Kp * error(k) + Ki * integral_error + Kd * d_error(k);

    % Apply control signal to system
    [y_temp, ~] = lsim(sys, [control_signal(k-1) control_signal(k)], [t(k-1) t(k)]);
    output(k) = y_temp(end);

    % Update previous error
    prev_error = error(k);
end

% Plot results
figure;
subplot(3,1,1);
plot(t, ref, 'r--', 'LineWidth', 1.5); hold on;
plot(t, output, 'b', 'LineWidth', 1.5);
title('System Response with Fuzzy PID Controller');
xlabel('Time (s)');
ylabel('Output');
legend('Reference', 'Output');
grid on;

subplot(3,1,2);
plot(t, error, 'k', 'LineWidth', 1.5);
title('Error Signal');
xlabel('Time (s)');
ylabel('Error');
grid on;

subplot(3,1,3);
plot(t, control_signal, 'LineWidth', 1.5);
title('Control Signal');
xlabel('Time (s)');
ylabel('Control Signal');
grid on;
