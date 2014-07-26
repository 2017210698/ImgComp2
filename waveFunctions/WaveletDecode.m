function Im_rec = WaveletDecode(Ap,Coef,Wpar)

    H = cell(1,6);
    V = cell(1,6);
    D = cell(1,6);
    
    ptr = 512;
    for j=1:6
        H{j} = Coef{1,1}(1:ptr/2,ptr/2+1:ptr);
        V{j} = Coef{1,1}(ptr/2+1:ptr,1:ptr/2);
        D{j} = Coef{1,1}(ptr/2+1:ptr,ptr/2+1:ptr);
        ptr=ptr/2;
    end
    
%     
%     COEF  = zeros(8);
%     for j=level:-1:1
%             COEF = [COEF,Coef{1,j}];           %#ok<AGROW>
%             COEF = [COEF;Coef{2,j},Coef{3,j}]; %#ok<AGROW>
%     end
    
%     H = Coef(1,:);
%     V = Coef(2,:);
%     D = Coef(3,:);
    S = 2.^(9-Wpar.level:1:9);
    S = [S(1);S(:)];
    S = [S,S];
    wavelet_name = Wpar.wavelet_name;
    C = getWaveletStream(Ap,H,V,D);
    Im_rec = waverec2(C,S,wavelet_name);
end