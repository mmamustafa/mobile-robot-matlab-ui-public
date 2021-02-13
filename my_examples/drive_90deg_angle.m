function my_alg = drive_90deg_angle(my_alg, robot)
% This function drives the robot in a square with localization
% activated.
%
% Mohamed Mustafa, December 2020
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    % Initialization
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
end

% Drive in a square
time = toc(my_alg('tic'));      % Get time since start of session
if time < 10
    if time < 4
        my_alg('right motor') = 20;
        my_alg('left motor') = 20;
    elseif time < 6.5
        my_alg('right motor') = 1;
        my_alg('left motor') = -1;
    else
        my_alg('right motor') = 20;
        my_alg('left motor') = 20;
    end
else
    % Stop motors
    my_alg('right motor') = 0;
    my_alg('left motor') = 0;
    % Stop session
    my_alg('is_done') = true;
end

return