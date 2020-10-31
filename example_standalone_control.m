clc, clear all
restoredefaultpath
addpath(genpath(pwd))


% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');
% Uncomment below for using the real robot (it's simulation otherwise)
% R1.connect('192.168.1.1');

% Create World
W = WorldClass('fname', 'world_0002.json');

% Total duration and sampling time parameters
TotalTime = 2;
t_sampling = 0.02;

t_start = tic;
t_loop = tic;

% Initialise motor angular velocity controllers
control_right = MotorControl();
control_left = MotorControl();

% Controller setpoints for right and left wheel
wR_set = 7;
wL_set = 6;

wR = 0;
wL = 0;

wR_all = [0];
wL_all = [0];

while toc(t_start)<TotalTime
    
    dt = toc(t_loop);
    
    if(dt>=t_sampling)              % execute code when desired sampling time is reached
        t_loop = tic;
        
        % Right wheel controller %%%%%%%%%%%%%%%%%%%%
        errR = wR_set - wR;
        
        uR = control_right.Control(errR,dt);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Left wheel controller %%%%%%%%%%%%%%%%%%%%%
        errL = wL_set - wL;
        
        uL = control_left.Control(errL,dt);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Update robot in this order: actuators, pose (in simulation), sensors
        actuator_signals = {'right motor', uR, 'left motor', uL};
        sensor_readings = R1.update(dt, W, 'kinematics', 'voltage_pwm', actuator_signals{:});
        
        % Update encoder velocity readings
        wR = sensor_readings('right encoder');
        wL = sensor_readings('left encoder');
        
        % Save data for ploting
        wR_all = [wR_all wR];
        wL_all = [wL_all wL];
        
    end

     pause(0.001)
end

% Plot wheel angular velocities
plot(wR_all);
hold on;
plot(wL_all);


