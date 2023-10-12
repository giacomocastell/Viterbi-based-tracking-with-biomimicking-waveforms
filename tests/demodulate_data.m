function [demodulated_message] = demodulate_data(signalTX,x)

xo = signalTX.biomimicking.x_original;
original_message = signalTX.biomimicking.message;
bias = 1;

fs = 96000;
window_len = 672;
overlapping = 638;
freq_resolution = 1024;

% figure;
% spectrogram(xo,window_len,overlapping,freq_resolution,fs,'yaxis');
% figure;
% spectrogram(x,window_len,overlapping,freq_resolution,fs,'yaxis');
% title('orig')

[so,~,~]=stft(xo,fs,'Window',hamming(window_len,"periodic"),'OverlapLength',overlapping,'FrequencyRange',"onesided");
[s,~,~]=stft(x,fs,'Window',hamming(window_len,"periodic"),'OverlapLength',overlapping,'FrequencyRange',"onesided");

sshift = s(:,1:length(so));

demodulated_message  = zeros(size(sshift,2),1);

for t=1:size(so,1)

    if nnz(s(:,t)) > 0
        [original,~] = remNonzero(real(so(:,t)));
        [encoded,~] = remNonzero(real(sshift(:,t)));
        if max(original) == max(encoded) - bias
            demodulated_message(t) = 0;
        elseif max(original) == max(encoded) + bias
            demodulated_message(t) = 1;
        else
            demodulated_message(t) = NaN;
        end
    end
end

end