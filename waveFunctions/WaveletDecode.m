function Im_rec = WaveletDecode(Ap,Coef,Wpar)
    H = Coef(1,:);
    V = Coef(2,:);
    D = Coef(3,:);
    S = [16;16;32;64;128;256;512];
    S = [S,S];
    wavelet_name = Wpar.wavelet_name;
    C = getWaveletStream(Ap,H,V,D);
    Im_rec = waverec2(C,S,wavelet_name);
end