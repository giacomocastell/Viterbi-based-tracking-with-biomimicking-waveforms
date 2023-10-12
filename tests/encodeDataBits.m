function [s_encoded, random_message] = encodeDataBits(s, timeBins)

% Randomly derive message to encode
random_message = randi([0, 1], 1, timeBins);

% Initialize encoded spectrogram
s_encoded = zeros(size(s));

bias = 2;

for t=1:timeBins

    if nnz(s(:,t)) > 0
        
        shiftsign = random_message(t);
        [nonzero_idx, ~] = remNonzero(s(:,t));

        if shiftsign
            s_encoded(nonzero_idx + bias,t) = s(nonzero_idx,t);

        else
            s_encoded(nonzero_idx - bias,t) = s(nonzero_idx,t);

        end    

    end    
end

end