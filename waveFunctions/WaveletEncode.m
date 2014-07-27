function [Ap,Coef] = WaveletEncode(Im,Wpar)
    Im = double(Im) / 256;
%     Im = smthborder(Im, 32); % Review that
    COEF = pdfbdec(Im, Wpar.pfilt, Wpar.dfilt, Wpar.level);
    
    Ap = COEF{1};
    Coef = cell(3,6);
    
    for j=1:6
        for i=1:3
            Coef{i,j}=COEF{7-j+1}{i};
        end
    end    
    
%     wavelet_name = Wpar.wavelet_name;
%     level        = Wpar.level;
%     % wavelet encode 
%     [C,S] = wavedec2(Im,level,wavelet_name);
%     if(Wpar.plots)
%         figure(); showwave2( C,S,level,wavelet_name )
%     end
%     [Ap,Coef] = getCoefCel( C,S,level,wavelet_name);
end