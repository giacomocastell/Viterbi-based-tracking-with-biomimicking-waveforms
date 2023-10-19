%%%%
%%%% Convert signal to baseband and perform low-pass filtering
%%%%

function [y_bb_downsampled,t_bb_downsampled]=baseband(y,t,fs,fc,cutoff_frequency,downsampling_factor)

drawplot = 0;

% Define modulating signal (cosine)
% t_mod = [0:1/fs:t(end)-t(1)];

modulating_sig = 2*exp(-1i*2*pi*fc*t);

% Bring received signal to base band
y_bb = y.*modulating_sig;

% Apply low-pass filter
filter_order = 120;
nyquist_frequency = fs/2;

b = fir1(filter_order, (cutoff_frequency/nyquist_frequency));                                      % Order 12 FIR LPF Fco = 35 Hz
y_filtered = filtfilt(b,1,y_bb);

if drawplot
    
    freq = fs*(0:length(y_bb)/2-1)/length(y_bb);
    Y = abs(fft(y));
    Y_bb = abs(fft(y_bb));
    YF_bb = abs(fft(y_filtered));

    figure;
    subplot(311);
    plot(freq*10^-3, mag2db(Y(1:length(Y)/2)));
    xlabel("Fequency [kHz]")
    ylabel("Magnitude [dB]")
    title("Original signal fft")
    subplot(312);
    plot(freq*10^-3, mag2db(Y_bb(1:length(Y_bb)/2)));
    xlabel("Fequency [kHz]")
    ylabel("Magnitude [dB]")
    title("Baseband signal fft")
    subplot(313);
    plot(freq*10^-3,mag2db(YF_bb(1:length(y_filtered)/2)));
    xlabel("Fequency [kHz]")
    ylabel("Magnitude [dB]")
    title("Filtered baseband signal fft")
end

% Downsample filtered baseband signal by a downsampling factor

y_bb_downsampled = downsample(y_filtered,downsampling_factor);
t_bb_downsampled = downsample(t,downsampling_factor);

% y_bb_downsampled = real(y_bb_downsampled);


end