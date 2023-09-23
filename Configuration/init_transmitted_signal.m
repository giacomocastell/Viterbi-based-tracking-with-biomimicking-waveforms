function [signalTX] = init_transmitted_signal(flag)

switch flag
    case 'chirp'
        tau = 10e-3;                        % Duration of the pulse (10ms)
        fs = 100e3;                         % Sampling frequency (100kHz)
        t = 0:1/fs:tau-1/fs;                % Time axis
        f1 = 18e3;                          % Start frequency (18kHz)
        f2 = 34e3;                          % End frequency (34kHz)
        A = 1;
        x = A*chirp(t,f1,tau,f2);
    case 'biomimicking'
        path = strcat(pwd,'/Data/Waveforms/biomimicking/');
        [x,t,tau,fs] = biomimicked_signal_generation( path );
        f1 = 10e3;                        % To tune if use a new waveform  
        f2 = 15e3;                        % To tune if use a new waveform
        A=1;
        x = A*x;
    case 'airgun'
        filename = 'tpres_ppres.txt';
        path = strcat(pwd,'/Data/Waveforms/airgun/');
        [x,t,tau,fs] = read_airgun_signal( strcat(path, filename) );
        f1 = 0;
        f2 = 80;
        A = 1;
        x = A*x;
    otherwise
        error('Wrong waveform flag.');
end

signalTX.x   = x;
signalTX.t   = t;
signalTX.f1  = f1;
signalTX.f2  = f2;
signalTX.A   = A;
signalTX.fs  = fs;
signalTX.tau = tau;

end