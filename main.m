addpath('waveFunctions/');
addpath('ksvdFunctions/');
addpath('entropyFunctions/');
addpath('ompFunctions/');
%% get Image 

Im= imread('barbara.gif');
Imfig = figure();subplot(1,2,1);imshow(Im,[]);title('Original Image')

TargetPSNR = 40;

%% Wavelet Transform
    % fixed param
    Wpar.wavelet_name = 'sym8'; dwtmode('per','nodisp');  
    Wpar.plots = 1;
    Wpar.level = 5;
    % encode
    [Ap,Coef] = WaveletEncode(Im,Wpar);
    % Coef are H,V,D 2d wavelet coeffiencets in cell array
    
    % Reconstruction Check
    Im_rec = WaveletDecode(Ap,Coef,Wpar);
    MSE    =  norm(double(Im)-Im_rec,'fro')/numel(Im);
    PSNR   =  10*log10(255^2/MSE);

%% Sparse KSVD (Train Dictionaries)
    Kpar.perTdict  = 0.01;
    Kpar.targetPSNR = TargetPSNR;
    Kpar.R         = 4; % dictionary reduandancy % TODO: first paramter to change
    Kpar.iternum   = 10;
    Kpar.printInfo = 1;
    Kpar.plots     = 1;
    Dict = TrainDictCells(Coef,Kpar);
    
%% GOMP (Sparse representations) 
    Kpar.gomp_test =1;
    Kpar.targetPSNR = 20;
    [GAMMA] = OMPcells(Coef,Dict,Wpar,Kpar);
    
    % Reconstruction
    Coef   = SparseToCoef(GAMMA,Dict,Kpar);
    Im_rec = WaveletDecode(Ap,Coef,Wpar);
    MSE    = norm(double(Im)-Im_rec,'fro')/numel(Im);
    PSNR   = 10*log10(255^2/MSE);

    
    
    
    