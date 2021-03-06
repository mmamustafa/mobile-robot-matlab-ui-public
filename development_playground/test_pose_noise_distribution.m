clc, clear all, close all


% Create World
W = WorldClass('fname', 'world_0002.json');

% Plot all
figure(1)
tic
h_w = W.plot();
toc

d_t = 1e0;     % time step
    
% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');

% Particles
N = 100;
particles = zeros(2, N);
for j=1:N
    j
    % set pose
    T = [eye(3), [-1 -1 0]'; 0 0 0 1];
    R1.set_transformation(T)
    for i=1:10
        % Update motors
        R1.update_component('right motor', 'voltage_pwm', 0.05, 'delta_time', d_t)
        R1.update_component('left motor', 'voltage_pwm', 0.051, 'delta_time', d_t)
        
        % Update pose
        R1.update_pose('kinematics', d_t)
    end
    % update particles
    particles(:, j) = R1.transformation(1:2, 4);
end

% plot particles
plot(particles(1, :), particles(2, :), 'r.')
R1.plot();
