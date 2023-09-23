%%%% 
%%%% Read airgun signal
%%%% 

function [x, t, tau, fs] = read_airgun_signal( path )

drawplot = 0;

M = readmatrix( path );
t = M(:,1).';
x = M(:,2).';

tau = t(end);
fs = (length(t) - 1)/tau;

if drawplot 
    
    xfft = fft(x,length(x));
    freq = fs*(0:length(x)/2-1)/length(x);

    subplot(211);
    plot(t, x);
    xlabel('Time [s]');
    ylabel('Magnitude');

    subplot(212);
    plot(freq, mag2db(abs(xfft(1:floor(length(x)/2)))/(max(abs(xfft(1:floor(length(x)/2)))))));
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    title('Normalized spectrum');
end

end