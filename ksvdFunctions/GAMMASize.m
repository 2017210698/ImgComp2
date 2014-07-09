function [m,n]  = GAMMASize(mIm,nIm,level,Kpar)
    [mLev,nLev] = WaveImSize(mIm,nIm,level);
    pSize = PatchSize(level); % TOOD: should be dependad on [mLev,nLev]?
    mm = pSize^2;
    n  = mLev*nLev/mm; 
   if(level<3)
        Rtmp     = Kpar.Rbig;
    else
        Rtmp     = Kpar.Rsmall;
    end
    R = DictRedundancy(Rtmp,mm);
    m = mm*R;
end

