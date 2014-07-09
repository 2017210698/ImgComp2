function [GAMMACONT] = Cell2CONT(GAMMA)
    m=size(GAMMA,1);
    n=size(GAMMA,2);
    
    % concat all GAMMA vals, bins+1 as separator
    GAMMACONT = [];
    for j=1:n
        for i=1:m
             GAMMACONT=[GAMMACONT ,GAMMA{i,j}];   %#ok<AGROW>
        end
    end
end 