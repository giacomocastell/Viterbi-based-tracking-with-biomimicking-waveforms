%%%%
%%%% Calculate emission matrix
%%%%

function [emission_matrix] = compute_emission_matrix(signalTX, scenario_settings,simulation_results)

fprintf('\nEmission matrix computation start\n');

drawplot = 0;
num_iterations = scenario_settings.num_iterations;
num_iterations=1;
% Cumulative vector to accumulate diplacements row by row
emission_matrix_row = zeros(1,2 * length(simulation_results.range_axis) + 1);

% Center of the vector (zero displacement)
zero_index = ceil(length(emission_matrix_row)/2);

for i=1:num_iterations
    
    fprintf('Iteration %d/%d\n', i,num_iterations);
    
    % Randomly track a target
    [random_target]        = scenario_sim(signalTX,scenario_settings,1);
    actual_distance_random = random_target.actual_distance;
    range_axis_random      = random_target.range_axis;
    value_random           = random_target.value;
    
    % Initialize vector to store (index of) position of the target
    indexes = cell(length(actual_distance_random), 1);
    
    for j=1:length(actual_distance_random)
        
        % Extract index of actual distance values
        d = abs(range_axis_random - actual_distance_random(j));
        [~, actual_distance_random_index] = min(d);
    
        % Compute index of nonzero measurements (closest to estimate of position)
        indexes{j} = find(value_random(j, :) ~= 0);
        
        % Find values of the nonzero measurements for each row
        v = zeros(1,length(indexes{j}));
        for k=1:length(indexes{j})
            v(k) = abs(value_random(j,indexes{j}(k)));
        end
    
        % Compute displacement wrt correct measurement and store into cell
        disp = actual_distance_random_index - indexes{j};
        displacement{j} = disp;
        
        % Normalization factor
        [maxVal,~] = max(abs(value_random(j,:)));
        
        % Shift by the amount of the zero index selected
        shifted_indexes = zero_index + displacement{j};
        
        % Store normalized value in the i-th row of the matrix
        % May raise an error if displacement factor is too small
        
        emission_matrix_row(shifted_indexes) = emission_matrix_row(shifted_indexes) + v / maxVal;
        
        if drawplot
            imagesc(range_axis_random,scenario_settings.timeaxis,abs(value_random));caxis([0 1e-5]);%xlim([0 400]);
            xlabel('Estimated distance [m]');
            ylabel('Time [s]');
        end    
    end
end

% Fill real emission matrix
range_axis_target      = simulation_results.range_axis;
value_target           = simulation_results.value;

% Initialize emission matrix
emission_matrix = zeros(size(value_target,2));

for i=1:length(emission_matrix)
    
    % Align actual distance of the target with center of the row
    total_shift = abs(zero_index-i);
    emission_matrix(i,:) = emission_matrix_row(total_shift:total_shift + length(range_axis_target)-1);

end

% Normalize 
emission_matrix = emission_matrix/max(emission_matrix,[],'all');

if drawplot
    xaxis = -floor(length(emission_matrix_row)/2):1:floor(length(emission_matrix_row)/2);
    plot(xaxis,emission_matrix_row);
    xlabel('Index');
    ylabel('Cumulative sum');
    title('Row of emission matrix');
end

fprintf('\nEmission matrix computation end\n');

end