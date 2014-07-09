function [code,counts] = EntropyEncodediffRow(GAMMA,bins) 
    m=size(GAMMA,1);
    n=size(GAMMA,2);
    
    GAMMACONT = [];
    for j=1:n
        for i=1:m
             GAMMACONT=[GAMMACONT ,GAMMA{i,j}];   %#ok<AGROW>
        end
    end
    
    % probabilties calc
    counts = ones(1,bins); % ** initiate to ones for zeros are not allowed
    for i=1:length(GAMMACONT);
        counts(GAMMACONT(i)) = counts(GAMMACONT(i))+1;
    end
    
    code = arithenco(GAMMACONT,counts);
end