function my_alg = drive_square_timer(my_alg, robot)
% This function drives the robot in a square path using timer.
%
% Mohamed Mustafa, February 2021
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
    
    my_alg('time1') = toc(my_alg('tic'));
    my_alg('state') = 1;
    my_alg('side_counter') = 0;
end

time = toc(my_alg('tic'));      % Get time since start of session
% (a) Select the state
% --------------------
if my_alg('state') == 1
    if time - my_alg('time1') >= 5
        my_alg('side_counter') = my_alg('side_counter') + 1;
        if my_alg('side_counter') == 4
            disp('Done!')
            my_alg('state') = 3;
        else
            disp('Turn 90 degrees.')
            my_alg('state') = 2;
            my_alg('time1') = time;
        end
    end
elseif my_alg('state') == 2
    if time - my_alg('time1') >= 2.5
        disp('Straight.')
        my_alg('state') = 1;
        my_alg('time1') = time;
    end
elseif my_alg('state') == 3
    % Stop session
    my_alg('is_done') = true;
end

% (b) Apply the state
% -------------------
if my_alg('state') == 1       % straight
    my_alg('right motor') = 5;
    my_alg('left motor') = 5;
elseif my_alg('state') == 2   % turn
    my_alg('right motor') = -1;
    my_alg('left motor') = 1;
elseif my_alg('state') == 3   % stop and terminate
    my_alg('right motor') = 0;
    my_alg('left motor') = 0;
end

return