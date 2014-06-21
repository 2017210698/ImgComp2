function     [GAMMAq,GAMMANegSigns] = DeCssGAMMA(GAMMAval,GAMMAneg,GAMMArow,GAMMAcol,GAMMAemptyCol,Kpar)


    GAMMAq        = cell(size(GAMMAval));
    GAMMANegSigns = cell(size(GAMMAval));
    
    mm    = size(GAMMAval,1);
    level = size(GAMMAval,2); 
    
    for i=1:mm
        for j=1:level
            VAL = GAMMAval{i,j};
            COL = GAMMAcol{i,j};
            ROW = GAMMArow{i,j};
            NEG = GAMMAneg{i,j};
                        
            [m,n]  = GAMMASize(512,512,j,Kpar); % TODO: use sizeGAMMA()
  
            GAM    = zeros(m,n);
            GAMNEG = zeros(m,n);
            
%             % modified CSS
%             if(GAMMAemptyCol{i,j})
%                 COL = zeros(1,n-length(GAMMAcol{i,j}));
%                 it1 =1;
%                 it2 =1;
%                 if(~isempty(GAMMAcol{i,j}))
%                     for k=1:n
%                        if(GAMMAcol{i,j}(it1)==k)
%                            if(it1<length(GAMMAcol{i,j}))
%                                 it1=it1+1;
%                            end
%                        else
%                            COL(it2) = k;
%                            if(it2<length(COL))
%                                 it2=it2+1;
%                            end
%                        end
%                     end
%                 else
%                     COL = 1:1:n;
%                 end
%             end
            
            % De CSS
 
            colIter = 1;
            rowIter = 1; 
            a=-1;
            b=-1;
            if(colIter==a);fprintf('sa\n');end
            if(rowIter==b);fprintf('sa\n');end
            while(1)
                if(isempty(VAL)); break;end;
                
                GAM   (ROW(rowIter),COL(colIter)) = VAL(rowIter);
                GAMNEG(ROW(rowIter),COL(colIter)) = NEG(rowIter);
                
                if(rowIter==length(ROW))
                    break;
                end
                
                if(ROW(rowIter)>=ROW(rowIter+1))
                    colIter=colIter+1;
                end
                rowIter=rowIter+1;    
             
            end
            GAMMAq{i,j}        = GAM;
            GAMMANegSigns{i,j} = GAMNEG;
        end
    end
end

