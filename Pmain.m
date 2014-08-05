function [PSNR,BPP] = Pmain(filename,TARGET_PSNR,iternum)
    addpath('/home/soron/matlab_exp/ksvd2');
    addpath('/home/soron/matlab_exp/ksvdbox11');
    addpath('/home/soron/matlab_exp/ompbox1');
   outfilename = 'bar1';
%% Global param
    global Gpar;
    Gpar.pSizeBig    = 4;
    Gpar.pSizeSmall  = 4;
    Gpar.plotReconst = 0;
    Gpar.plotBppPie  = 0;
%% Wavelet param
    Wpar.pfilt = 'sym16';
    Wpar.dfilt = 'sym16';
    Wpar.plots = 0;
    Wpar.level = [0, 0, 0, 0, 0, 0];
%% GOMP (Sparse representations) 
    Kpar.gomp_test  = 0;
    Kpar.targetPSNR = TARGET_PSNR;
%% Sparse KSVD (Train Dictionaries)
    Kpar.Rbig              = 2;
    Kpar.Rsmall            = 2;
    Kpar.dictBigMaxAtoms   = 2; 
    Kpar.dictSmallMaxAtoms = 2;   
    Kpar.trainPSNR         = Kpar.targetPSNR + 5;
    Kpar.iternum           = iternum;
    Kpar.printInfo         = 0;
    Kpar.plots             = 0;
%% Quantization (GAMMA,Dict)
    Qpar.GAMMAbins = 40;
    Qpar.Dictbins  = 40;
    Qpar.infoDyRange = 0;
%% Optimazie Gamma
    Opar.plots = 0;
    Opar.order = 'GAMMA'; % gamma columned descend population
[~,~,PSNR,BPP] = ImgComp(filename,outfilename,Kpar,Wpar,Qpar,Opar);
% ImRE = ImgRead(outfilename,Kpar,Wpar,Qpar,Opar);
% figure;imshow(ImRE,[])
% TODO:
% remove DC's
% combine same levels
% combine differently
% save diffcol by a symbol to skeep to the next line instead of different
% symbols
% Haar transform really bad -> need a better wavelet
% check the overhead of zeros padd im2col