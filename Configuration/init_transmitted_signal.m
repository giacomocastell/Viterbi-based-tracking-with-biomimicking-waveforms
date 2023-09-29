function [signalTX] = init_transmitted_signal(scenario_settings)

switch scenario_settings.waveform_type
    case 'chirp'

        tau = 10e-3;                        % Duration of the pulse (10ms)
        fs = 100e3;                         % Sampling frequency (100kHz)
        t = 0:1/fs:tau-1/fs;                % Time axis
        f1 = 18e3;                          % Start frequency (18kHz)
        f2 = 34e3;                          % End frequency (34kHz)
        A = 1;
        x = A*chirp(t,f1,tau,f2);
        signal_tag = 'chirp';

    case 'biomimicking'

%         f1 = 20e3;                        % To tune if use a new waveform  
%         f2 = 30e3;                        % To tune if use a new waveform
%         path = strcat(pwd,'/../Biomimicking_dataset/Original/');
%         signal_type = scenario_settings.biomimicking_signal;
        
        f1 = 10e3;
        f2 = 15e3;
        path = strcat(pwd,'/Data/Waveforms/biomimicking/');
        signal_type = 'dolphin';
        
        center_frequency = round((f1+f2)/2);
        [x,t,tau,fs] = biomimicked_signal_generation( path, signal_type, center_frequency );
        A=1;
        x = A*x;

        signal_tag = strcat(scenario_settings.waveform_type, '_' ,signal_type);

    case 'airgun'
        filename = 'tpres_ppres.txt';
        path = strcat(pwd,'/Data/Waveforms/airgun/');
        [x,t,tau,fs] = read_airgun_signal( strcat(path, filename) );
        f1 = 0;
        f2 = 80;
        A = 1;
        x = A*x;
        signal_tag = 'airgun';
        
    otherwise
        error('Wrong waveform flag.');
end

signalTX.x          = x;
signalTX.t          = t;
signalTX.f1         = f1;
signalTX.f2         = f2;
signalTX.A          = A;
signalTX.fs         = fs;
signalTX.tau        = tau;
signalTX.signal_tag = signal_tag;

end