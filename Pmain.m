function [NNZD,NNZG,PSNR,BPP] = Pmain(expLevel,PatchSize,TPSNR)
   filename = 'barbara.gif';
   outfilename = 'bar1';
%% Global param
    global Gpar;
    Gpar.expLevel     = expLevel;
    Gpar.expPatchSize = PatchSize;   
    Gpar.pSizeBig     = 6;
    Gpar.pSizeSmall   = 4;
    Gpar.plotReconst  = 0;
    Gpar.plotBppPie   = 0;
%% Wavelet param
    Wpar.pfilt = '9-7';
    Wpar.dfilt = '9-7';%'pkva';
%     Wpar.wavelet_name = 'sym16'; dwtmode('per','nodisp');  
    Wpar.plots = 0;
%     Wpar.level = 6; % DONOT change for now
    Wpar.level = [0, 0, 0, 0, 0, 0];
%% GOMP (Sparse representations) 
    Kpar.gomp_test  = 0;
    Kpar.targetPSNR = TPSNR;
%% Sparse KSVD (Train Dictionaries)
    Kpar.Rbig              = 3;
    Kpar.Rsmall            = 3;
    Kpar.dictBigMaxAtoms   = 2; 
    Kpar.dictSmallMaxAtoms = 2;    % (MAX = dictLen = R*pSize;)
    Kpar.trainPSNR         = Kpar.targetPSNR + 5;
    Kpar.iternum           = 100;
    Kpar.printInfo         = 0;
    Kpar.plots             = 0;
%% Quantization (GAMMA,Dict)
    Qpar.GAMMAbins = 32;
    Qpar.Dictbins  = 32;
    Qpar.infoDyRange = 0;
%% Optimazie Gamma
    Opar.plots = 0;
    Opar.order = 'GAMMA'; % gamma columned descend population
    try 
        [NNZD,NNZG,PSNR,BPP] = ImgComp(filename,outfilename,Kpar,Wpar,Qpar,Opar);
    catch
        NNZD=-1;NNZG=-1;PSNR=-1;BPP=-1;
        err  = 'Err while expLevel %g,PatchSize %g PSNR %g\n';
        vals = [expLevel,PatchSize,TPSNR];
        fid = fopen('errLog.txt','a');
        fprintf(fid, err, vals);
        fclose(fid);
    end
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
end