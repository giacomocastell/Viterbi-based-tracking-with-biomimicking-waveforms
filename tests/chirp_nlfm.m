% % Generate a chirp signal with siunsoidal time-frequency

clear;
fs = 96e3;

t = (0:4*fs-1)/fs;

T = 1;

fChirp = 5e3 + 3e3*sin(2*pi*t/T);
wChirp = cumsum(fChirp)/fs;

myChirp = cos(2*pi*wChirp);

spectrogram(myChirp,512,256,1024,fs,'yaxis')
