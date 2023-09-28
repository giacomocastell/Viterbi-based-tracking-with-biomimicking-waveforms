function mat2py(lower_bound, upper_bound, scenario_settings, simulation_results)

waveform = scenario_settings.waveform_type;
path = scenario_settings.viterbi_path;

% Restrict field of view + convert to strings
lower_bound = num2str(lower_bound);
upper_bound = num2str(upper_bound);

distance = num2str(fix(simulation_results.actual_distance(1)));

% Run python script, passing parameters to reduce computations
status = system(['python3 ', path, ' "', lower_bound, '" "', upper_bound, '" "', waveform, '" "', distance,'"']);

% Check if everything worked correctly
if status == 0
    
else
    error('Error executing Python script.');
end


end