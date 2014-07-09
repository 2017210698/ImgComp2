function [GAMMAdiffRow ] = EntropyDecodediffRow(code,counts,GAMMARowStart,GAMMAval,level)
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
  
    dseq = arithdeco(code,counts,LEN);
    
    ptr =1;
    for j=1:n
        for i=1:m   
             TMPLEN = LENCELL{i,j};
             GAMMAdiffRow{i,j} = dseq(ptr:ptr+TMPLEN-1);
             ptr=ptr+TMPLEN;        
        end
    end
end

