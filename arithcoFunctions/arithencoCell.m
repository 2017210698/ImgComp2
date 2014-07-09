function [Ecode,Epar] = arithencoCell(Diff)
    % sperate nnz
    % comuting nnzInd
    DiffLen  = length(Diff); %  index is original Length
    nzInd        = zeros(size(Diff));
    ind           = 1;
    % bulinding Diffnz
    for i=1:length(Diff)
          if(Diff(i)~=0)
              nzInd(ind)=i;
              ind = ind+1;
          end
    end
    nzInd(ind) = DiffLen; 
    nzInd   = nzInd(1:ind);
    Diffnz     = Diff(Diff~=0);
    fprintf('DEBUG: nzInd length:%d, size in file:%dB\n',length(nzInd),length(nzInd)*2);
        
    % entropy encoding
    Min    = min(Diffnz);
    Max    = max(Diffnz);
    seq    = zeros(size(Diffnz));
    counts = zeros(size(Diffnz));
    trans  = zeros(size(Diffnz));
    t = 1;
    for i = Min:1:Max
        ind       = Diffnz==i;
        if(max(ind))
            counts(t) = sum(ind);
            trans(t)  = i; 
            seq(ind)  = t;
            t = t+1;
        end
    end
    counts = counts(1:t-1);
    trans  = trans(1:t-1);
    len    = length(seq);
    if(length(counts)>1)
        Ecode = arithenco(seq,counts);
    elseif(length(counts)==1)
        Ecode = 0;
    end
    
    Epar.nzInd  = nzInd;
    Epar.counts = counts;
    Epar.trans  = trans;
    Epar.len    = len;
    
    % TODO : add over flow check
    Epar.header.field = {'nzInd','counts','trans','len'}; % trans type is 2*bins
    % TODO reduce size of nzInd type by partion to 8 bit series of 128
    Epar.header.type  = {'uint16','uint32','int64','uint32'}; %TODO : try to reduce and check overflow 
end