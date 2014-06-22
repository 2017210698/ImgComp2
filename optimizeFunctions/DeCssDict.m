function  [Dict,DictNegSigns] = DeCssDict (Dictval,Dictneg,Dictrow,Dictcol,Kpar)
    
    Dict         = cell(size(Dictval));
    DictNegSigns = cell(size(Dictval));
    
    mm    = size(Dictval,1);
    level = size(Dictval,2); 
    
    for i=1:mm
        for j=1:level
            VAL = Dictval{i,j};
            NEG = Dictneg{i,j};
            COL = Dictcol{i,j};
            ROW = Dictrow{i,j};
                                
            [m,n]  = DictSize(j,Kpar); 
  
            DIC    = zeros(m,n);
            DICNEG = zeros(m,n);
                      
            % De CSS
            valIter=1;
            for colIter =1:n
               while(valIter<COL(colIter+1))
                   DIC   (ROW(valIter),colIter)=VAL(valIter);
                   DICNEG(ROW(valIter),colIter)=NEG(valIter);
                   valIter=valIter+1;
               end
            end
 
             
            Dict{i,j}        = DIC;
            DictNegSigns{i,j} = DICNEG;
        end
    end

end

