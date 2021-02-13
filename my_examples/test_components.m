function my_alg = test_components(my_alg, robot)
% Test sonar, servo, reflectance sensors
%
% Mohamed Mustafa, August 2020
% -------------------------------------------------------------------------

if my_alg('is_first_time')
    % Initialization
    my_alg('counter_1') = 1;
end

%[my_alg('sonar') my_alg('reflectance') my_alg('left encoder') my_alg('right encoder')]

my_alg('servo motor') = deg2rad(-30 + mod(my_alg('counter_1'), 60));

my_alg('counter_1') = my_alg('counter_1') + 1;
return