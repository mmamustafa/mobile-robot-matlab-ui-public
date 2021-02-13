function my_alg = drive_straight_mapping(my_alg, robot)
% Drive straight with encoder localization and simple mapping on the real
% robot.
%
% Mohamed Mustafa, February 2021
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    % Initialization
    my_alg('dc_motor_signal_mode') = 'voltage_pwm';
    
    % Localization initialization
    my_alg('localizer') = LocalizationClass(...
        'method', 'wv',...
        'robot', robot,...
        'pose', [0 0 0],...
        'n_particles', 30,...
        'map', WorldClass('fname', 'world_0003.mat'),...
        'ext_sensor_label', 'lidar');
    
    % Mapping initialization
    my_alg('map') = MappingClass(...
        'method', 'prob_grid',...
        'robot', robot,...
        'ext_sensor_label', 'lidar',...
        'll_corner', [-10 -5],...
        'ur_corner', [10 5]);
end

%[my_alg('left encoder') my_alg('right encoder')]

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
if time < 7
    my_alg('right motor') = 0.25;
    my_alg('left motor') = 0.25;
elseif time < 10
    my_alg('right motor') = -0.27;
    my_alg('left motor') = 0.25;
elseif time < 17
    my_alg('right motor') = 0.25;
    my_alg('left motor') = 0.25;
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