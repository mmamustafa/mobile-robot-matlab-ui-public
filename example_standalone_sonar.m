clc, clear all, close all
restoredefaultpath
addpath(genpath(pwd))


% Create Robot (robot with reflectance,sonar and servo motor)
R1 = RobotClass('json_fname', 'puzzle_bot_0002.json');
% Uncomment below for using the real robot (it's simulation otherwise)
R1.connect('192.168.1.1');

% Create World
W = WorldClass('fname', 'world_wall.json');

% Plot world and robot
figure(1)
h_w = W.plot();

% Total duration and sampling time parameters
TotalTime = 10;
sampling_inner = 0.02;
sampling_outer = 0.1;

t_start = tic;
t_outer_loop = tic;
t_inner_loop = tic;

% Initialise motor angular velocity controllers
control_right = MotorControl();
control_left = MotorControl();

% Desired wheel velocities
wR_set = 0;
wL_set = 0;

wR = 0;
wL = 0;

% desired wheel velocity 
w_desired = 5;

% Proportional gain for following the wall
K = 5;

while toc(t_start)<TotalTime
    
    %% Outer loop
    dt = toc(t_outer_loop);
    
    if(dt>=sampling_outer) % execute code when desired outer loop sampling time is reached
        t_outer_loop = tic;
                                
        sonar_dist = sensor_readings('sonar');
        
        % If a wall is found less than 1m away from the robot then follow it
        if sonar_dist < 1
            err_dist = 0.5 - sonar_dist;  % hold a constant distance of 0.5m to the wall
            wR_set = w_desired - K*err_dist;
            wL_set = w_desired + K*err_dist;
        else
            wR_set = 0;
            wL_set = 0;
        end
                
        % Plot all
        try
            delete([h_r, h_s])
        catch
        end
        h_r = R1.plot('simple');
        h_s = R1.plot_measurements('sonar');
    end

    %% Inner loop
    dt = toc(t_inner_loop);
    if(dt>=sampling_inner) % execute code when desired inner loop sampling time is reached
        t_inner_loop = tic;
                
        uR = control_right.Control(wR_set-wR,dt);
        uL = control_left.Control(wL_set-wL,dt);
        
        % Update robot in this order: actuators, pose (in simulation), sensors
        % Set the servo angle to 90 degrees to the left, 1.57 radians (where the wall should be)
        actuator_signals = {'right motor', uR, 'left motor', uL,'servo motor',1};
        sensor_readings = R1.update(dt, W, 'kinematics', 'voltage_pwm', actuator_signals{:});
        
        % Update encoder velocity readings
        wR = sensor_readings('right encoder');
        wL = sensor_readings('left encoder');

    end
    
    pause(0.001)
end

actuator_signals = {'right motor', 0, 'left motor', 0,'servo motor',0};
R1.update(dt, W, 'kinematics', 'voltage_pwm', actuator_signals{:});


