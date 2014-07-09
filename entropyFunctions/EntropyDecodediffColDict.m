function  [GAMMAdiffCol] = EntropyDecodediffColDict(code,counts,level,Kpar)
    m = 3;
    n = level;
    GAMMAdiffCol = cell(m,n);
    LENCELL      = cell(m,n);
    
    LEN = 0 ;
    for j=1:n
        for i=1:m
            LENCELL{i,j} = DictSize(j,Kpar);
            LEN = LEN + LENCELL{i,j};
        end
    end

    
    dseq = arithdeco(code,counts,LEN);
    dseq = dseq-1;
    
    ptr =1;
    for j=1:n
        for i=1:m   
             TMPLEN = LENCELL{i,j};
             GAMMAdiffCol{i,j} = dseq(ptr:ptr+TMPLEN-1);
             ptr=ptr+TMPLEN;        
        end
    end

end

