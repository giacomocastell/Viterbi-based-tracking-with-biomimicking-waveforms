clc;
clear;

tau = 10e-3;                        % Duration of the pulse (10ms)
fs = 100e3;                         % Sampling frequency (100kHz)
t = 0:1/fs:tau-1/fs;                % Time axis
f1 = 18e3;                          % Start frequency (18kHz)
f2 = 34e3;                          % End frequency (34kHz)
A = 1;
x = A*chirp(t,f1,tau,f2);

delay = 10;
tdel = t + delay;
x_long = [x zeros(1,1000)];
y = add_noise_model(x_long,10);

corr = xcorr(x,y);
% corr = NormCorrVer0(x,y,1,1);
group_delay = (length(x)-1)/(fs);

tcorr = t(1) + tdel(1) + (0:length(corr)-1) / fs- 2*group_delay;
plot(tcorr,corr);