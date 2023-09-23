function [delayEst] = computeDelayFromChannel( channel )

persistent chirpTable chirpTableDone phaseResolution

% Assume chirp function
Fs = 100e3; %48e3;
Ts = 0.1;
f0 = 18e3; %7e3;
f1 = 34e3; %17e3; 
Fc = (f0+f1)/2;
W = f1 - f0;
t = linspace(0, Ts, Ts*Fs+1);
t(end) = [];

% Prepare phased chirp bank
if isempty(chirpTableDone)
    phaseResolution = 512;
    phaseList = 0 : pi/phaseResolution : (2*pi - 1e-6);
    chirpTable = createPhasedChirpBank(Ts,f0,f1,Fs,phaseList);
    chirpTableDone = true;
end

% Select threshold for fixed false alarm ratio
Pf = 1e-4;
TH = CalcTH(W*Ts, Pf);


%Bandpass conversion parameters
L = 128;  % BP filter length
B = 1.2*W;    % BPF band
bLPF = fir1(L, B/Fs);
Factor = 4;
FsBB = Fs/Factor;

% Reference signal and BB version
refSignal = chirp(t,f0,Ts,f1);
[refSignal_BB, ~, ~, ~] = ConvertToBBVer0(refSignal, Fc, Fs, Factor, bLPF);

% if 1
%     % Random CIR
%     randNtaps = 5;
%     randMaxDelay = 0.5; % [s]
%     channel = randomCIR(randNtaps, randMaxDelay, Fs);
% else
%     % Bellhop
% end

% Form received signal
signalRX = zeros(1,round(max(channel(:,1))*Fs+Ts*Fs));
for iTap = 1:size(channel,1)
    insIndex = round(channel(iTap,1)*Fs);
    signalRX(insIndex:insIndex+length(refSignal)) = chirpTable(:,mod(round(mod(angle(channel(iTap,2)),2*pi)/(2*pi)*phaseResolution),phaseResolution)+1).';
end

plot(signalRX)

% Actual signal and BB version
[signalRX_BB, ~, ~, ~] = ConvertToBBVer0(signalRX, Fc, Fs, Factor, bLPF);

% Normalized matched filter
MF = NormCorrVer0(signalRX_BB, refSignal_BB, 1, 1);
MF(isinf(MF))=0;
MF(isnan(MF))=0;

if 0
    tPlot = (0:length(MF)-1)/FsBB;
    plot(tPlot,abs(MF));
end

% Find peaks larger than threshold
loc = find(abs(MF) > TH);

% Find delay
delayEst = loc(1)/FsBB;



