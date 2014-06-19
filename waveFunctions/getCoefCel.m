function  [A,Coef] = getCoefCel( C,S,level,wavelet )

A     = cell(1,level);
Coef  = cell(3,level);
     
    for i = 1:level
        A{i} = appcoef2(C,S,wavelet,i); % approx
        [Coef{1,i} ,Coef{2,i} ,Coef{3,i}] = detcoef2('a',C,S,i); % details  
    end
    A = A{level};
end

