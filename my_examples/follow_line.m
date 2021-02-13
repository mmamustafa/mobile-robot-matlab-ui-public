function my_alg = follow_line(my_alg, robot)
% This function follows a line for 60 seconds, then it stops.
%
% Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

% Initialization
if my_alg('is_first_time')
    % DC motor has 2 signal modes {'omega_setpoint', 'voltage_pwm'}. Place
    % your preference here:
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';
    
    % Initialization usually creates memory, therefore the first few
    % iterations require longer processing time. For applications where
    % sampling time is necessary it is better to ignore those first
    % iterations after initialization. The parameters below control this
    % behaviour.
    my_alg('ignore_iteration_counter') = 0;
    my_alg('n_iteration_to_ignore') = 2;
end

if my_alg('ignore_iteration_counter') == my_alg('n_iteration_to_ignore')
    % =================== Start your algorithm Here =======================
    
    
    time = toc(my_alg('tic'));      % Get time since start of session
    if time < 60
        omega_max = 10;  % max angular velocity of the wheel
        expected_value_normalized = my_alg('reflectance');
        
        % Drive
        my_alg('right motor') = omega_max * (1 + expected_value_normalized);
        my_alg('left motor') = omega_max * (1 - expected_value_normalized);
    else
        % Stop motors
        my_alg('right motor') = 0;
        my_alg('left motor') = 0;
        % Stop session
        my_alg('is_done') = true;
    end
    
    %[my_alg('left encoder') my_alg('right encoder') my_alg('reflectance')]
    
    
    % =================== Stop your algorithm Here ========================
else
    my_alg('ignore_iteration_counter') = my_alg('ignore_iteration_counter') + 1;
    my_alg('tic') = tic;        % reset the timer so when we enter the if-statement it looks as if we start now after ignoring the first few iterations
end
return