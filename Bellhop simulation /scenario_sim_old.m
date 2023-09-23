%%%%
%%%% Build TD matrix 
%%%%

function [simulation_results] = scenario_sim(signalTX,scenario_settings,emission_matrix_flag)

% Scenario variables
num_pulses          = scenario_settings.num_pulses;
displacement_factor = scenario_settings.displacement_factor;
pos_TX              = scenario_settings.pos_TX;

% Check if the function is called in the context of emission matrix
% calculation. In this case, draw position of receiver at random
switch nargin
    case 2
        emission_matrix_flag = 0;
        pos_RX_init         = scenario_settings.pos_RX_init;
        lon_shift           = scenario_settings.lon_shift;
        lat_shift           = scenario_settings.lat_shift;
        dep_shift           = scenario_settings.dep_shift;
    
    case 3
        emission_matrix_flag = 1;
        [pos_RX_init,~,~,~] = random_shift_generator(scenario_settings);
        [~,lon_shift,lat_shift,dep_shift] = random_shift_generator(scenario_settings);
    
    otherwise
        error('Incorrect number of inputs');
end

% Initialize ground truth vector about target distance
dist = zeros(num_pulses,1);

% Simulate first transmission
[dist(1),range_first,val_first] = simulate_one_transmission(signalTX,scenario_settings,pos_RX_init);

% Matrix that describes position of the target
pos_target = zeros(num_pulses,3);

% First transmission target position
pos_target(1,:) = pos_RX_init;

% Initialize vectors that will store range reference and TD matrix respectively
range = zeros(round(length(range_first)*displacement_factor),num_pulses)';
val = zeros(round(length(val_first)*displacement_factor),num_pulses)';

% Store first simulation results in first row
range(1,:) = [range_first zeros(length(range(1,:)) - length(range_first),1)'];

% Define space distance between consecutive samples
spatial_resolution = abs(range(1,1)-range(1,2));

k_tmp = zeros(length(range(1,:)) - length(range_first),1)';
k_tmp(1) = range_first(end) + spatial_resolution;

for k=2:length(range(1,:)) - length(range_first)
    k_tmp(k) = k_tmp(k-1) + spatial_resolution;
end

range(1,:) = [range_first k_tmp];
val(1,:) = [val_first zeros(length(val(1,:)) - length(val_first),1)'];

% Loop through all transmissions

i = 2;
while i <= num_pulses
    
    if emission_matrix_flag
        [~,lon_shift,lat_shift,dep_shift] = random_shift_generator(scenario_settings);
    end

    % Define new receiver position
    pos_target(i,1) = pos_target(i-1,1) - lon_shift;
    pos_target(i,2) = pos_target(i-1,2) + lat_shift;
    pos_target(i,3) = pos_target(i-1,3) + dep_shift;
    
    % Simulate Bellhop 
    [dist(i),r,v] = simulate_one_transmission(signalTX,scenario_settings,pos_target(i,:));
    
    % Fill empty parts with zeros

    k_tmp = zeros(length(range(i,:)) - length(r),1)';
    k_tmp(1) = r(end)+ spatial_resolution;

    for k=2:length(range(i,:)) - length(r)
        k_tmp(k) = k_tmp(k-1) + spatial_resolution;
    end
    
    % Handle the situation where distance between random target and
    % transmitter reaches 0
    try
        val(i,:) = [v zeros(length(val(i,:)) - length(v),1)'];
        range(i,:) = [r k_tmp];
        i = i + 1;
    catch
        warning('Error in the random positioning of the target. Skipping iteration.')
        continue;
    end
end

% Align ranges to form image

% Find starting point (smaller value)
m = min(range(range > 0));

% Determine the shift 
shift = zeros(num_pulses,1);

for i=1:num_pulses

    sel = range(i,:);
    shift(i) = abs(min(sel(sel > 0))-m);
    
    % Number of samples to shift for
    n = round(shift(i)/spatial_resolution);
    
    % Temporarily store values in smaller arrays
    range_tmp = range(i,1:end-length(zeros(n,1)));
    val_tmp = val(i,1:end-length(zeros(n,1)));
    
    % Fill empty zones
    if n~=0
        k_tmp = zeros(n,1);
        k_tmp(n) = range_tmp(1) - spatial_resolution;
        for k=n-1:-1:1
            k_tmp(k) = k_tmp(k+1)-spatial_resolution;
        end
    else
        k_tmp = zeros(n,1);
    end
    
    range(i,:) = [k_tmp' range_tmp];
    val(i,:) = [zeros(n,1)' val_tmp];
end

rng = mean(range);

% Store results in data structure

simulation_results.actual_distance        = dist;
simulation_results.range_axis             = rng;
simulation_results.value                  = val;

end