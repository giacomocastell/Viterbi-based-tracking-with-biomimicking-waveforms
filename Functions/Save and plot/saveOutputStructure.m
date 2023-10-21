function saveOutputStructure(output, simulation_results, scenario_settings, signalTX)
    
    scenario.FoV                 = [output.start_idx output.end_idx]; 
    scenario.scenario_settings   = scenario_settings;
    scenario.signalTX            = signalTX;
    scenario.simulation_results  = simulation_results;
    
    % Read path to the emission matrix
    fid = fopen( fullfile(output.current_folder,'emission_matrix.txt') );
    emission_matrix_path = textscan(fid,'%s','delimiter','\n'); 
    fclose(fid);
    
    if ~cellfun(@isempty,emission_matrix_path)
        % Store into output struct
        scenario.emission_matrix_path  = emission_matrix_path{1}{1};
    else

        filename = [datestr(now, 'yyyy-mm-dd'), '_', signalTX.signal, '_', num2str(fix(simulation_results.actual_distance(1))), 'meters'];
        emission_matrix_path = fullfile(scenario_settings.output_folder, 'Emission matrix', filename);
        scenario.emission_matrix_path  = emission_matrix_path;

    end
    
    % Delete file containing emission matrix path
    delete (fullfile(output.current_folder,'emission_matrix.txt'))
    
    % Save output struct
    save( fullfile (output.current_folder, 'scenario.mat'),'scenario');
    
    fprintf('\nOutput structure correctly saved.......\n')

end