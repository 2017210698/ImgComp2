function  [m,n]  = DictSize(level,Kpar)
    pSize = PatchSize(level); % TOOD: should be dependad on [mLev,nLev]?
    mm = pSize^2;
    R = DictRedundancy(Kpar.R,mm);
    m = mm*R;
    n = m;

end

