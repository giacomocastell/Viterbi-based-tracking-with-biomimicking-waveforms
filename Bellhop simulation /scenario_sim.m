%%%%
%%%% Build TD matrix 
%%%%

function [simulation_results] = scenario_sim(signalTX,scenario_settings,emission_matrix_flag)

%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialization %%%%
%%%%%%%%%%%%%%%%%%%%%%%%

% Scenario variables
num_pulses          = scenario_settings.num_pulses;
pos_TX              = scenario_settings.pos_TX;

drawplot = 0;

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

% Matrix that describes position of the target
pos_target = zeros(num_pulses,3);

% Initialize cell arrays
range = cell(num_pulses, 3);
value = cell(num_pulses, 1);

% range = zeros(round(length(range_first)*displacement_factor),num_pulses)';
% val = zeros(round(length(val_first)*displacement_factor),num_pulses)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Simulate first transmission %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First cell element -> result of simulation
[dist(1),range{1, 1},value{1}] = simulate_one_transmission(signalTX,scenario_settings,pos_RX_init, emission_matrix_flag);

% Second cell element -> first element of simulation
range{1, 2} = range{1, 1}(1);

% Third cell element -> last element of simulation
range{1, 3} = range{1, 1}(end);

% First transmission target position
pos_target(1,:) = pos_RX_init;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Simulate all transmissions %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize max and min ranges (to be updated in loop)
minRange = Inf;
maxRange = 0;

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
    [dist(i),range{i, 1},value{i}] = simulate_one_transmission(signalTX,scenario_settings,pos_target(i,:), emission_matrix_flag);
    
    if dist(i) > 0.5
        
    else
        warning('Skipping iteration');
        continue;
    end

    % Store first element and vector length
    range{i, 2} = range{i, 1}(1);
    range{i, 3} = range{i, 1}(end);
    
    % Find starting points (minimum range along all transmissions)
    if range{i, 2} < minRange
        minRange = range{i, 2};
    end
    
    % Find largest range measured
    if range{i, 3} > maxRange
        maxRange = range{i, 3};
    end
    
    % Next iteration
    i = i + 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Store and form TD matrix %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define space distance between consecutive samples
spatial_resolution = abs(range{1, 1}(1)-range{1, 1}(2));

rng = minRange:spatial_resolution:maxRange;
% rng = zeros(num_pulses,maxLength);

maxLength = length(rng);
val = zeros(num_pulses,maxLength);

for i=1:num_pulses
    
    % Compute quantity to shift
    [~,shift] = min(abs(range{i, 2} - rng));
    val(i,shift:length(value{i})+shift-1) = value{i};
end

if size(val,2) ~= length(rng)
    val = val(:,1:length(rng));
end 

simulation_results.actual_distance        = dist;
simulation_results.range_axis             = rng;
simulation_results.value                  = val;

if drawplot
    imagesc(rng,scenario_settings.timeaxis,abs(val));%caxis([0 1e-4]);%xlim([0 400]);
    xlabel('Estimated distance [m]');
    ylabel('Time [s]');
end

end