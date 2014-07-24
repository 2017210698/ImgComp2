function  [m,n]  = DictSize(level,Kpar)
    pSize = PatchSize(level); % TOOD: should be dependad on [mLev,nLev]?
    mm = pSize^2;
   if(level<3)
        Rtmp     = Kpar.Rbig;
    else
        Rtmp     = Kpar.Rsmall;
    end
    R = DictRedundancy(Rtmp,mm);
    m = round(mm*R);
    n = m;

end

