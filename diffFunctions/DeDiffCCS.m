function [GAMMArow,GAMMAcol] = DeDiffCCS(GAMMAdiffCol,GAMMARowStart,GAMMAdiffRow)
    
    GAMMArow = cell(size(GAMMAdiffCol));
    GAMMAcol = cell(size(GAMMAdiffCol));
    
    mm    = size(GAMMAcol,1);
    level = size(GAMMAcol,2);
    % for all GAMMA cells
    for i=1:mm
        for j=1:level
            DIFCOL = GAMMAdiffCol {i,j};
            DIF    = GAMMAdiffRow {i,j};
            START  = GAMMARowStart{i,j};
            
            DIFCOLT = DIFCOL(DIFCOL~=0); 
            NNZ     = sum(DIFCOL);
            ROW     = zeros(1,NNZ);
            
            iter = 1;
            iter2= 1;
            for k=1:length(DIFCOLT)
                % recover TMPROW
                TMPROW = zeros(1,DIFCOLT(k));
                TMPROW(1) = START(k);
                for t=2:length(TMPROW)
                    TMPROW(t)=TMPROW(t-1)+DIF(iter);
                    iter=iter+1;
                end
                % insert TMPROW to ROW
                for t=1:length(TMPROW)
                    ROW(iter2)=TMPROW(t);
                    iter2=iter2+1;
                end
            end
            % recover COL
            COL = zeros(1,length(DIFCOL)+1);
            COL(1) = 1;
            for t=2:length(COL)
                COL(t) = COL(t-1)+DIFCOL(t-1);
            end
            
            GAMMArow{i,j} = ROW;
            GAMMAcol{i,j} = COL;
        end
    end


end

