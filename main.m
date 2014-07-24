   filename = 'barbara.gif';
   outfilename = 'bar1';   
   global Gpar;
N    = 10;   
iter = 1;
FEATURES = 12;
TAGS     = 3;
while(1)
    XTOT = zeros(N,FEATURES);
    YTOT = zeros(N,TAGS);
    for ii=1:N
    %% Global param
        Gpar.pSizeBig    = 2 + randi(6);
        Gpar.pSizeSmall  = 2 + randi(6);
        Gpar.plotReconst = 0;
        Gpar.plotBppPie  = 0;
    %% Wavelet param
        wavelet_names = {'sym8','sym16','db8','db16'};
        wave_ind      = randi(length(wavelet_names));
        Wpar.wavelet_name = wavelet_names{wave_ind};
            dwtmode('per','nodisp');  
        Wpar.plots = 0;
        Wpar.level = 6; % DONOT change for now
    %% GOMP (Sparse representations) 
        Kpar.gomp_test  = 0;
        Kpar.targetPSNR = 25 + randi(10);
    %% Sparse KSVD (Train Dictionaries)
        Kpar.Rbig              = randi(3) + 0.5*binornd(1,0.5);
        Kpar.Rsmall            = randi(3) + 0.5*binornd(1,0.5);
        Kpar.dictBigMaxAtoms   = randi(min(floor(Kpar.Rbig^2  *Gpar.pSizeBig  ),7));
        Kpar.dictSmallMaxAtoms = randi(min(floor(Kpar.Rsmall^2*Gpar.pSizeSmall),7));
        Kpar.trainPSNR         = Kpar.targetPSNR + randi(5) - 1;
        Kpar.iternum           = 1;
        Kpar.printInfo         = 0;
        Kpar.plots             = 0;
    %% Quantization (GAMMA,Dict)
        Qpar.GAMMAbins = (1 + randi(7))*10;
        Qpar.Dictbins  = (1 + randi(7))*10;
        Qpar.infoDyRange = 0;
    %% Optimazie Gamma
        Opar.plots = 0;
        Opar.order = 'GAMMA'; % gamma columned descend population

        [NNZD,NNZG,PSNR,BPP] = ImgComp(filename,outfilename,Kpar,Wpar,Qpar,Opar);
        X = [PSNR                  ...
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
            ];
        Y = [NNZD,NNZG,BPP];
        XTOT(ii,:) = X;
        YTOT(ii,:) = Y;
    end
    save(sprintf('DATA%7d',iter),'XTOT','YTOT');
    iter = iter +1;
end