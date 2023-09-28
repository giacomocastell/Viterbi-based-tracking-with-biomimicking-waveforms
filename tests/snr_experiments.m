clc;
clear;

sigpath = fullfile('..','Functions/Signals generation/');
addpath(sigpath);

path = fullfile('..', 'Data/Waveforms/biomimicking/');

% strcat(sigpath, biomimicked_signal_generation.m);

% [x,t,tau,fs] = biomimicked_signal_generation( path );


% Signal definition (chirp)
tau = 10e-3;                        % Duration of the pulse (10ms)
fs = 100e3;                         % Sampling frequency (100kHz)
t = 0:1/fs:tau-1/fs;                % Time axis
f1 = 18e3;                          % Start frequency (18kHz)
f2 = 34e3;                          % End frequency (34kHz)
A = 1;
x = A*chirp(t,f1,tau,f2);

% Samples considered
N = 999;

% Index where to start from
start_idx = 1;

% SNR in dB scale
SNR_dB = 10;
% SNR to linear scale
SNR = 10^(SNR_dB/10);

% Length of considered signal
L = length(x);

% Calculate actual symbol energy
Esig=sum(abs(x).^2)/(L); 

% Find the noise spectral density
N0=Esig/SNR; 

if ( isreal(x))
    % Standard deviation for AWGN Noise when x is real
    noiseSigma = sqrt (N0);
    % computed noise
    n = noiseSigma*randn(1,L);
else
    noiseSigma= sqrt (N0/2);
    n = noiseSigma*(randn(1,L)+1i*randn(1,L));
end

% First N samples of noise
nw = n(1:N);

% Signal + noise
y = x + n;

% Range to consider
rngs = start_idx:start_idx + N;

% Noise energy
Pn = sum(abs(nw).^2)/length(nw);

% Signal+noise energy within same time interval
Psn = sum(abs(y(rngs)).^2)/length(y(rngs));

fprintf('\nMyMethod (P_N+S)/P_N - SNR_lin - 1 = %.2f\n\n',Psn/Pn - SNR - 1)

% Method 2
y2 = awgn(x,10,'measured');
Psn2 = sum(abs(y2(rngs)).^2)/length(y2(rngs));

fprintf('\nNotMyMethod (P_N+S)/P_N - SNR_lin - 1 = %.2f\n\n',Psn2/Pn - SNR - 1)

% figure;
% subplot(211)
% plot(x)
% subplot(212)
% plot(y)