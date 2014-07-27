function Im_rec = WaveletDecode(Ap,Coef,Wpar)


    COEFR    = cell(1,7);
    COEFR{1} = Ap;
    
    for j=1:6
        COEFR{7-j+1}    = cell(1,3);
        for i=1:3   
            COEFR{7-j+1}{i} = Coef{i,j};
        end
    end
    
    Im_rec = pdfbrec(COEFR, Wpar.pfilt, Wpar.dfilt);
    Im_rec = double(Im_rec)*256;

%     H = Coef(1,:);
%     V = Coef(2,:);
%     D = Coef(3,:);
%     S = 2.^(9-Wpar.level:1:9);
%     S = [S(1);S(:)];
%     S = [S,S];
%     wavelet_name = Wpar.wavelet_name;
%     C = getWaveletStream(Ap,H,V,D);
%     Im_rec = waverec2(C,S,wavelet_name);
end