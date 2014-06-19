function [Ap,Coef] = WaveletEncode(Im,Wpar)
    wavelet_name = Wpar.wavelet_name;
    level        = Wpar.level;
    % wavelet encode 
    [C,S] = wavedec2(Im,level,wavelet_name);
    if(Wpar.plots)
        figure(); showwave2( C,S,level,wavelet_name )
    end
    [Ap,Coef] = getCoefCel( C,S,level,wavelet_name);
end