function [A,err] = TrainDict(B,Kpar,level)
    PSNR    = Kpar.targetPSNR; 
    [X,m]   = GetPatches(B,level);
    R       = Kpar.R; % dictionary reduandancy
    perTdict= Kpar.perTdict;
    
    % eligable reduandancy
        NewR = (floor(sqrt(R*m)))^2/m;
        fprintf('Eligable Dictionary redudnacy for patch size:%d is R:%.4f\n',m,NewR);
    R = NewR;
    dictLen = R*m;
    params2d.iternum = Kpar.iternum;
    params2d.data = X;                                
    params2d.initA = speye(R*m);              
    params2d.basedict{1} = odctdict(sqrt(m),sqrt(dictLen));   
    params2d.basedict{2} = odctdict(sqrt(m),sqrt(dictLen));         
     
    % ask to train each patch under compression PSNR
    params2d.Tdict   = ceil(perTdict*dictLen);  
    MSE = 255^2*10^(-PSNR/10);
    params2d.Edata = sqrt(MSE*m); %TODO: ksvd experiment to verify that
    
    [A,~,err] = ksvds(params2d);
    if(max(isnan(full(A(:))))) 
        error('KSVD A output NaN for some indicies');
    end
    % print info on run
    if(Kpar.printInfo)
       	fprintf('**********KSVD RUN**********\n');
        fprintf('%s sub-band:\n imSize:%dx%d, patchSize:%d, patches:%d\n  trainPatches:%d, dictLen:%d, dictMaxRowAtoms=%d\n  nnz(A):%d, numel(A):%d, per=%.2f\n'...
                    ,Kpar.name...
                    ,size(B,1),size(B,2)...
                    ,m ...
                    ,numel(B)/m ...
                    ,size(X,2) ...
                    ,dictLen ...
                    ,params2d.Tdict ...
                    ,nnz(A) ...
                    ,numel(A) ...
                    ,nnz(A)/numel(A) ...
                    );                
    end
    % TODO: review if more plots needed to see convergence
end

function [X,m] = GetPatches(B,level)
if(level<3)
    pSize = 8;
    X = im2col(B,[pSize pSize],'distinct');
else
    pSize = 4;
    X = im2col(B,[pSize pSize],'sliding');
    while(length(X)<4*pSize^2)
        X = [X,X]; %#ok<AGROW>
    end
end
    m = pSize^2;
end
