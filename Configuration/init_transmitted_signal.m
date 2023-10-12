function [signalTX] = init_transmitted_signal(scenario_settings)

A = 1;

switch scenario_settings.waveform_type
    case 'chirp'
        tau = 10e-3;                        % Duration of the pulse (10ms)
        fs = 100e3;                         % Sampling frequency (100kHz)
        t = 0:1/fs:tau-1/fs;                % Time axis
        f1 = 18e3;                          % Start frequency (18kHz)
        f2 = 34e3;                          % End frequency (34kHz)
        x = A*chirp(t,f1,tau,f2);

        signal = scenario_settings.waveform_type;
    case 'biomimicking'
        path = 'Data/Waveforms/biomimicking/';
        
        % 'Dolphin_1', 'Dolphin_2', 'Orca', 'Beaked_Whale', 'Humpback_Whale','Sea_Lion'
        signal = 'Dolphin_2';
        
        f1 = 20e3;                        % To tune if use a new waveform  
        f2 = 30e3;                        % To tune if use a new waveform
        
        center_frequency = round((f1+f2)/2);
%         center_frequency = 12e3;
        variance = 2e3;

        [x,t,xo,to,message,tau,fs] = biomimicked_signal_generation( path, ...
                                                                    signal, ...
                                                                    center_frequency, ...
                                                                    variance, ...
                                                                    scenario_settings );
        x = A*x;

        signalTX.x_original = xo;
        signalTX.biomimicking.t_original = to;
        signalTX.biomimicking.message    = message;
    
    case 'png'
        
        path = 'Functions/Signals generation/example_images';
        filename = 'synth_diffgen_1.png';
        [x,t,tau,fs] = read_png ( fullfile(path, filename) );
        f1 = 0e3;
        f2 = 100e3;
        
        signal = 'biomimicking_png';

    case 'airgun'
        filename = 'tpres_ppres.txt';
        path = strcat('Data/Waveforms/airgun');
        [x,t,tau,fs] = read_airgun_signal( fullfile(path, filename) );
        f1 = 0;
        f2 = 80;
        x = A*x;

        signal = scenario_settings.waveform_type;
    otherwise
        error('Wrong waveform flag.');
end

signalTX.x      = x;
signalTX.t      = t;
signalTX.f1     = f1;
signalTX.f2     = f2;
signalTX.A      = A;
signalTX.fs     = fs;
signalTX.tau    = tau;
signalTX.signal = signal;

end