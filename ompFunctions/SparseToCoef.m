function   [Coef]  = SparseToCoef(GAMMA,Dict)
    mm   = size(GAMMA,1); % bands
    nn   = size(GAMMA,2); % wavelt levels
    Coef = cell(mm,nn);
    for j = 1:nn
        for i=1:mm
            m          = PatchSize(j);
            dictLen    = size(GAMMA{i,j},1);
            phi        = kron(odctdict(m,sqrt(dictLen)),odctdict(m,sqrt(dictLen)));
            DD         = phi*Dict{i,j}; % Xr = phi*A*Gamma;
            X          = DD*GAMMA{i,j};
            Coef{i,j}  = col2Imgomp(X,m,j);
        end
    end
end


function [Im] = col2Imgomp(X,m,j)
    global Gpar;
    pSize = m;
%     oSize = WaveImSize(Gpar.mIm,Gpar.nIm,j);
    Im = col2im(X,[pSize pSize],[512 512],'distinct');
end

