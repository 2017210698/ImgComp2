function  [m,n] = WaveImSize(mIm,nIm,level)
    % gets the initial Image Size return current level size
    if(mIm~=nIm)
        error('WaveImSize works only for squared Images in this project');
    end
    
    m = mIm;
    n = nIm;
    for i=1:level
        m=m/2;
        n=n/2;
    end
    

end

