%%%%
%%%% Remove all zeros before and after the correlation results
%%%%

function [firstNonzeroIndex, lastNonzeroIndex] = remove_zero_padding (correlation_result)

    % Find the indices of nonzero elements
    indices = find(correlation_result ~= 0);

    if isempty(indices)
        warning('No nonzero elements found in the correlation.');
        
        firstNonzeroIndex = 1;
        lastNonzeroIndex  = length(correlation_result);
    else
        firstNonzeroIndex = indices(1); 
        lastNonzeroIndex  = indices(end);
    end

    % firstNonzeroIndex=1;
    % lastNonzeroIndex  = length(correlation_result);
    % Update correlation and spatial reference
  
end