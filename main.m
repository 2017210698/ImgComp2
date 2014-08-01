function main (THREAD_ID)
    addpath('/home/soron/matlab_exp/ksvd2');
    addpath('/home/soron/matlab_exp/ksvdbox11');
    addpath('/home/soron/matlab_exp/ompbox1');
    %% Picture pram
        IMGNUM = 10;
        outfilename = sprintf('%sbarOut',THREAD_ID);  
    %% Inner Iteration param
    rng('shuffle');
     global Gpar;    
     N    = 20;   
     FEATURES = 13;
     TAGS     = 3;
     iter = 1; % iterator
while(1)
    XTOT = zeros(N,FEATURES);
    YTOT = zeros(N,TAGS);
    ii=1;
    while(ii<=N)
        fileno = randi(IMGNUM);
        filename = sprintf('images/%d.gif',fileno);
    %% Global param
        Gpar.pSizeBig    = 2 + randi(6);
        Gpar.pSizeSmall  = 2 + randi(3);
        Gpar.plotReconst = 0;
        Gpar.plotBppPie  = 0;
    %% Wavelet param
        wavelet_names = {'sym16','9-7'};
        wave_ind      = randi(length(wavelet_names));
        
        Wpar.dfilt = wavelet_names{wave_ind};
        Wpar.pfilt = wavelet_names{wave_ind};
        Wpar.level = [0,0,0,0,0,0];
    %% GOMP (Sparse representations) 
        Kpar.gomp_test  = 0;
        Kpar.targetPSNR = 25 + randi(10);
    %% Sparse KSVD (Train Dictionaries)
        Kpar.Rbig              = randi(3) + 0.5*binornd(1,0.5);
        Kpar.Rsmall            = randi(3) + 0.5*binornd(1,0.5);
        Kpar.dictBigMaxAtoms   = randi(min(floor(Kpar.Rbig^2  *Gpar.pSizeBig  ),7));
        Kpar.dictSmallMaxAtoms = randi(min(floor(Kpar.Rsmall^2*Gpar.pSizeSmall),7));
        Kpar.trainPSNR         = Kpar.targetPSNR + randi(5) - 1;
        Kpar.iternum           = 20; 
        Kpar.printInfo         = 0;
        Kpar.plots             = 0;
    %% Quantization (GAMMA,Dict)
        Qpar.GAMMAbins = (1 + randi(7))*10;
        Qpar.Dictbins  = (1 + randi(7))*10;
        Qpar.infoDyRange = 0;
    %% Optimazie Gamma
        Opar.plots = 0;
        Opar.order = 'GAMMA'; % gamma columned descend population
        
        X = [-1                    ...
            ,Kpar.targetPSNR       ...
            ,Kpar.trainPSNR        ...
            ,Gpar.pSizeBig         ...
            ,Gpar.pSizeSmall       ... 
            ,wave_ind              ...
            ,Kpar.Rbig             ... 
            ,Kpar.Rsmall           ... 
            ,Kpar.dictBigMaxAtoms  ... 
            ,Kpar.dictSmallMaxAtoms... 
            ,Qpar.GAMMAbins        ...
            ,Qpar.Dictbins         ...
            ,fileno                ...
            ];
        
        try
             [NNZD,NNZG,PSNR,BPP] = ImgComp(filename,outfilename,Kpar,Wpar,Qpar,Opar);
        catch 
             save(sprintf('errData/errDATA%s%d',THREAD_ID,iter),'X','YTOT');
             continue;
        end
        X(1)       = PSNR;
        Y          = [NNZD,NNZG,BPP];
        XTOT(ii,:) = X;
        YTOT(ii,:) = Y;
        ii = ii +1;
    end
    save(sprintf('dataSimul/DATA%s%d',THREAD_ID,iter),'XTOT','YTOT');
    iter = iter +1;
end
end