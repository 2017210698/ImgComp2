function [GAMMAdiffRow ] = EntropyDecodediffRow(code,counts,GAMMARowStart,GAMMAval,countsBins,level)
    
    m = 3;
    n = level;
    GAMMAdiffRow = cell(m,n);
    LENCELL      = cell(m,n);

    LEN = 0 ;
    for j=1:n
        for i=1:m
            LENCELL{i,j} = length(GAMMAval{i,j})-length(GAMMARowStart{i,j});
            LEN = LEN + LENCELL{i,j};
        end
    end
    if(LEN~=0)
        % de quantize counts
        probLOGQ   = counts; 
        probLOGRE  = probLOGQ/(countsBins-1);
        probRE     = 2.^(probLOGRE*13.3);
        counts     = round(probRE)+1;

        dseq = arithdeco(code,counts,LEN);
    end
    
    ptr =1;
    for j=1:n
        for i=1:m   
             if(LEN~=0)
                 TMPLEN = LENCELL{i,j};
                 GAMMAdiffRow{i,j} = dseq(ptr:ptr+TMPLEN-1);
                 ptr=ptr+TMPLEN;        
             else
                 GAMMAdiffRow{i,j} = zeros(1,0);
             end
        end
    end
end

