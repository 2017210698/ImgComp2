   filename = 'barbara.gif';
   outfilename = 'bar1';   
%% Global param
    global Gpar;
    Gpar.pSizeBig    = 1 + randi(7);
    Gpar.pSizeSmall  = 1 + randi(7);
    Gpar.plotReconst = 0;
    Gpar.plotBppPie  = 0;
%% Wavelet param
    wavelet_names = {'sym8','sym16','db8','db16'};
    Wpar.wavelet_name = wavelet_names{randi(length(wavelet_names))};
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
    ,Wpar.wavelet_name     ...
    ,Kpar.Rbig             ... 
    ,Kpar.Rsmall           ... 
    ,Kpar.dictBigMaxAtoms  ... 
    ,Kpar.dictSmallMaxAtoms... 
    ,Qpar.GAMMAbins        ...
    ,Qpar.Dictbins         ...
    ];
Y = [NNZD,NNZG,BPP];