function  [GAMMAval,GAMMAneg,GAMMArow,GAMMAcol]= CssGAMMA(GAMMA,GAMMANegSigns)
% columns of GAMMA are not sparse! -> indcies of missing GAMMA colmuns
% GAMMAemptyCol -> denotes if GAMMAcol is the indicies of columns_ptr or
% missing columns ptr

    mm    = size(GAMMA,1);
    level = size(GAMMA,2); 
    GAMMAval      = cell(size(GAMMA));
    GAMMAneg      = cell(size(GAMMA));
    GAMMArow      = cell(size(GAMMA));
    GAMMAcol      = cell(size(GAMMA));
    
    % for all GAMMA cells
    for i=1:mm
        for j=1:level
            % intial 
            GAM    = GAMMA{i,j};
            GAMNEG = GAMMANegSigns{i,j};
            
            VALS   = zeros(1,nnz(GAM));
            NEGS   = zeros(1,nnz(GAM)); 
            ROW    = zeros(1,nnz(GAM));
            COL    = zeros(1,size(GAM,2));
          
                
            valIter = 1;
            colIter = 1;
            % modified CSS algo
            for jj=1:size(GAM,2)
                emptyColFlag = 1;
                for ii=1:size(GAM,1)
                    if(GAM(ii,jj)~=0)
                        VALS(valIter) = GAM(ii,jj);
                        NEGS(valIter) = GAMNEG(ii,jj);
                        ROW (valIter) = ii;
                        
                        valIter       = valIter+1;
                        emptyColFlag  = 0;
                    end
                end
                if(~emptyColFlag)
                    COL(colIter)= jj;
                    colIter     = colIter+1;
                end
   
            end
            COL = COL(1:colIter-1);
            % return css form
            GAMMAval{i,j} = VALS;
            GAMMAneg{i,j} = NEGS;
            GAMMArow{i,j} = ROW;
            GAMMAcol{i,j} = COL;
        end
    end

end

