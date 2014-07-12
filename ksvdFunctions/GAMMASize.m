function [m,n]  = GAMMASize(level,Kpar)
    global Gpar;
    [mLev,nLev] = WaveImSize(Gpar.mIm,Gpar.nIm,level);
    pSize = PatchSize(level); % TOOD: should be dependad on [mLev,nLev]?
    mm = pSize^2;
    
    TMPIM = zeros(mLev,nLev);
    X = im2col(TMPIM,[pSize pSize],'distinct');
    n = size(X,2);
%     n  = ceil(mLev*nLev/mm); 

    if(level<3)
        Rtmp     = Kpar.Rbig;
    else
        Rtmp     = Kpar.Rsmall;
    end
    R = DictRedundancy(Rtmp,mm);
    m = mm*R;
end

