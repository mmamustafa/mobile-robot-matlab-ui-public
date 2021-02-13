function my_alg = drive_semi_slam(my_alg, robot)
% This function drives the robot and performs localization and mapping
% separately.
% Mohamed Mustafa, December 2020
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    % Initialization
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
    
    % Localization initialization
    my_alg('localizer') = LocalizationClass(...
        'method', 'pf',...
        'robot', robot,...
        'pose', [0 0 0],...
        'n_particles', 30,...
        'map', WorldClass('fname', 'world_0003.mat'),...
        'ext_sensor_label', 'range');
    
    % Mapping initialization
    my_alg('map') = MappingClass(...
        'method', 'prob_grid',...
        'robot', robot,...
        'ext_sensor_label', 'range',...
        'll_corner', [-10 -5],...
        'ur_corner', [10 5]);
end

% Localization update
omegas_map = containers.Map({'right wheel', 'left wheel'},...
    [my_alg('right encoder'), my_alg('left encoder')]);
update(my_alg('localizer'), omegas_map)
my_alg = add_plot(my_alg, 'plot(my_alg(''localizer''))');     % plot pose estimation in the main figure

% Mapping upate
update(my_alg('map'), my_alg('localizer').pose)
my_alg = add_plot(my_alg, 'plot(my_alg(''map''), 0.5)');     % plot map in the main figure with 50% transparency

% Drive in a square
time = toc(my_alg('tic'));      % Get time since start of session
if time < 20
    if time < 4
        my_alg('right motor') = 20;
        my_alg('left motor') = 20;
    elseif time < 9.5
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
    % Plot map
    figure(1), clf
    plot(my_alg('map'), 0.5);
    axis equal
end

return