function [signal, timeaxis,time_end,fs] = read_png( png_image )

drawplot = 0;

spectrogram_image = imread(png_image);
spectrogram_image = rgb2gray(spectrogram_image);
spectrogram_image = abs((255-spectrogram_image));

% Double the spectrogram (positive and negative frequencies)
spectrogram_image_flipped = flip(spectrogram_image(2:end,:));
spectrogram_image_complete = [spectrogram_image; spectrogram_image_flipped];

% Define the time and frequency axis ranges
time_start = 0;         % Start time in seconds
time_end = 1;           % End time in seconds
frequency_start = 0;    % Start frequency in Hz
frequency_end = 25e3;   % End frequency in Hz

% Determine the number of time frames and frequency bins
[num_freq_bins, num_time_bins] = size(spectrogram_image_complete);

% Calculate the time and frequency resolutions
time_resolution = (time_end - time_start) / num_time_bins;
frequency_resolution = (frequency_end - frequency_start) / num_freq_bins;

% Initialize the time-domain signal
signal_length = round((time_end - time_start) / time_resolution) * round((frequency_end - frequency_start) / frequency_resolution);
reconstructed_signal = zeros(1, signal_length );

% Perform the Inverse Short-Time Fourier Transform
for t = 1:num_time_bins
    
    % Extract the spectrogram data for the current frame
    spectrogram_frame = spectrogram_image_complete(:, t);
    
    % Calculate the time corresponding to this frame
    current_time = (t - 1) * time_resolution * num_freq_bins;
    
    % Calculate the time-domain signal for this frame
    frame_signal = ifft(spectrogram_frame, num_freq_bins);
    
    % Reconstruct the signal
    start_index = round(current_time / time_resolution) + 1;
    end_index = start_index + num_freq_bins - 1;
    
    reconstructed_signal(start_index:end_index) = frame_signal;
    
end

% Time axis
timeaxis = linspace(time_start, time_end, length(real(reconstructed_signal)));
% Sampling frequency
fs = 1/(timeaxis(2) - timeaxis(1));

signal = real(reconstructed_signal);

if drawplot
    % Time and frequency axis
    timeaxis_orig = linspace(time_start, time_end, num_time_bins);
    freqaxis_orig = linspace(frequency_start, frequency_end, num_freq_bins/2);

    % Plot spectrogram
    figure;
    mesh(timeaxis_orig,freqaxis_orig*10^-3,spectrogram_image);
    xlabel('Time[s]');
    ylabel('Frequency[kHz]');
    title('Spectrogram');
    
    % Plot the reconstructed signal
    figure;
    plot(timeaxis, real(reconstructed_signal));
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Reconstructed Time-Domain Signal');% Time and frequency axis
    timeaxis = linspace(time_start, time_end, num_time_bins);
    freqaxis = linspace(- frequency_end, frequency_end, num_freq_bins);
    
    % Spectrogram of reconstructed signal
    window_len = num_time_bins;
    overlapping = 0;
    freq_resolution = num_freq_bins;
    
    % figure;
    % spectrogram(real(reconstructed_signal),window_len,overlapping,freq_resolution,fs,'yaxis');
    
    % Spectrogram with stft
    [s,w,t] = stft(real(reconstructed_signal),fs,'Window',hamming(window_len,"periodic"),'OverlapLength',overlapping,'FrequencyRange',"onesided");
    figure;
    mesh(t,w*10^-3,abs(s));
end

end