function [PSNR,BPP] = Pmain(myPSNR)
   addpath('/home/soron/matlab_exp/ksvd2');
   addpath('/home/soron/matlab_exp/ksvdbox11');
   addpath('/home/soron/matlab_exp/ompbox1');
   filename = 'barbara.gif';
   outfilename = 'bar1';
%% Global param
    global Gpar;
    Gpar.pSizeBig    = 6;
    Gpar.pSizeSmall  = 4;
    Gpar.plotReconst = 1;
    Gpar.plotBppPie  = 1;
%% Wavelet param
    Wpar.wavelet_name = 'sym16'; dwtmode('per','nodisp');  
    Wpar.plots = 0;
    Wpar.level = 6; % DONOT change for now
%% Sparse KSVD (Train Dictionaries)
    Kpar.Rbig              = 2.5;
    Kpar.Rsmall            = 2.5;
    Kpar.dictBigMaxAtoms   = 2; 
    Kpar.dictSmallMaxAtoms = 2;    % (MAX = dictLen = R*pSize;)
    Kpar.trainPSNR         = myPSNR+5;
    Kpar.iternum           = 1; %40
    Kpar.printInfo         = 0;
    Kpar.plots             = 1;
%% GOMP (Sparse representations) 
    Kpar.gomp_test  = 1;
    Kpar.targetPSNR = myPSNR;
%% Quantization (GAMMA,Dict)
    Qpar.GAMMAbins = 32;
    Qpar.Dictbins  = 32;
    Qpar.infoDyRange = 0;
%% Optimazie Gamma
    Opar.plots = 0;
    Opar.order = 'GAMMA'; % gamma columned descend population

dbstop in ImgComp
[NNZD,NNZG,PSNR,BPP] = ImgComp(filename,outfilename,Kpar,Wpar,Qpar,Opar);
ImRE = ImgRead(outfilename,Kpar,Wpar,Qpar,Opar);
% figure;imshow(ImRE,[])
% TODO:
% remove DC's
% combine same levels
% combine differently
% save diffcol by a symbol to skeep to the next line instead of different
% symbols
% Haar transform really bad -> need a better wavelet
% check the overhead of zeros padd im2col
end