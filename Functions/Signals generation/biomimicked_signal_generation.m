%%%%
%%%% Generate biomimicked signal
%%%%

function [xinv,tinv,tau,fs] = biomimicked_signal_generation( path )
    
    drawplot = 0;
%     currdir = cd;

    filesdir = strcat(path,'*.wav');
    files=dir(filesdir);
    [y,fs] = audioread(fullfile(path,files(1).name));

    % Compute spectrogram

    window_len = round(1e-2*size(y,1));
    overlapping = round(0.95*window_len);
    freq_resolution = 1024;
    
    % [s,w,t]=spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
    [s,w,t]=stft(y,fs,'Window',hamming(window_len,"periodic"),'OverlapLength',overlapping,'FrequencyRange',"onesided");
    
    tau=size(y,1)/fs;                       % Duration of the pulse [s]
    % timeaxis=[0:1/fs:tau-1/fs];             % Original signal time axis
    % N=round(fs*tau);                        % Number of samples
    % freqaxis=[0:N-1]*fs/N;                  % Original signal frequency axis

    gauss = @(x,a,b,c) a*exp(-(((x-b).^2)/(2*c.^2)));
    amp = 1; 
    var = 1e3;
    mu = 12e3;                                % To tune if use a new waveform
    
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
    
    if drawplot
        figure;
        subplot(121);
        spectrogram(xinv,window_len,overlapping,freq_resolution,fs,'yaxis');
        subplot(122);
        spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
    end
    xinv = xinv';
    tinv = tinv';
end