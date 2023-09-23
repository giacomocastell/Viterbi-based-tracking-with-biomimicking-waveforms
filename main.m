clc;
clear;

addpath(genpath(pwd));

%% Load data and initialize scenario

scenario_settings = init_scenario();

%%%%% Define transmitted signal
signalTX = init_transmitted_signal(scenario_settings.waveform_type);

%% Simulate whole scenario

simulation_results = scenario_sim(signalTX,scenario_settings);

%% Prepare for tracking - Emission matrix calculation - Save results

if scenario_settings.compute_emission_matrix
    emission_matrix = compute_emission_matrix(signalTX, scenario_settings, simulation_results);
    th = scenario_settings.threshold;
    
    % Check emission matrix size (if too large this may be too large to store)
    if size(emission_matrix,1) > th
        
        fprintf('Emission matrix is too large, only first %d elements taken\n',th)
        emission_matrix = emission_matrix(1:th,1:th);

    end
    
    % Store or not new emission matrix
    if scenario_settings.save_emission_matrix
        save_emission_matrix(scenario_settings, emission_matrix)
    end

end

%% Store simulation results

% Restrict field of view
[~,start_idx] = min(abs((min(simulation_results.actual_distance)*0.5 - simulation_results.range_axis)));
[~,end_idx] = min(abs((max(simulation_results.actual_distance)*1.5 - simulation_results.range_axis)));

% Store or not results
if scenario_settings.save_results
    
    [output] = saveResults(simulation_results, scenario_settings, start_idx, end_idx);
    
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
    
    mat2py(start_idx, end_idx, scenario_settings);

end

%% Results visualization
if scenario_settings.plot_results
    plotResults( simulation_results, scenario_settings, output );
end