% Main Script: PID Controller Tuning using Ziegler-Nichols Method

% Define system parameters
num = 1; 
den = [1 2 1]; 
sys = tf(num, den); % Create the system



%{
Kp = 1; % Initial proportional controller gain
sys_cl = feedback(Kp * sys, 1); % Closed-loop system

[Ku, Pu] = find_critical_values(sys);

% PID controller coefficients using Ziegler-Nichols method
Kp = 0.6 * Ku;
Ti = Pu / 2;
Td = Pu / 8;

Ki = Kp / Ti;
Kd = Kp * Td;

% PID controller
C_pid = pid(Kp, Ki, Kd);

% Closed-loop system with PID controller
sys_cl_pid = feedback(C_pid * sys, 1);

% Step response of the closed-loop system
figure;
step(sys_cl_pid);
title('Step Response of System with PID Controller');
xlabel('Time (seconds)');
ylabel('System Output');
grid on;

% Display PID controller coefficients
fprintf('PID Controller Coefficients:\n');
fprintf('Kp = %.4f\n', Kp);
fprintf('Ki = %.4f\n', Ki);
fprintf('Kd = %.4f\n', Kd);

% Time response with stability display
[y, t] = step(sys_cl_pid);
figure;
plot(t, y, 'LineWidth', 1.5);
title('Time Response of System with PID Controller');
xlabel('Time (seconds)');
ylabel('System Output');
grid on;

% Function to find Ku and Pu
function [Ku, Pu] = find_critical_values(sys)
    Ku = 1; % Initial guess for critical gain
    delta_K = 0.1; % Increment step for gain
    max_iter = 1000; % Maximum number of iterations

    % Initialize variables
    is_unstable = false;
    oscillation_detected = false;

    for i = 1:max_iter
        sys_cl = feedback(Ku * sys, 1); % Closed-loop system
        [y, t] = step(sys_cl, 0:0.01:100); % Step response for long enough time

        % Check stability by analyzing the poles
        poles = pole(sys_cl);
        if any(real(poles) >= 0)
            % System becomes unstable, stop incrementing gain
            is_unstable = true;
            break;
        end

        % Detect oscillations in the step response
        [~, locs] = findpeaks(y);
        if numel(locs) >= 2
            % Oscillations detected
            oscillation_detected = true;
            break;
        end

        % Increment the gain
        Ku = Ku + delta_K;
    end

    if ~oscillation_detected
        error('Unable to find Ku: System does not exhibit sustained oscillations.');
    end

    if ~is_unstable
        warning('Ku found, but system may not be fully critical.');
    end

    % Calculate critical period Pu from peaks in the step response
    [~, locs] = findpeaks(y);
    if numel(locs) > 1
        Pu = t(locs(2)) - t(locs(1));
    else
        error('Unable to determine Pu: Not enough oscillations detected.');
    end
end

