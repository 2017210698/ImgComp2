function [GAMMAval] = EntropyDecodeVals(code,counts,len,countsBins,level)
    m = 3;
    n = level;
    GAMMAval = cell(m,n);
    for i=1:m
        for j=1:n
            GAMMAval{i,j} = EntropyDecodeValsTOP(code{i,j},counts{i,j},len{i,j},countsBins);
        end
    end
end

function [GAMMAval] = EntropyDecodeValsTOP(code,counts,len,countsBins)
    
    if(len>1)
    % de quantize counts
    probLOGQ   = counts; 
    probLOGRE  = probLOGQ/(countsBins-1);
    probRE     = 2.^(probLOGRE*13.3);
    counts     = round(probRE)+1;
    
    dseq = arithdeco(code,counts,len);
    
%     
%     headptr =1;
%     tailptr =1;
%     for j=1:n
%         for i=1:m
%             while(dseq(headptr)~=bins+1)
%                 headptr=headptr+1;
%             end
%             GAMMAval{i,j} = dseq(tailptr:headptr-1);
%             headptr=headptr+1;
%             tailptr=headptr;           
%         end
%     end
    
    GAMMAval= dseq;  
    elseif(len==1)
        GAMMAval = bin2dec(sprintf('%d',code));
    elseif(len==0)
        GAMMAval = code;
    end
end