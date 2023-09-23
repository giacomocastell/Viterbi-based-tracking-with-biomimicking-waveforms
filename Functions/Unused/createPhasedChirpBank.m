% Create phased chirp bank
function chirpTable = createPhasedChirpBank(Ts,f0,f1,Fs,phases)

t = linspace(0,Ts,Ts*Fs+1)';

chirpTable = zeros(length(t), length(phases));

for iPhase = 1:length(phases)
    chirpTable(:,iPhase) = chirp(t,f0,t(end),f1,'linear',phases(iPhase));
end
