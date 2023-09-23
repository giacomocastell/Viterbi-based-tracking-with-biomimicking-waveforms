function Threshold = CalcTH(N, Pf)
%function Threshold = CalcTH(N, Pf)
%
% Desciption: 
%   The function calculates the threshold to the normalized matched filter
%
% Input:
%  N - number of samples in the reference symbol
%  Pf - false alarm probebility

TH = 1 / N: 1 / N: 1;
ProbF = [];
for Threshold = TH
    ProbF = [ProbF, 0.5 * (1 - betainc(Threshold ^ 2, 0.5, (N - 1) / 2))];
end

[E, ind] = min(abs(ProbF - Pf));
Threshold = TH(ind);

