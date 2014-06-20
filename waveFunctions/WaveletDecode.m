function Im_rec = WaveletDecode(Ap,Coef,Wpar)
    H = Coef(1,:);
    V = Coef(2,:);
    D = Coef(3,:);
    S = 2.^(9-Wpar.level:1:9);
    S = [S(1);S(:)];
    S = [S,S];
    wavelet_name = Wpar.wavelet_name;
    C = getWaveletStream(Ap,H,V,D);
    Im_rec = waverec2(C,S,wavelet_name);
end