function plotResults ( simulation_results, scenario_settings, output )

% Extract variables form output structure
viterbi_path = strcat(output.current_folder,'/viterbi_results.txt');
start_idx    = output.start_idx;
end_idx      = output.end_idx;

% Obtain simulation results
value        = simulation_results.value; 
range_axis   = simulation_results.range_axis;

% Viterbi results (Python script)
res = importdata( viterbi_path ) ;  
res = res.';

% Initialize matrix
N = zeros(size(value(:,start_idx:end_idx)));
for t=1:length(scenario_settings.timeaxis)
    
    % Store as '1' the path estimated
    N(t,res(t) - start_idx) = 1;
    
    % Extract indexes of actual position
    diff = abs(range_axis - simulation_results.actual_distance(t));
    [~, index] = min(diff);
    
    % Store as '2' the actual path
    N(t,index - start_idx) = 2;
end    

my_colormap = [0 0 1; 0 1 0; 1 0 0];

% Plot results
figure;
imagesc(range_axis(start_idx:end_idx),scenario_settings.timeaxis,N);
xlabel('Distance [m]');
ylabel('Time [s]');
colormap(my_colormap);


end