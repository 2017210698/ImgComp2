function  showwave2( C,S,level,wavelet )
    A = cell(1,level);
    H = cell(1,level);
    V = cell(1,level);
    D = cell(1,level);
    
    for i = 1:level
        A{i} = appcoef2(C,S,wavelet,i); % approx
        [H{i} ,V{i} ,D{i}] = detcoef2('a',C,S,i); % details  
        % scaling to [0,255] image format
        A{i} = wcodemat(A{i},256)-1;
        H{i} = wcodemat(H{i},256)-1;
        V{i} = wcodemat(V{i},256)-1;
        D{i} = wcodemat(D{i},256)-1;
    end
    
    dec = cell(1,level);
    dec{level} = [A{level} H{level} ; V{level} D{level}];
    
    for k = level-1:-1:1
        dec{k} = [imresize(dec{k+1},size(H{k})), H{k} ; V{k} ,D{k}];
    end
     IM2 = imcomplement(dec{1});% negative img
     imagesc(IM2);
     colormap(gray)
end


