function my_alg = drive_square_localization(my_alg, robot)
% This function drives the robot in a square path using timer.
%
% Mohamed Mustafa, February 2021
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
    
    % Localization initialization
    my_alg('localizer') = LocalizationClass(...
        'method', 'wv', 'robot', robot, 'pose', [0 0 0]);
    
    my_alg('state') = 1;
    my_alg('side_counter') = 0;
    my_alg('start_pose') = my_alg('localizer').pose;
end

% Localization update
omegas_map = containers.Map({'right wheel', 'left wheel'},...
    [my_alg('right encoder'), my_alg('left encoder')]);
update(my_alg('localizer'), omegas_map)

% Extract information form simplicity of the code
s = my_alg('localizer').pose;   % robot current pose
s_pose = my_alg('start_pose');  % robot start pose
R = 3;                      % square side length

% (a) Select the state
% --------------------
if my_alg('state') == 1
    xg = s_pose(1) + R*cos(s_pose(3));
    yg = s_pose(2) + R*sin(s_pose(3));
    if distance_two_points([xg;yg],s(1:2)) < 0.3
        s_pose = s;
        my_alg('side_counter') = my_alg('side_counter') + 1;
        if my_alg('side_counter') == 4
            disp('Done!')
            my_alg('state') = 3;
        else
            disp('Turn 90 degrees.')
            my_alg('state') = 2;
        end
    end
elseif my_alg('state') == 2
    thetag = s_pose(3) + pi/2;
    if abs(wrapToPi(s(3)-thetag)) < 0.05
        s_pose = s;
        disp('Straight.')
        my_alg('state') = 1;
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
    my_alg('right motor') = 1;
    my_alg('left motor') = -1;
elseif my_alg('state') == 3   % stop and terminate
    my_alg('right motor') = 0;
    my_alg('left motor') = 0;
end

% Update MyAlg
my_alg('start_pose') = s_pose;   % robot start pose

return