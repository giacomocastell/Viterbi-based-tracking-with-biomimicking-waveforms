clc;
clear;

addpath('example_images/');
spectrogram_image = imread('synth_diffgen_5.png');
spectrogram_image = rgb2gray(spectrogram_image);
% spectrogram_image = abs(im2double(255-spectrogram_image));

% Define the time and frequency axis ranges
time_start = 0;         % Start time in seconds
time_end = 1;           % End time in seconds
frequency_start = 0;    % Start frequency in Hz
frequency_end = 25000;  % End frequency in Hz

% Determine the number of time frames and frequency bins
[num_frames, num_bins] = size(spectrogram_image);

% Calculate the time and frequency resolutions
time_resolution = (time_end - time_start) / num_frames;
frequency_resolution = (frequency_end - frequency_start) / num_bins;

% Initialize the time-domain signal
signal_length = round((time_end - time_start) / time_resolution) + 1; % Add 1 to account for the last sample
reconstructed_signal = zeros(1, signal_length);

% Perform the Inverse Short-Time Fourier Transform (ISTFT)
for frame = 1:num_frames
    % Extract the spectrogram data for the current frame
    spectrogram_frame = spectrogram_image(frame, :);
    
    % Calculate the time corresponding to this frame
    current_time = (frame - 1) * time_resolution;
    
    % Calculate the time-domain signal for this frame
    frame_signal = ifft(spectrogram_frame, num_bins);
    
    % Apply overlap-and-add to reconstruct the signal
    start_index = round(current_time / time_resolution) + 1;
    end_index = start_index + num_bins - 1;
    
    % Ensure that the indices are within bounds
    if start_index <= signal_length && end_index <= signal_length
        reconstructed_signal(start_index:end_index) = ...
            reconstructed_signal(start_index:end_index) + frame_signal;
    end
end

% Plot or save the reconstructed signal
plot(linspace(time_start, time_end, signal_length), real(reconstructed_signal));
xlabel('Time (s)');
ylabel('Amplitude');
title('Reconstructed Time-Domain Signal');