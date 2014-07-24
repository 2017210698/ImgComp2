function [A,err] = TrainDict(B,Kpar,level)
    PSNR    = Kpar.trainPSNR; 
    [X,m]   = GetPatches(B,level);
    if(level<3)
        TdictMaxAtoms = Kpar.dictBigMaxAtoms;
        Rtmp     = Kpar.Rbig;
    else
        TdictMaxAtoms = Kpar.dictSmallMaxAtoms;
        Rtmp     = Kpar.Rsmall;
    end
    R       = DictRedundancy(Rtmp,m); % dictionary reduandancy
    dictLen = round(R*m);
    params2d.iternum = Kpar.iternum;
    params2d.data = X;                                
    params2d.initA = speye(dictLen);              
    params2d.basedict{1} = odctdict(sqrt(m),sqrt(dictLen));   
    params2d.basedict{2} = odctdict(sqrt(m),sqrt(dictLen));         
     
    % Train each patch under TargetPSNR ->MSE->Edata
    params2d.Tdict   = TdictMaxAtoms;  
    MSE = 255^2*10^(-PSNR/10);
    params2d.Edata = sqrt(MSE*m); 
    
    % Sparse KSVD RUN
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
end

function [X,m] = GetPatches(B,level)
    
if(level<3)
    pSize = PatchSize(level);%8
    X = im2col(B,[pSize pSize],'distinct');
else
    pSize = PatchSize(level);%4
    X = im2col(B,[pSize pSize],'sliding');
    while(length(X)<4*pSize^2)
        X = [X,X]; %#ok<AGROW>
    end
end
    m = pSize^2;
end
