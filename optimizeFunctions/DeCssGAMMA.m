function     [GAMMAq,GAMMANegSigns] = DeCssGAMMA(GAMMAval,GAMMAneg,GAMMArow,GAMMAcol,Kpar)
    GAMMAq        = cell(size(GAMMAval));
    GAMMANegSigns = cell(size(GAMMAval));
    
    mm    = size(GAMMAval,1);
    level = size(GAMMAval,2); 
    
    for i=1:mm
        for j=1:level
            VAL = GAMMAval{i,j};
            NEG = GAMMAneg{i,j};
            COL = GAMMAcol{i,j};
            ROW = GAMMArow{i,j};
           
            [m,n]  = GAMMASize(j,Kpar); 
  
            GAM    = zeros(m,n);
            GAMNEG = zeros(m,n);
                      
            % De CSS
            valIter=1;
            for colIter =1:n
               while(valIter<COL(colIter+1))
                   GAM   (ROW(valIter),colIter)=VAL(valIter);
                   GAMNEG(ROW(valIter),colIter)=NEG(valIter);
                   valIter=valIter+1;
               end
            end
 
             
            GAMMAq{i,j}        = GAM;
            GAMMANegSigns{i,j} = GAMNEG;
        end
    end
end

