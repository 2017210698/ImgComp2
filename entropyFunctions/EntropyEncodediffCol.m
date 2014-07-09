function [code,counts] = EntropyEncodediffCol(GAMMA,MAXGAMMADIFFCOL) 
    m=size(GAMMA,1);
    n=size(GAMMA,2);
    
    GAMMACONT = [];
    for j=1:n
        for i=1:m
             GAMMACONT=[GAMMACONT ,GAMMA{i,j}];   %#ok<AGROW>
        end
    end
    
    % probabilties calc
    counts = ones(1,MAXGAMMADIFFCOL+1); % ** initiate to ones for zeros are not allowed
    GAMMACONT = GAMMACONT+1;
    for i=1:length(GAMMACONT);
        counts(GAMMACONT(i)) = counts(GAMMACONT(i))+1;
    end
    
    code = arithenco(GAMMACONT,counts);
end