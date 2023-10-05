function [output] = saveResults(simulation_results, scenario_settings,signalTX, start_idx, end_idx)

% Extract simulation results
range_axis  = simulation_results.range_axis;
value       = simulation_results.value;

% Extract current date
currentDateTime = datestr(now, 'yyyy-mm-dd');

% Start distance
distance = fix(simulation_results.actual_distance(1));

% Define name and path of output
folderName = [currentDateTime, '_', signalTX.signal ,'_', num2str(distance),'meters'];
folderPath = fullfile(scenario_settings.output_folder, folderName);

% Create new folder if it does not exist
if ~exist(folderPath)
    mkdir(folderPath);
end

% Actually store the data
save( fullfile (folderPath, 'ranges.mat'),'range_axis');
save( fullfile (folderPath, 'values.mat'),'value');

% Return output in data structure
output.current_folder = folderPath;
output.start_idx      = start_idx;
output.end_idx        = end_idx;

end