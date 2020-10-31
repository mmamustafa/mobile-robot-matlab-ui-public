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
TotalTime = 1;
t_sampling = 0.02;

t_start = tic;
t_loop = tic;

% Wheel control pwm signals [-1,1]
uR = 1;
uL = 0.5;

wR_all = [0];
wL_all = [0];

while toc(t_start)<TotalTime
    
    dt = toc(t_loop);
    
    if(dt>=t_sampling) % execute code when desired sampling time is reached
        t_loop = tic;
                            
        % Update robot in this order: actuators, pose (in simulation), sensors
        if toc(t_start)>0.0
        actuator_signals = {'right motor', uR, 'left motor', uL};  
        else
        actuator_signals = {'right motor', 0, 'left motor', 0};  
        end
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

% plot saved velocities for right and left wheels
plot(wR_all);
hold on
plot(wL_all);


