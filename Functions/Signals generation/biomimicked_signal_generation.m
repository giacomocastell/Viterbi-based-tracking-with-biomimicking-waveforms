%%%%
%%%% Generate biomimicked signal
%%%%

function [xinv,tinv,xinv_orig,tinv_orig,message,tau,fs] = biomimicked_signal_generation( path, signal, mu, var, scenario_settings )
    
    drawplot = 0;

%     filesdir = strcat(path,'*.wav');
%     files=dir(filesdir);
    [y,fs] = audioread(fullfile(path,strcat(signal,'.wav')));

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
    
    % Gaussian smoothing function
    gauss = @(x,a,b,c) a*exp(-(((x-b).^2)/(2*c.^2)));
    amp = 1; 
    g = gauss(w, amp, mu, var);
    
    sgauss=zeros(size(s));
    smax=zeros(size(s));
    wmax=zeros(1,size(s,1));
    
    % Keep only max of each time bin
    for i=1:length(t)                   % For each time
        
        sgauss(:,i)=(s(:,i)).*g;        % Apply gaussian filter
        [~,Midx]=max(sgauss(:,i));      % Find index of max
        wmax(i)=w(Midx);                % Frequency selected
        smax(Midx,i)=sgauss(Midx,i);    
    end    
    
    % Encode data eventually
    if scenario_settings.encode_data_bits
        sorig = smax;
        [smax,message] = encodeDataBits(smax, length(t));
        [xinv_orig,tinv_orig] = istft(sorig,fs,'Window',hamming(window_len,'periodic'),'OverlapLength',overlapping,'FrequencyRange',"onesided");
    else
        xinv_orig = y;
        tinv_orig = t;
        message = zeros(length(t),1);
    end

    % % Invert spectrogram
    [xinv,tinv] = istft(smax,fs,'Window',hamming(window_len,'periodic'),'OverlapLength',overlapping,'FrequencyRange',"onesided");
    
    if drawplot
        figure;
        plot(tinv,xinv);
        title('Time domain');
        figure;
        subplot(121);
        spectrogram(xinv,window_len,overlapping,freq_resolution,fs,'yaxis');
        title('Spectrogram of processed signal');
        subplot(122);
        spectrogram(y,window_len,overlapping,freq_resolution,fs,'yaxis');
        title('Spectrogram of original signal');
    end

%     xinv = xinv(4745:58085);
%     xinv = xinv(6964:end);
    tinv = tinv(1:length(xinv));
    tau = tinv(end);
    
    xinv = xinv';
    tinv = tinv';

    xinv_orig = xinv_orig';
    tinv_orig = tinv_orig';


end