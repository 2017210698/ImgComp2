function main (THREAD_ID)
    addpath('/home/soron/matlab_exp/ksvd2');
    addpath('/home/soron/matlab_exp/ksvdbox11');
    addpath('/home/soron/matlab_exp/ompbox1');
    %% Picture pram
        filename = 'barbara.gif';
        outfilename = sprintf('%sbarOut',THREAD_ID);  
    %% Inner Iteration param
    rng('shuffle');
     global Gpar;    
     N    = 2;   
     iter = 1;
     FEATURES = 12;
     TAGS     = 3;
while(1)
    XTOT = zeros(N,FEATURES);
    YTOT = zeros(N,TAGS);
    for ii=1:N
    %% Global param
        Gpar.pSizeBig    = 2 + randi(6);
        Gpar.pSizeSmall  = 2 + randi(3);
        Gpar.plotReconst = 0;
        Gpar.plotBppPie  = 0;
    %% Wavelet param
        wavelet_names = {'sym16','9-7','pkva'};
        wave_ind      = randi(length(wavelet_names));
        
        Wpar.dfilt = wavelet_names{wave_ind};
        if(strcmp(Wpar.dfilt,'pkva'));
            Wpar.pfilt = '9-7';
        else
            Wpar.pfilt = wavelet_names{wave_ind};
        end
        Wpar.level = [0,0,0,0,0,0];
       
%         Wpar.plots = 0;
%         Wpar.level = 6; % DONOT change for now
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
    save(sprintf('dataSimul/DATA%s%d',THREAD_ID,iter),'XTOT','YTOT');
    iter = iter +1;
end
end