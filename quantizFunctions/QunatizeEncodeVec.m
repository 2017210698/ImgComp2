function A = QunatizeEncodeVec(V,Qpar)
  % Quantize encode V
    bins         = Qpar.bins;
    OriginalSize = size(V);
    Av           = Gamma2vec(V); %TODO: vary GAMMA to vec GAMMA/A /H/D/V/AP
    Av           = Av';
    DC           = mean(full(Av));
    Av           = Av-DC;
    Max          = max(abs(Av));
    % encode
    partition = ((-bins/2:1:bins/2-2)+0.5)/(bins/2)*Max;
    codebook =  (-bins/2:1:bins/2-1);
    [index,~] = quantiz(Av,partition,codebook);
    % save parameters
    Qpar.OriginalSize = OriginalSize;
    Qpar.DC          = DC;
    Qpar.Max         = Max;
    Qpar.header.field = {'OriginalSize','DC','Max'};
    Qpar.header.type  = {'uint16','double','double'};%TODO: check DC/Max double/signel float...
    A.Qindex         = index;
    A.Qpar           = Qpar;    
end