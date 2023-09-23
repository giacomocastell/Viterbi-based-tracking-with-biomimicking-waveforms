% % Chirp spectrogram and loss model

clc;
clear;

%% Parameters

tau = 10e-3;                        % Duration of the pulse (1ms)
fs = 150e3;                         % Sampling frequency (100kHz)
t = 0:1/fs:tau-1/fs;                % Time axis
fstart = 18e3;                      % Start frequency (18kHz)
fend = 34e3;                        % End frequency (34kHz)
B = fend - fstart;                  % Bandwidth [kHz]
n = fs*tau;                         % Number of samples
freqaxis = (0:n-1)*fs/n;            % Frequency axis

%% Chirp
        
ch = chirp(t,fstart,tau,fend);
% plot(t,ch);

chfft = fft(ch,n);

figure;
plot(freqaxis*10^-3,mag2db(abs(chfft))-mag2db(max(abs(chfft))));
title('Normalized spectrum');
xlabel('Frequency [kHz]');
ylabel('Normalized amplitude [dB]');
% xticks(-50:10:50);

figure;
plot(freqaxis*10^-3,angle(chfft));
title('Normalized spectrum');
xlabel('Frequency [kHz]');
ylabel('Phase [rad]');
% xticks(-50:10:50);

window_len=100;
overlapping=95;

% [~,f,t,p] = spectrogram(y,100,80,100,fs);

figure;
spectrogram(ch,window_len,overlapping,1500,fs,'yaxis');
title('Spectrogram');
clim([-70 -40]);
ylim([15 40]);
% xlabel('Frequency [kHz]');
% ylabel('Phase [rad]');

%% Attenuation model

% See Seghal(2009) and Harris(2010)

% Code at https://it.mathworks.com/matlabcentral/fileexchange/25215-the-matlab-code-for-absorption-coefficient-in-underwater-wireless-communication-networks?s_tid=gn_loc_drop

maxFreq = 1000; % [kHz]

af=[];
for f=0.01:0.1:maxFreq
    af1=(0.11*f*f)/(1+(f*f));
%     af2=0.011*f*f;            % --> up to 400 Hz
    af2=(44*f*f)/(4100+(f*f));
%     af3=0;
    af3=2.75*(10^(-4))*f*f;
    af4=af1+af2+af3+0.003;
    af=[af af4];
end

f=0.01:0.1:maxFreq;
plot(f,af,'m');
grid on;
xlabel('frequency(khz)')
ylabel('absorption coefficient(db/km)')

% l=linspace(0.1,2,ln);
l = [.1 1 10 50 100];

p=1.5;
att=zeros(size(l,2),size(af,2));

for i=1:size(l,2)
    att(i,:) = l(i)*af + p*10*log10(l(i)*10^3);     % Att(f,l) = alpha^l * l^p --> l*alpha + p*10log(l) in dB --> [dB/km]*[km], [log10(m)]
end

figure;
plot(f,att);
grid on;
xlabel('frequency(kHz)')
ylabel('Attenuation(dB)')

%% Link budget

Atx = 1;                                            % Amplitude of transmitted signal [Pa]
sel=1;
d = l(sel);                                           % Receiver distance [km]
eta = 0.1;                                          % Loss factor

% Dahl(2007)--> Sound Pressure Level (SPL)
% Coates book
% Medwin book

% ptx = sqrt(sum(Atx*ch.^2)/size(ch,2));            % Root-mean-square pressure [Pa]
ptx=rms(Atx*ch);

c = 1500;                                           % Speed of sound in water [m/s]
rho = 1000;                                         % Density of water [kg/m^3]
sigma = c*rho;                                      % Acoustic impedance [Rayls]

Itx = (ptx*ptx)/sigma;                              % Acoustic intensity [W/m^2]

pref = 1e-6;                                        % Reference rms for water [uPa] 
SL = 20*log10(ptx/pref);                            % Source level: Sound Pressure Level (SPL) at the source [dB re uPa] --> with respect to reference (water) where p_ref = 1 [uPa]

% Harris(2010)

a=att(sel,f==f(1)+fstart*10^-3);                      % Attenuation for specific frequency and distance d
s=0;                                                % Ship parameter [0 to 1]
w=0;                                                % Wind speed [m/s]

Nt = 17-30*log10(f);
Ns = 40+20*(s-0.5)+26*log10(f)-60*log10(f+0.03);
Nw = 50+7.5*sqrt(w)+20*log10(f)-40*log10(f+0.4);
Nth = -15+20*log10(f);
N = 10.^(Nt/10) + 10.^(Ns/10) + 10.^(Nw/10) + 10.^(Nth/10); % Noise PSD
NdB=10*log10(N);

AN = -(att+NdB);                                            % AN product
% figure;plot(f,AN);xlim([0 20]);ylim([-170 -70]);

SPLrx = SL-a;                                               % SPL at the object

SPLbs = 10*log10(eta) + SPLrx;                              % Backscattered power pbs=eta*prx

SPLfin = SPLbs-a;                                           % Received power [dB re uPa]
SNR = SPLfin-NdB(fstart*10^-3+f(1)==f);                     % Link budget analysis

prx = 10^(SPLfin/20)*pref;                                  % Received root-mean-square pressure [Pa]
Arx = (size(ch,2)*prx)/(sum(ch.^2));                        % Receved amplitude

% Hebbar(2020) 
% Aydin(2020)
% Khan(2014)-Modeling of Acoustic Propagation Channel in Underwater Wireless Sensor Networks 
% Underwater acoustic networks (Proakis)
% Dahl(2007)-Underwater ambient noise

%% Ambiguity function

prf=1000;

% [afmag,delay] = ambgfun(Atx*ch,Arx*ch,fs,[prf,prf],"Cut","Doppler");
[afmag,delay] = ambgfun(Atx*ch,fs,prf,"Cut","Doppler");

figure;
plot(delay,20*log10(afmag/max(afmag)))
xlim([-0.0005 0.0005])


% [afmag,delay,doppler] = ambgfun(Atx*ch,fs,[PRF,PRF],"Cut","Doppler");
% [afmag,delay,doppler] = ambgfun(ch,fs,PRF,'Cut','Doppler');