clc;
clear;

addpath(genpath(pwd));

%% Load data and initialize scenario

scenario_settings = init_scenario();

%%%%% Define transmitted signal
signalTX = init_transmitted_signal(scenario_settings);

%% Simulate whole scenario

simulation_results = scenario_sim(signalTX,scenario_settings);

%% Prepare for tracking - Emission matrix calculation - Save results

if scenario_settings.compute_emission_matrix
    emission_matrix = compute_emission_matrix(signalTX, scenario_settings, simulation_results);
    th = scenario_settings.threshold;
    
    % Check emission matrix size (if too large this may be too large to store)
    if (size(emission_matrix,1) > th) && scenario_settings.FoV_restricted
        
        fprintf('Emission matrix is too large, only first %d elements taken\n',th)
        emission_matrix = emission_matrix(1:th,1:th);

    end
    
    % Store or not new emission matrix
    if scenario_settings.save_emission_matrix
        save_emission_matrix(scenario_settings, signalTX, simulation_results, emission_matrix)
    end

end

%% Store simulation results

if scenario_settings.FoV_restricted
    % Restrict field of view (memory and computational time reasons)
    [~,start_idx] = min(abs((min(simulation_results.actual_distance)*0.5 - simulation_results.range_axis)));
    [~,end_idx]   = min(abs((max(simulation_results.actual_distance)*1.5 - simulation_results.range_axis)));

    start_idx = length(1:simulation_results.range_axis(2)-simulation_results.range_axis(1):simulation_results.range_axis(1));
    end_idx   = start_idx + length(simulation_results.range_axis);

else
    start_idx = 1;
    end_idx   = length(simulation_results.range_axis);
end
%%
% Store or not results
if scenario_settings.save_results
    
    [output] = saveResults(simulation_results,signalTX, scenario_settings, start_idx, end_idx);
    
    % Save all simulated scenario

    simulated_scenario.FoV                 = [start_idx end_idx]; 
    simulated_scenario.scenario_settings   = scenario_settings;
    simulated_scenario.signalTX            = signalTX;
    simulated_scenario.simulation_results  = simulation_results;
    
else
    
    % If not saved, only visualize the data
    imagesc(simulation_results.range_axis,scenario_settings.timeaxis,abs(simulation_results.value));caxis([0 1e-4]);%xlim([0 400]);
    xlabel('Estimated distance [m]');
    ylabel('Time [s]');
        
    return;
end

%% Run tracking algorithm (Viterbi)
% --> python3 viterbi.py

if scenario_settings.run_viterbi
    
    mat2py(start_idx - 1, end_idx - 1, scenario_settings, signalTX, simulation_results);
    
    % Read path to the emission matrix
    fid = fopen( fullfile(output.current_folder,'emission_matrix.txt') );
    emission_matrix_path = textscan(fid,'%s','delimiter','\n'); 
    fclose(fid);
    
    % Store into output struct
    simulated_scenario.emission_matrix_path  = emission_matrix_path{1}{1};
    
    % Save output struct
    save( fullfile (output.current_folder, 'scenario.mat'),'simulated_scenario');
    
    % Delete file containing emission matrix path
    delete (fullfile(output.current_folder,'emission_matrix.txt'))

end

%% Results visualization
if scenario_settings.plot_results
    
    plotResults( simulation_results, scenario_settings, output );
    
end