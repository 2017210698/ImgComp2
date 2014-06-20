addpath('waveFunctions/');
addpath('ksvdFunctions/');
addpath('entropyFunctions/');
addpath('ompFunctions/');
addpath('quantizFunctions/');
close all;clear all;clc;
%% get Image 

Im= imread('barbara.gif');
f1m=2;f1n=2;
f1 = figure();subplot(f1m,f1n,1);imshow(Im,[]);title('Original Image')

TargetPSNR = 30;

%% Wavelet Transform
    % fixed param
    Wpar.wavelet_name = 'sym8'; dwtmode('per','nodisp');  
    Wpar.plots = 1;
    Wpar.level = 6;
    % encode
    [Ap,Coef] = WaveletEncode(Im,Wpar);
    % Coef are H,V,D 2d wavelet coeffiencets in cell array
    
    % Reconstruction Check
    Im_rec = WaveletDecode(Ap,Coef,Wpar);
    MSE    =  norm(double(Im)-Im_rec,'fro')/numel(Im);
    PSNR   =  10*log10(255^2/MSE);
    fprintf(sprintf('Wavelet PSNR %.2f\n',PSNR));

%% Sparse KSVD (Train Dictionaries)
    Kpar.perTdict  = 0.03;
    Kpar.targetPSNR = TargetPSNR;
    Kpar.R         = 2; % dictionary reduandancy % TODO: first paramter to change
    Kpar.iternum   = 8;
    Kpar.printInfo = 1;
    Kpar.plots     = 0;
    Dict = TrainDictCells(Coef,Kpar);
    
%% GOMP (Sparse representations) 
    Kpar.gomp_test =1;
    Kpar.targetPSNR = 30;
    [GAMMA] = OMPcells(Coef,Dict,Wpar,Kpar);
    
    % Reconstruction
    tmpCoef   = SparseToCoef(GAMMA,Dict);
    Im_rec    = WaveletDecode(Ap,tmpCoef,Wpar);
    % eval
    NNZG    = cellArrayNNZ(GAMMA);
    NNZD    = cellArrayNNZ(Dict);
    MSE    = norm(double(Im)-Im_rec,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf('*******GOMP END *******\n');
    fprintf('  GOMP PSNR :%.2f, nnz(GAMMA):%d, nnz(Dict):%d, Tot=%d\n',PSNR,NNZG,NNZD,NNZD+NNZG);
    figure(f1);subplot(f1m,f1n,2);imshow(Im_rec,[]);title(sprintf('GOMP reconstrucion PSNR:%.2f',PSNR));

%% Quantization (GAMMA,Dict)
    Qpar.GAMMAbins = 2^5;
    Qpar.Dictbins  = 2^5;
    Qpar.infoDyRange = 1;
    
    [GAMMA]  = QuantizeGAMMA(GAMMA,Qpar); 
    
    









    