function  [m,n,MAX]  = DictSize(level,Kpar)
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
    
    
    MAX = -inf;
    if(nargout>2)
        for ii=1:6
            pSize = PatchSize(ii); % TOOD: should be dependad on [mLev,nLev]?
            mm = pSize^2;
           if(ii<3)
                Rtmp     = Kpar.Rbig;
            else
                Rtmp     = Kpar.Rsmall;
            end
            R = DictRedundancy(Rtmp,mm);
            m = round(mm*R);
            if(m>MAX);
                MAX=m;
            end
        end
    end
end

