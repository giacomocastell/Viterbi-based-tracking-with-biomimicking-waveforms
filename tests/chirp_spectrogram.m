clc;
clear all;

%% Parameters

A = 1;                                  % Signal amplitude

f1=18e3;                                % Start of the sweep [Hz]
f2=34e3;                                % End of the sweep [Hz]

fs=80e3;                                % Sampling frequency [Hz]
tau=100e-3;                             % Duration of the pulse [s]
N=round(fs*tau);                        % Number of samples

HB = (f2-f1);                           % Half bandwidth [Hz]
c=HB/(2*tau);                           % Chirp rate [Hz/s]

t=0:1/fs:tau-1/fs;                      % Time axis
f=[0:N-1]*fs/N;                         % Frequency axis

%% Waveform

% Linear
v=2*t;
eta=t.^2;

% % Hyperbolic
% v=1./t;
% eta=log(t);

alpha = sqrt(abs(v));
x = A*alpha.*exp(1i*2*pi*(c*eta + f1*t));

fx=fft(real(x),N);

figure;
plot(f,abs(fx))

figure;
spectrogram(x,100,80,100,fs,'yaxis')

%% NLFM

f1 = 12.5e3;
f2 = 10.5e3;



xNFM = exp(1i*2*pi*((c*t.^2) + f1*t));




