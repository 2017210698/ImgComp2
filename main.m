addpath('waveFunctions/');
addpath('ksvdFunctions/');
addpath('entropyFunctions/');
addpath('ompFunctions/');
close all;clear all;clc;
%% get Image 

Im= imread('barbara.gif');
Imfig = figure();subplot(1,2,1);imshow(Im,[]);title('Original Image')

TargetPSNR = 29;

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
    Kpar.perTdict  = 0.15;
    Kpar.targetPSNR = TargetPSNR;
    Kpar.R         = 2; % dictionary reduandancy % TODO: first paramter to change
    Kpar.iternum   = 8;
    Kpar.printInfo = 1;
    Kpar.plots     = 0;
    Dict = TrainDictCells(Coef,Kpar);
    
%% GOMP (Sparse representations) 
    Kpar.gomp_test =1;
    Kpar.targetPSNR = TargetPSNR;
    [GAMMA] = OMPcells(Coef,Dict,Wpar,Kpar);
    
    % Reconstruction
    Coef   = SparseToCoef(GAMMA,Dict);
    Im_rec = WaveletDecode(Ap,Coef,Wpar);
    % eval
    NNZ=0;
    for i=1:size(GAMMA,1)
        for j=1:size(GAMMA,2)
            NNZ=NNZ+nnz(GAMMA{i,j});
        end
    end
    MSE    = norm(double(Im)-Im_rec,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf('PSNR after GOMP:%.2f, nnz(GAMMA):%d\n',PSNR,NNZ);
    figure();subplot(1,2,2);imshow(Im_rec,[]);title(sprintf('reconstrucion PSNR:%.2f',PSNR));

    
    
    
    