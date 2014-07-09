function [GAMMAval] = EntropyDecodeVals(code,counts,len,bins,level)
    m = 3;
    n = level;
    GAMMAval = cell(m,n);
    
    dseq = arithdeco(code,counts,len);
    
    headptr =1;
    tailptr =1;
    for j=1:n
        for i=1:m
            while(dseq(headptr)~=bins+1)
                headptr=headptr+1;
            end
            GAMMAval{i,j} = dseq(tailptr:headptr-1);
            headptr=headptr+1;
            tailptr=headptr;           
        end
    end
end