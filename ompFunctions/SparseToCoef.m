function   [Coef]  = SparseToCoef(GAMMA,Dict)
    mm   = size(GAMMA,1); % bands
    nn   = size(GAMMA,2); % wavelt levels
    Coef = cell(mm,nn);
    for j = 1:nn
        for i=1:mm
            m          = patchSize(j);
            dictLen    = size(GAMMA{i,j},1);
            phi        = kron(odctdict(sqrt(m),sqrt(dictLen)),odctdict(sqrt(m),sqrt(dictLen)));
            DD         = phi*Dict{i,j}; % Xr = phi*A*Gamma;
            X          = DD*GAMMA{i,j};
            Coef{i,j}  = col2Imgomp(X,m);
        end
    end
end


function [Im] = col2Imgomp(X,m)
    pSize = sqrt(m);
    oSize = sqrt(numel(X));
    Im = col2im(X,[pSize pSize],[oSize oSize],'distinct');
end

function m = patchSize(level)
    if(level<3)
        m = 64;
    else
        m = 16;
    end
end