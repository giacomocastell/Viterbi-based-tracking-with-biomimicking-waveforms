clc;
clear;

addpath('example_images/');
img = imread('synth_augsimple_1.png');

% first_channel = abs(255-img(:,:,1));
first_channel = abs(im2double(255-img(:,:,1)));
second_channel = img(:,:,2);
third_channel = img(:,:,3);

% Time axis reference
sigLen = 1;
time_resolution = sigLen/size(first_channel,1);
timeaxis = 0:time_resolution:sigLen-time_resolution;

% Freq axis reference
maxFreq = 25;
freq_resolution = maxFreq/size(first_channel,1);
freqaxis = 0:freq_resolution:maxFreq-freq_resolution;

imagesc(timeaxis,freqaxis,first_channel)


[ix,ti] = istft(first_channel,1/time_resolution,'Window',hamming(2,'periodic'),'OverlapLength',1);
[x,t] = istft(first_channel,1/time_resolution);
