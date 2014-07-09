function [DictLen] = MaxDictLen(Kpar.R )
    R       = DictRedundancy(Kpar.R,m); % dictionary reduandancy
    perTdict= Kpar.perTdict;
    % eligable reduandancy
    fprintf('Eligable Dictionary redudnacy for patch size:%d is R:%.4f\n',m,R);
   
    dictLen = R*m;
end

