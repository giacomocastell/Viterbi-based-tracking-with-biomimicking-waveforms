function save_emission_matrix( scenario_settings, emission_matrix )

% Extract current date
currentDateTime = datestr(now, 'yyyy-mm-dd');

% Define name and path of output
folderPath = fullfile(scenario_settings.output_folder,'Emission matrix');

% Create new folder if it does not exist
if ~exist(folderPath)
    mkdir(folderPath);
end

fileName = [currentDateTime, '_', scenario_settings.waveform_type];
fileNameMat = strcat( fileName, '.mat');

save( fullfile (folderPath, fileNameMat),'emission_matrix');

end