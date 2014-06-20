function GAMMAq  = QuantizeGAMMA(GAMMA,Qpar)
    bins   = Qpar.GAMMAbins;
    infoDR = Qpar.infoDyRange;
    level = size(GAMMA,2);
    mm    = 3; 
    band = {'H','V','D'};
    if(infoDR)
        DynamicRangeStats(GAMMA);
    end
    
    GAMMAqMAX     = cell(size(GAMMA));
    GAMMANegSigns = cell(size(GAMMA));
    for j = 1:level
        for i = 1:mm
            MAX       = max(abs(GAMMA{i,j}));
            NegSigns  = GAMMA{i,j}<0;
            codebook  = linspace(0,bins-1,bins);
            tmpParti  = linspace(0,MAX,bins+1);
            partition = tmpParti(2:end-1); 
        end
    end
  
    Max          = max(abs(GAMMA));
    % encode
    partition = ((-bins/2:1:bins/2-2)+0.5)/(bins/2)*Max;
    codebook  =  (-bins/2:1:bins/2-1);
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