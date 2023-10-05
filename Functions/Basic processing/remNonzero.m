function [firstNonzeroIndex, lastNonzeroIndex] = remNonzero(vector)


% Start from first recorded nonzero element
indices = find(vector ~= 0);
if isempty(indices)
    warning('No nonzero elements found in the correlation.');
    firstNonzeroIndex = 1;
    lastNonzeroIndex = length(vector);
else
    firstNonzeroIndex = indices(1);
    lastNonzeroIndex = indices(end);
end


end