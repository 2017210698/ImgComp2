function [GAMMA] = OMPcells(Coef,Dict,Wpar,Kpar)
    fprintf('**********GOMP RUN**********\n');
    level   = Wpar.level;
    COEF  = zeros(8);
    for j=level:-1:1
            COEF = [COEF,Coef{1,j}];           %#ok<AGROW>
            COEF = [COEF;Coef{2,j},Coef{3,j}]; %#ok<AGROW>
    end
    
    GAMMA   = cell(1,1);
    PSNR    = Kpar.targetPSNR;
    MSE     = 255^2*10^(-PSNR/10);
    band = {'H','V','D'};

    if(Kpar.gomp_test) ;figure; suptitle('GOMP run test');end
        name    =  'ALL';
        Im      =  COEF;
        [X,m]   =  Im2colgomp(Im,1);
        Rtmp = Kpar.Rbig;
        R       =  DictRedundancy(Rtmp,m); % dictionary reduandancy
        dictLen =  round(R*m);

        phi = kron(odctdict(sqrt(m),sqrt(dictLen)),odctdict(sqrt(m),sqrt(dictLen)));
        DD  = phi*Dict{1,1}; % Xr = phi*A*Gamma;
        epsilon = sqrt(MSE*numel(X));
        % GOMP RUN
        GAMMA{1,1} = gomp(DD,X,'error',epsilon);

        % plot reconstruction results
        if(Kpar.gomp_test)
           Xr   = DD*GAMMA{1,1};
           pMSE  = norm(Xr-X,'fro')^2/numel(X);
           fprintf('GOMP for %s MSE:%.4f nnz(GAMMA):%d::%d\n',name,pMSE,nnz(GAMMA{1,1}),numel(GAMMA{1,1}));
           ImRe  = col2im(Xr,[sqrt(m) sqrt(m)],size(Im),'distinct');
                  subplot(1,1*2,1*2-1);imshow(Im,[]);title(sprintf('Original %s',name));
                  subplot(1,1*2,1*2);imshow(ImRe,[]);title(sprintf('Reconstruction mse%.4f',pMSE));
        end
end

function [X,m] = Im2colgomp(Im,level)
    pSize = PatchSize(level);
    X = im2col(Im,[pSize pSize],'distinct');
    m = pSize^2;
end