function puzzleBot_user_interface_1()
% PuzzleBot User Interface
% Mohamed Mustafa, August 2020

%% Version check
if verLessThan('matlab','8.4.0')
    error('puzzleBot_user_interface_1 requires at least MATLAB version 8.4 (R2014b) or newer.')
end

%% Startup
restoredefaultpath
addpath(genpath(pwd))
clc, close all
%warning('OFF')
disp('===========================================================')
disp('PuzzleBot User Interface ........................ Initiated')
disp('===========================================================')

%% User-defined section
control_filename = 'follow_line';	% File containing control signal to the robot
connect_to_physical_robot = false;
ip_address = '192.168.1.1';

%% Create Robot and World
W = WorldClass('fname', 'world_0004.mat');        % World only used in simulation
R1 = RobotClass('json_fname', 'puzzle_bot_0002.json');  % PuzzleBot without exteroceptive sensors


%% Connect to physical robot
if connect_to_physical_robot
    R1.connect(ip_address)
end

%% Start a figure for GUI/Joystick/Control
global key h0;
start_control_gui;

%% Wait for `s` key to be pressed by the user
disp('  Press ''s'' to start, or Press ''q'' to stop.')
while(~strcmp(key,'s') && ~strcmp(key,'q')),    pause(1e-3);    end
if strcmp(key,'s')
    disp('  Program: started.')
    % Plot robot components
    figure()
    R1.plot('full');
    axis equal, grid off
    title('Robot chassis with all components (For illustration purpose only)')
    % Plot would
    figure(h0); clf;
    h_w = W.plot();
    h_r = [];       % initialize from robot plot handle
end

%% Initialize `my_alg` map (hash table)
my_alg = containers.Map();
my_alg('tic') = tic;            % updates everytime step and can be used in time-related functions
my_alg('is_first_time') = true; % flag changes to false after the first time step.
my_alg('is_done') = false;      % flag to stop simulation
my_alg('dc_motor_signal_mode') = 'omega_setpoint';

plot_every_second = 0.1;        % inverse of frame rate
temp1 = plot_every_second;


%% Start the big loop
while(~strcmp(key,'q') && ~my_alg('is_done'))
    %% (1) Get input signals from my_alg
    actuator_signals = {};
    try
        for ind = R1.actuator_inds
            k = R1.components_tree.get(ind).label;
            try
                v = my_alg(k);
            catch
                v = 0;
            end
            actuator_signals = cat(2, actuator_signals, {k, v});
        end
    catch
    end
    
    %% (2) Compute change in time for robot update (simulation)
    try
        dt = toc(t_last_robot_upate);
    catch
        dt = 0;
    end
    t_last_robot_upate = tic;       % reset stopwatch
    
    %% (3) Move robot and update all sensors
    sensor_readings = R1.update(dt, W, 'kinematics',...
        my_alg('dc_motor_signal_mode'), actuator_signals{:});
    ks = keys(sensor_readings);
    for i = 1:length(ks)
        my_alg(ks{i}) = sensor_readings(ks{i});
    end
    
    %% (4) Apply control algorithm
    my_alg = feval(control_filename, my_alg, R1);
    
    %% (5) Update plot
    t_now = toc(my_alg('tic'));
    if t_now > temp1
        temp1 = t_now + plot_every_second;
        figure(h0);
        title(['Time ' num2str(toc(my_alg('tic'))) ' sec.'])
        delete([h_r])
        h_r = R1.plot('simple');
        pause(1e-3)
    end    
    
    %% (6) Update `my_alg` map
    if my_alg('is_first_time'),     my_alg('is_first_time') = false;	end
end

%% Stop motors and disconnect robot
R1.disconnect()

if my_alg('is_done')
    disp('  Program: Finished.')
else
    disp('  Program: stoped by the user.')
end
hold off

%% Close control GUI
close_control_gui;
disp('===========================================================')
disp('PuzzleBot User Interface ....................... Terminated')
disp('===========================================================')

end


function start_control_gui()
global key h0;
key = 0;
try
    h0 = figure(1); clf,
    %axis equal;     axis([-1 1 -1 1]);  grid on;
    %set(h0,'WindowStyle','modal');
    
    set(h0,'Position',[0 60 880 600]);
    set(h0,'Resize','off');
    movegui(h0,'northwest');
    set(h0, 'KeyPressFcn', @Key_Down, 'KeyReleaseFcn', @Key_Up);
    pause(1e-3);
    controlGUIstarted = 1;
catch
    controlGUIstarted = 0;
end

disp(' ')
if controlGUIstarted
    disp('  Control GUI ........................ Initialized.')
else
    disp('  Control GUI ........................ Not Initialized!')
end
end


function close_control_gui()
global h0;
try
    %close(h0);
    controlGUIclosed = 1;
catch
    controlGUIclosed = 0;
end

if controlGUIclosed
    disp('  Control GUI ........................ Closed.')
else
    disp('  Control GUI ........................ Not Closed!')
end
end


function Key_Up(src,event)
% http://uk.mathworks.com/matlabcentral/newsreader/view_thread/311895
global h0 key;
key = 'xxx';
set(h0,'KeyPressFcn',@Key_Down);
end


function Key_Down(src,event)
% http://uk.mathworks.com/matlabcentral/newsreader/view_thread/311895
global h0 key;
key = get(h0, 'CurrentKey');

% >> Comment the following line to be the same as before (working with 's'
%    and 'q'.
% 
% >> May be put if-statement here to do the following with arrows and space
% bar only...
set(h0,'KeyPressFcn','');
end