clc, clear all
restoredefaultpath
addpath(genpath(pwd))


% Create Robot
R1 = RobotClass('json_fname', 'robot_0002.json');
% Uncomment below for using the real robot (it's simulation otherwise)
R1.connect('192.168.1.1');

% Create World
W = WorldClass('fname', 'world_0002.json');

% Total duration and sampling time parameters
t_sampling = 0.01;

t_start = tic;
t_loop = tic;

% Wheel control pwm signals [-1,1]
uR = 0;
uL = 0;

wR = 0;
wL = 0;

real_all = [];
imag_all = [];
amp_all = [];
phase_all = [];
f_all = [];

F_start = 0.5;
F_final = 15;
f = F_start;
step_f = 0.25;

Nf = 4;

while f<=F_final
    
    k=0:Nf/(f*t_sampling);
        
	uR = sin(2*pi*k*t_sampling*f);
                            
	actuator_signals = {'right motor', uR};  
	R1.update(t_sampling, W, 'kinematics', 'voltage_pwm', actuator_signals{:});
    
    wR = 0;

	while size(wR,2)<size(uR,2)
        actuator_signals = {};  
        sensor_readings = R1.update(t_sampling, W, 'kinematics', 'voltage_pwm', actuator_signals{:});

        % Update encoder velocity readings
        wR = sensor_readings('right encoder');

        pause(0.001);
	end

    t = t_sampling*(0:length(wR)-1);
	[imag,real] = harmonicFit(t,wR,f);
            
	amp = sqrt(real^2+imag^2);
	phase = atan2(imag,real);
	if phase>0
        phase = phase - 2*3.1415926;
    end

	if amp > 0
        real_all = [real_all real];
        imag_all = [imag_all imag];
        amp_all = [amp_all amp];
        phase_all = [phase_all phase];
        f_all = [f_all f];

        figure(1);
        plot(t,uR);
        hold on;
        plot(t,wR);
        hold off;
        xlabel('Time (s)');
        ylabel('Angular Velocity (Rad/s)');
        title('Input/Output signals');
        figure(2);
        plot(real,imag,'*b');
        hold on;
        xlabel('Real Axis');
        ylabel('Imaginary Axis');
        title('Niquist diagram')
    else
        disp('Error');
    end
            
    f = f + step_f;
end

F = 2*3.1415*f_all;
figure(3);
subplot(2,1,1);
plot(F,20*log10(amp_all));
set(gca,'XScale', 'log');
axis([F(1) F(size(F,2)) 20*log10([amp_all(size(amp_all,2))-1 amp_all(1)+1])]);
xlabel('Frequency (Rad/s)');
ylabel('Magnitude (dB)');
title('Bode diagram')
subplot(2,1,2);
plot(F,180/3.1415*phase_all);
set(gca,'XScale', 'log');
axis([F(1) F(size(F,2)) 180/3.1415*[phase_all(size(phase_all,2)) phase_all(1)]]);
xlabel('Frequency (Rad/s)');
ylabel('Phase (deg)');

