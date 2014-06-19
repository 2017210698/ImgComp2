function   [Coef]  = SparseToCoef(GAMMA,Dict,Kpar)
    mm   = size(GAMMA,1);
    nn   = size(GAMMA,2);
    Coef = cell(mm,nn);
    for j = 1:nn
        for i=1:mm
            R          =  Kpar.R; % dictionary reduandancy
            m          = size(GAMMA{i,j},1)/R;
            dictLen    = size(GAMMA{i,j},1);
            phi        = kron(odctdict(sqrt(m),sqrt(dictLen)),odctdict(sqrt(m),sqrt(dictLen)));
            DD         = phi*Dict{i,j}; % Xr = phi*A*Gamma;
            Coef{i,j}  = DD*GAMMA{i,j};
        end
    end
end

