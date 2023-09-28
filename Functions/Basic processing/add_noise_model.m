function [signal_plus_noise] = add_noise_model( signal, SNRdB )

% SNR to linear scale
SNRlin = 10^(SNRdB/10);

% Length of considered signal
L = length(signal);

% Calculate actual symbol energy
Esig=sum(abs(signal).^2)/(L); 

% Find the noise spectral density
N0=Esig/SNRlin; 

% Standard deviation for AWGN Noise
noiseSigma = sqrt (N0);

% Computed noise
n = noiseSigma*randn(1,L);

% Signal + noise
signal_plus_noise = signal + n;

% Noise energy
Pn = sum(abs(n).^2)/length(n);

% Signal + noise energy within same time interval
Psn = sum(abs(signal_plus_noise.^2)/length(signal_plus_noise));

if ~(abs(Psn/Pn - SNRlin - 1) < 1)

    warning('Noise specs not met');
    fprintf('\n (P{N+S})/P{N} - SNR_lin - 1 = %.2f (should be close to 0)\n\n',Psn/Pn - SNRlin - 1)

end

end