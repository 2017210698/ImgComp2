function len = GAMMColSize(level)
    pSize = PatchSize(level);
    m = pSize^2;
    
    imSize = 512/2^level;
    
    n = imSize^2;
    
    len = n/m;

end

