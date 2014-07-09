function [MAX] = CELLARRMAX(GAMMA)
    MAX = -inf;
    for i=1:size(GAMMA,1)
        for j=1:size(GAMMA,2)
            MAX = max(MAX,max(GAMMA{i,j}));
        end
    end
end

