% % Perform link budget analysis over chirp signal

clc;
clear all;

%% Read data

% path = '/home/giacomocastell/Desktop/TESI/Biomimicking_dataset/Original/';
path = '/home/giacomocastell/Desktop/TESI/Codes/Data/Waveforms/biomimicking/';

% filesdir = strcat(path,'*.wav');
% files=dir(filesdir);
% [y,fs] = audioread(fullfile(path,files(4).name));

filename = 'dolphin';

% filename = 'Beaked_Whale';
% filename = 'Dolphin';
% filename = 'Humpback_Whale';
% filename = 'Orca';
% filename = 'Sea_Lion';
[y,fs] = audioread(fullfile(path, strcat(filename,'.wav')));

%% Compute spectrogram

window_len = round(1e-2*size(y,1));
overlapping = round(0.95*window_len);
freq_resolution = 1024;

% figure;
% [s,w,t]=spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
[s,w,t]=stft(y,fs,'Window',hamming(window_len,"periodic"),'OverlapLength',overlapping,'FrequencyRange',"onesided");
% mesh(t,w,abs(s));

spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
% title('Spectrogram');
% caxis([-90 -50]);
% ylim([15 40]);


tau=size(y,1)/fs;                       % Duration of the pulse [s]
timeaxis=[0:1/fs:tau-1/fs];             % Original signal time axis
N=round(fs*tau);                        % Number of samples
freqaxis=[0:N-1]*fs/N;                  % Original signal frequency axis

%% Gaussian weighting of the spectrogram (1)

gauss = @(x,a,b,c) a*exp(-(((x-b).^2)/(2*c.^2)));
amp = 1; 
var = 1e3;
mu = 12e3;

g = gauss(w, amp, mu, var);

sgauss=zeros(size(s));
smax=zeros(size(s));
wmax=zeros(1,size(s,1));

for i=1:length(t)                   % For each time
    
    sgauss(:,i)=(s(:,i)).*g;        % Apply gaussian filter
    [~,Midx]=max(sgauss(:,i));      % Find index of max
    wmax(i)=w(Midx);                % Frequency selected
    smax(Midx,i)=sgauss(Midx,i);    
end 

[xinv,tinv] = istft(smax,fs,'Window',hamming(window_len,'periodic'),'OverlapLength',overlapping,'FrequencyRange',"onesided");

% % Visualize the spectrogram of reconstructed signal
figure;
spectrogram(xinv,window_len,overlapping,freq_resolution,fs,'yaxis');
figure;
spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');


%% Gaussian weighting of the spectrogram (2)

gauss = @(x,a,b,c) a*exp(-(((x-b).^2)/(2*c.^2)));
amp = 1; 
var = 1e3;
mu = 25e3;

g = gauss(w, amp, mu, var);

sgauss=zeros(size(s));
smax=zeros(size(s));
wmax=zeros(1,size(s,1));

for i=1:length(t)                   % For each time
    
%     [~,maxPtIdx]=max(s(endFreqidx:startFreqidx,i));
%     mu = w(maxPtIdx+endFreqidx);
%     y = gauss(w, amp, mu, var);
    
    sgauss(:,i)=(s(:,i)).*g;        % Apply gaussian filter
    [~,Midx]=max(sgauss(:,i));      % Find index of max
    wmax(i)=w(Midx);                % Frequency selected
    smax(Midx,i)=sgauss(Midx,i);    
end    

% % Invert spectrogram
[xinv,tinv] = istft(smax,fs,'Window',hamming(window_len,'periodic'),'OverlapLength',overlapping,'FrequencyRange',"onesided");

% % Visualize the spectrogram of reconstructed signal
figure;
spectrogram(xinv,window_len,overlapping,freq_resolution,fs,'yaxis');
figure;
spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
% stem(t,wmax)
% mesh(t,w,abs(smax));


%% Compute start time and frequency

[~,startTimeidx]=min(abs(t-0.1));            % Sweep start point in time (index)
startTime=t(startTimeidx);                   % Estimated sweep start in time [s]

[~,startFreqidx]=max(abs(s(:,startTimeidx)));
startFreq=w(startFreqidx);                   % Estimated sweep start frequency [Hz]

endTimeidx=length(t);                   % Sweep start point in time (index)
endTime=t(end);                         % Estimated sweep end in time [s]

[~,endFreqidx]=max(abs(s(50:end,endTimeidx)));
endFreq=w(50+endFreqidx);               % End of the sweep [Hz]

HB = (endFreq-startFreq);               % Half bandwidth [Hz]
c=HB/(2*tau);                           % Chirp rate [Hz/s]

tm=startTime:1/fs:endTime-1/fs;         % Time axis mimicked signal
% fq=[0:length(tm)-1]*fs/length(tm);      % Frequency axis

%% Analytical waveform

A = abs(s(endFreqidx,endTimeidx));  % Signal amplitude

% Linear
v=2*tm;
eta=tm.^2;

% Hyperbolic
% v=1./tm;
% eta=log(tm);

alpha = sqrt(abs(v));
x = A*alpha.*exp(1i*2*pi*(c*eta + startFreq*tm));   % Compute complex signal: Elmoslimany(2016)
xr = real(x);                                       % Obtain real part

toZeroPad=zeros(length(y)-length(x),1)';            % Zero pad to shift the start of the sweep
xp = [toZeroPad xr];

% fx=fft(xp,length(xp));                              % Compute spectrum
% figure;
% plot(freqaxis,abs(fx));

figure;
spectrogram(xp,window_len,overlapping,freq_resolution,fs,'yaxis');
% clim([-60 -40]);
figure;
spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
% clim([-80 -40]);
