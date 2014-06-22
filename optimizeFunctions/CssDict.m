function  [Dictval,Dictneg,Dictrow,Dictcol] = CssDict (Dict,DictNegSigns)  

    mm    = size(Dict,1);
    level = size(Dict,2); 
    Dictval      = cell(size(Dict));
    Dictneg      = cell(size(Dict));
    Dictrow      = cell(size(Dict));
    Dictcol      = cell(size(Dict));
    
    % for all Dict cells
    for i=1:mm
        for j=1:level
            % intial 
            DIC    = Dict{i,j};
            DICNEG = DictNegSigns{i,j};
            
            VALS   = zeros(1,nnz(DIC));
            NEGS   = zeros(1,nnz(DIC)); 
            ROW    = zeros(1,nnz(DIC));
            COL    = zeros(1,size(DIC,2)+1);
          
                
            valIter = 1;
            % modified CSS algo
            for jj=1:size(DIC,2)
                COL(jj)= valIter;
                for ii=1:size(DIC,1)
                    if(DIC(ii,jj)~=0)
                        VALS(valIter) = DIC(ii,jj);
                        NEGS(valIter) = DICNEG(ii,jj);
                        ROW (valIter) = ii;
                        valIter       = valIter+1;
                    end
                end
            end
            COL(end)=valIter;
            % return css form
            Dictval{i,j} = VALS;
            Dictneg{i,j} = NEGS;
            Dictrow{i,j} = ROW;
            Dictcol{i,j} = COL;
        end
    end

end

