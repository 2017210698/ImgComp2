function [ NewR ] = DictRedundancy(R,m)
    % m is the patch size m = numel(patch)
    NewR = (floor(sqrt(R*m)))^2/m;
end

