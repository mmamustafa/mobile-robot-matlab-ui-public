function my_alg = random_drive(my_alg, robot)
% This function drives the robot randomly for 60 seconds.
%
% Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    % Initialization
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
    my_alg('sampling_time') = 4;
    my_alg('old_time') = 0;
end

time = toc(my_alg('tic'));      % Get time since start of session
if time < 60
    % Update evert sampling_time seconds
    if my_alg('is_first_time') || time - my_alg('old_time') > my_alg('sampling_time')
        % Drive randomly
        for ind = robot.actuator_inds
            if strcmp(robot.components_tree.get(ind).type, 'dc-motor')
                % Velocities between -5 and 5 rad/sec
                my_alg(robot.components_tree.get(ind).label) = -5 + 10 * rand();
            end
        end
        % Update old time
        my_alg('old_time') = time;
     end
else
    % Stop motors
    for ind = robot.actuator_inds
        my_alg(robot.components_tree.get(ind).label) = 0;
    end
    % Stop session
    my_alg('is_done') = true;
end

return