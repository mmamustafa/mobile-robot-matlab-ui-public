function my_alg = template_with_sampling_time(my_alg, robot)
% This template can be used to develop algorithms that depend on sampling
% time.
%
% This function is called-back by MOBILE_ROBOT_PLATFORM inside a loop,
% therefore it is better used with state machines.
% 
% The input parameter my_alg is hash table of class container.Map. It has
% some global elements to be understood by MOBILE_ROBOT_PLATFORM. Those
% global elements are:
%   my_alg('tic') returns an identifier to the start time of session. To
%       compute the current time use toc(my_alg('tic'))
%   my_alg('is_first_time') returns a boolean to indicate whether the
%   	iteration is the first one. This element can be used to initialize
%   	parameters needed for the algorithm.
%   my_alg('is_done') returns a boolean to terminate the session
%       programmatically.
%   my_alg('dc_motor_signal_mode') returns a string defining the signal
%       mode. Options are {'omega_setpoint', 'voltage_pwm'}
%   my_alg(...) returns the value of the actuator or sensor labelled ... in
%       robot JSON-file.
%
% The user can add problem-specific parameters as elements to my_alg that
% will persist throughout the session. 
%
% Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

% Initialization
if my_alg('is_first_time')
    my_alg('dc_motor_signal_mode') = 'omega_setpoint';     % change if necessary to 'voltage_pwm'
    my_alg('sampling_time') = 5e-2;     % use machine processing time if set to empty
    
    my_alg('machine_old_time') = 0;     % needed for validating sampling time
    my_alg('update_old_time') = 0;      % needed for identifying the event when sampling time is reached
end

time = toc(my_alg('tic'));              % time since start of session
% Make sure sampling time is larger than machine processing time
processing_time = time - my_alg('machine_old_time');    % Machine processing time
my_alg('machine_old_time') = time;                      % Update for next iteration
if processing_time > my_alg('sampling_time')
    warning(['Requested sampling time of ' ...
             num2str(my_alg('sampling_time')) ' sec. is smaller than ' ...
             'machine processing time around ' num2str(processing_time) ...
             ' sec.! Machine processing time is used as sampling time.'])
    my_alg('sampling_time') = [];
end
actual_sampling_time = time - my_alg('update_old_time');
if isempty(my_alg('sampling_time')) || (actual_sampling_time > my_alg('sampling_time'))
    my_alg('update_old_time') = time;      % Update old time
    % =================== Start your algorithm Here =======================
    

    
    % =================== Stop your algorithm Here ========================
end
return