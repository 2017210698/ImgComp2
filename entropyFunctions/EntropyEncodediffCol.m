function [code,probLOGQ] = EntropyEncodediffCol(GAMMA,MAXGAMMADIFFCOL,countsBins) 
    m=size(GAMMA,1);
    n=size(GAMMA,2);
    
    GAMMACONT = [];
    for j=1:n
        for i=1:m
             GAMMACONT=[GAMMACONT ,GAMMA{i,j}];   %#ok<AGROW>
        end
    end
    
    % probabilties calc
    countsTmp = zeros(1,MAXGAMMADIFFCOL+1); % ** initiate to ones for zeros are not allowed
    GAMMACONT = GAMMACONT+1;
    for i=1:length(GAMMACONT);
        countsTmp(GAMMACONT(i)) = countsTmp(GAMMACONT(i))+1;
    end
     
    prob = countsTmp/max(countsTmp)*10000+2;
    countsNQ = countsTmp+1;
    
    % probabilties quantization
    probLOG  = log2(prob)/max(log2(prob));
    probLOGQ = round(probLOG*(countsBins-1));
    
    probLOGRE  = probLOGQ/(countsBins-1);
    probRE     = 2.^(probLOGRE*13.3);
    counts     = round(probRE)+1;
    

    % entropy coding
    code = arithenco(GAMMACONT,counts);
%     old_code = arithenco(GAMMACONT,countsNQ);
%     
%     bins  = MAXGAMMADIFFCOL;
%     SAVED = (bins+1)*2-(bins+1)*log2(countsBins)/8;
%     fprintf('****Entropy Code DiffCol****\n');
%     fprintf('  length(code):    %g\n  length(old_code):%g\n  LOST:            %g Byte\n  SAVED:           %g Byte, REMOVE(CPU HEAVY)\n',...
%              length(code),length(old_code),(length(code)-length(old_code))/8,SAVED);
end