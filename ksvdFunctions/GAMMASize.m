function [m,n]  = GAMMASize(mIm,nIm,level,Kpar)
    [mLev,nLev] = WaveImSize(mIm,nIm,level);
    pSize = PatchSize(level); % TOOD: should be dependad on [mLev,nLev]?
    mm = pSize^2;
    n  = mLev*nLev/mm;
    R = DictRedundancy(Kpar.R,mm);
    m = mm*R;
end

