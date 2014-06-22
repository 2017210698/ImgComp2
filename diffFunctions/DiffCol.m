function [GAMMAdiffCol,GAMMARowStart,GAMMAdiffRow] = DiffCol(GAMMArow,GAMMAcol)

    
    GAMMAdiffCol  = cell(size(GAMMArow));
    GAMMAdiffRow  = cell(size(GAMMArow));
    GAMMARowStart = cell(size(GAMMArow));
   

    mm    = size(GAMMAcol,1);
    level = size(GAMMAcol,2);
    
    % for all GAMMA cells
    for i=1:mm
        for j=1:level
            COL = GAMMAcol{i,j};
            ROW = GAMMArow{i,j};

            DIFCOL  = diff(COL);
            DIFCOLT = DIFCOL(DIFCOL~=0); 

            START  = zeros(1,length(DIFCOLT));
            DIF    = zeros(1,length(sum(DIFCOLT)-length(DIFCOLT)));

            iter  =1;
            iter2 =1;
            
            % obtain START DIF
            for k=1:length(DIFCOLT)
                % initialize tmp-row indices
                TMPROW = zeros(1,DIFCOLT(k));
                for t=1:DIFCOLT(k)
                   TMPROW(t) = ROW(iter);
                   iter      = iter+1;
                end
                % save start index
                START(k) = TMP(1);
                TMPD     = diff(TMP);
                % add diff to DIF vector
                for t=1:length(TMPD)
                    DIF(iter2)=TMPD(t);
                    iter2=iter2+1;
                end
            end
            GAMMAdiffCol {i,j} = DIFCOL;
            GAMMAdiffRow {i,j} = DIF;
            GAMMARowStart{i,j} = START;
        end
    end
end

