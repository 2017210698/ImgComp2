function Cd = arithdecoCell(Ce)
   % Decode Ce
    Ecode  = Ce.Ecode;
    counts = Ce.Epar.counts;
    trans  = Ce.Epar.trans;
    len    = Ce.Epar.len;   
    nzInd  = Ce.Epar.nzInd;
    
    Diffnz = zeros(1,len);
    if(length(counts)>1)
            Dseq = arithdeco(Ecode,counts,len);
        for i=1:length(trans)
           ind = Dseq==i;
           Diffnz(ind) = trans(i);
        end
    elseif(length(counts)==1)
        Diffnz(1:end)=trans(1)';
    end

    % reconsturct Diff form Diffnz and nzInd
    % reminder: last index of nzInd is length of Diff
    DiffRe = zeros(1,nzInd(end));
    ind    = 1;
    for i = 1:length(DiffRe)
        if(i==nzInd(ind))
            DiffRe(i)=Diffnz(ind); 
            ind=ind+1;
            if(ind==length(nzInd)) % last index is original size
                break;
            end
        end
    end
    
    
    
    Cd.Diff = DiffRe;
    Cd.Dpar = Ce.Dpar;
    Cd.Qpar = Ce.Qpar;
end

 