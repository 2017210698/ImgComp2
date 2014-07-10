addpath('waveFunctions/');
addpath('ksvdFunctions/');
addpath('entropyFunctions/');
addpath('ompFunctions/');
addpath('quantizFunctions/');
addpath('optimizeFunctions/');
addpath('quantizFunctions/');
addpath('diffFunctions/');
addpath('generalFunctions/');
addpath('arithcoFunctions/');
addpath('fileFunctions/');
%% 
close all;clear all;clc;
%% get Image 

Im= imread('barbara.gif');
f1m=2;f1n=2;
f1 = figure();subplot(f1m,f1n,1);imshow(Im,[]);title('Original Image')

TargetPSNR = 30;
TrainPSNR  = 32;

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
    Kpar.perTdictBig   = 0.02;
    Kpar.perTdictSmall = 0.02;
    Kpar.Rbig          = 2.5;
    Kpar.Rsmall       = 2.5;
    Kpar.targetPSNR = TrainPSNR;
    Kpar.iternum   = 8;
    Kpar.printInfo = 1;
    Kpar.plots     = 0;
    Dict = TrainDictCells(Coef,Kpar);
%% Normalize Dictionaries (degree of freedom)
    for i=1:size(Dict,1)
        for j=1:size(Dict,2)
            for row=1:size(Dict{i,j},1)      
                Dict{i,j}=Dict{i,j}./max(abs(Dict{i,j}(:)));
            end
        end
    end
    
%% GOMP (Sparse representations) 
    Kpar.gomp_test =1;
    Kpar.targetPSNR = TargetPSNR;
    [GAMMA] = OMPcells(Coef,Dict,Wpar,Kpar);
    
    % Reconstruction
    tmpCoef0   = SparseToCoef(GAMMA,Dict);
    Im_rec0    = WaveletDecode(Ap,tmpCoef0,Wpar);
    
    % eval 
    NNZG    = cellArrayNNZ(GAMMA);
    NNZD    = cellArrayNNZ(Dict);
    MSE    = norm(double(Im)-Im_rec0,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf('*******GOMP END *******\n');
    fprintf(' GOMP PSNR:%.2f, nnz(GAMMA):%d, nnz(Dict):%d, Tot=%d\n',PSNR,NNZG,NNZD,NNZD+NNZG);
    figure(f1);subplot(f1m,f1n,2);imshow(Im_rec0,[]);title(sprintf('GOMP reconstrucion PSNR:%.2f',PSNR));

%% Quantization (GAMMA,Dict)
    Qpar.GAMMAbins = 2^6;
    Qpar.Dictbins  = 2^6;
    Qpar.infoDyRange = 1;

    [GAMMAq,GAMMAqMAX,GAMMANegSigns] = QuantizeGAMMA(GAMMA,Qpar);
    [Dictq ,DictNegSigns]            = QuantizeDict(Dict,Qpar);
    
    % Reconstruction
    GAMMA1 = DeQuantizeGAMMA(GAMMAq,GAMMAqMAX,GAMMANegSigns,Qpar);
    Dict1  = DeQuantizeDict (Dictq ,DictNegSigns,Qpar);
    tmpCoef1   = SparseToCoef(GAMMA1,Dict1);
    Im_rec1    = WaveletDecode(Ap,tmpCoef1,Wpar);
    
    % eval
    NNZG    = cellArrayNNZ(GAMMAq);
    NNZD    = cellArrayNNZ(Dictq);
    MSE    = norm(double(Im)-Im_rec1,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf(' Quant PSNR:%.2f, nnz(GAMMAq):%d, nnz(Dictq):%d, Tot=%d\n',PSNR,NNZG,NNZD,NNZD+NNZG);
    figure(f1);subplot(f1m,f1n,3);imshow(Im_rec1,[]);title(sprintf('Quant reconstrucion PSNR:%.2f',PSNR));
    
%% Optimazie Gamma
    Opar.plots = 1;
    Opar.order = 'GAMMA'; % gamma columned descend population
    [GAMMAq,Dictq,GAMMANegSigns,DictNegSigns] = AlterRowCol(GAMMAq,Dictq,GAMMANegSigns,DictNegSigns,Opar);
    
    % Reconstruction
    GAMMA2 = DeQuantizeGAMMA(GAMMAq,GAMMAqMAX,GAMMANegSigns,Qpar);
    Dict2  = DeQuantizeDict (Dictq ,DictNegSigns,Qpar);
    tmpCoef2   = SparseToCoef(GAMMA2,Dict2); 
    Im_rec2    = WaveletDecode(Ap,tmpCoef2,Wpar);
    
    % eval
    MSE    = norm(double(Im)-Im_rec2,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf(' Optim PSNR:%.2f\n',PSNR);
    
%%  CCS (Coulmned compressed GAMMA,Dict) 
%     dbstop in CssGAMMA
    [GAMMAval,GAMMAneg,GAMMArow,GAMMAcol]= CssGAMMA(GAMMAq,GAMMANegSigns);
    [Dictval,Dictneg,Dictrow,Dictcol]    = CssDict (Dictq,DictNegSigns); 
    
    % Reconstruction 
    [GAMMAq3,GAMMANegSigns3] = DeCssGAMMA(GAMMAval,GAMMAneg,GAMMArow,GAMMAcol,Kpar);
    [Dictq3 ,DictNegSigns3 ] = DeCssDict (Dictval,Dictneg,Dictrow,Dictcol,Kpar);
    GAMMA3 = DeQuantizeGAMMA(GAMMAq3,GAMMAqMAX,GAMMANegSigns3,Qpar);
    Dict3  = DeQuantizeDict (Dictq3 ,DictNegSigns3,Qpar);
    tmpCoef3   = SparseToCoef(GAMMA3,Dict3); 
    Im_rec3    = WaveletDecode(Ap,tmpCoef3,Wpar);
    
    % eval
    NNZG = cellArrayNNZ(GAMMAval,GAMMAneg,GAMMArow,GAMMAcol,GAMMAqMAX);
    NNZD = cellArrayNNZ(Dictval,Dictneg,Dictrow,Dictcol);
    ENTG = cellArrayEntropy(GAMMAval,GAMMAneg,GAMMArow,GAMMAcol);
    ENTD = cellArrayEntropy(Dictval,Dictneg,Dictrow,Dictcol);
    MSE    = norm(double(Im)-Im_rec3,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf(' CSS   PSNR:%.2f numel(GAMMAinfo):%d,numel(DICTinfo):%d,Tot:%d\n',PSNR,NNZG,NNZD,NNZG+NNZD);
    fprintf(' CSS       H(GAMMAinfo):%d,H(DICTinfo):%d\n',ENTG,ENTD); 
%% Diff Code (for GAMMAcol ,Dictcol)
%     dbstop in DiffColCCS
    [GAMMAdiffCol,GAMMARowStart,GAMMAdiffRow] = DiffColCCS(GAMMArow,GAMMAcol);
    [DictdiffCol,DictRowStart,DictdiffRow   ] = DiffColCCS(Dictrow ,Dictcol);


    % Reconstruction 
    [GAMMArow4,GAMMAcol4]   = DeDiffCCS(GAMMAdiffCol,GAMMARowStart,GAMMAdiffRow);
    [Dictrow4 ,Dictcol4   ] = DeDiffCCS(DictdiffCol,DictRowStart,DictdiffRow);
    
    [GAMMAq4,GAMMANegSigns4] = DeCssGAMMA(GAMMAval,GAMMAneg,GAMMArow4,GAMMAcol4,Kpar);
    [Dictq4 ,DictNegSigns4 ] = DeCssDict (Dictval,Dictneg,Dictrow4,Dictcol4,Kpar);
    GAMMA4 = DeQuantizeGAMMA(GAMMAq4,GAMMAqMAX,GAMMANegSigns4,Qpar);
    Dict4  = DeQuantizeDict (Dictq4 ,DictNegSigns4,Qpar);
    tmpCoef4   = SparseToCoef(GAMMA4,Dict4); 
    Im_rec4    = WaveletDecode(Ap,tmpCoef4,Wpar);
    
    % eval
    ENTG = cellArrayEntropy(GAMMAval,GAMMAneg,GAMMAdiffCol,GAMMARowStart,GAMMAdiffRow);
    ENTD = cellArrayEntropy(Dictval,Dictneg,DictdiffCol,DictRowStart,DictdiffRow);
    MSE    = norm(double(Im)-Im_rec4,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf(' DIFF  PSNR:%.2f\n',PSNR);
    fprintf(' DIFF      H(GAMMAinfo):%d,H(DICTinfo):%d\n',ENTG,ENTD);
%% What is for entropy code 
    fprintf('****vars to entropy code*****\n');
        whos('GAMMAval','GAMMAneg','GAMMAdiffCol','GAMMARowStart','GAMMAdiffRow');
        whos('Dictval','Dictneg','DictdiffCol','DictRowStart','DictdiffRow');
        
%% Entropy Encode (GAMMA)
bins = Qpar.GAMMAbins;
%     ShowHist(GAMMAdiffCol,'GAMMAdiffCol',GAMMARowStart,'GAMMARowStart',GAMMAdiffRow,'GAMMAdiffRow',bins);
%     ShowHist(GAMMAval,'GAMMAval',GAMMAneg,'GAMMAneg',bins);

[GAMMAvalcode,GAMMAvalcounts,GAMMAvallen] = EntropyEncodeVals(GAMMAval,bins);
[GAMMAnegcode] = Cell2CONT(GAMMAneg);

dictLen = DictSize(0,Kpar);% max dict len
[GAMMARowStartcode,GAMMARowStartcounts,GAMMARowStartlen] = EntropyEncodeVals(GAMMARowStart,dictLen);
[GAMMAdiffRowcode,GAMMAdiffRowcounts] = EntropyEncodediffRow(GAMMAdiffRow,dictLen);

GAMMACOLBINS = CELLARRMAX(GAMMAdiffCol);
[GAMMAdiffColcode,GAMMAdiffColcounts] = EntropyEncodediffCol(GAMMAdiffCol,GAMMACOLBINS);

[GAMMAval5] = EntropyDecodeVals(GAMMAvalcode,GAMMAvalcounts,GAMMAvallen,bins,Wpar.level);
[GAMMAneg5] = CONT2Cell(GAMMAnegcode,GAMMAval5);
[GAMMARowStart5] = EntropyDecodeVals(GAMMARowStartcode,GAMMARowStartcounts,GAMMARowStartlen,dictLen,Wpar.level);
[GAMMAdiffRow5 ] = EntropyDecodediffRow(GAMMAdiffRowcode,GAMMAdiffRowcounts,GAMMARowStart5,GAMMAval5,Wpar.level);
[GAMMAdiffCol5 ] = EntropyDecodediffColGAMMA(GAMMAdiffColcode,GAMMAdiffColcounts,Wpar.level);

GAMMAentValid = zeros(1,5);
GAMMAentValid(1) = isequal(GAMMAval5,GAMMAval);
GAMMAentValid(2) = isequal(GAMMAneg5,GAMMAneg);
GAMMAentValid(3) = isequal(GAMMARowStart5,GAMMARowStart);
GAMMAentValid(4) = isequal(GAMMAdiffRow5,GAMMAdiffRow);
GAMMAentValid(5) = isequal(GAMMAdiffCol5,GAMMAdiffCol);

if(min(GAMMAentValid)==1)
    fprintf('******ENTROPY encoding TEST PASS (GAMMA)******\n')
else
    error('ERR: **ENTROPY encoding TEST FAILED (GAMMA)**')
end
%% Entropy Encode (Dict)
    bins = Qpar.Dictbins;
%     ShowHist(DictdiffCol,'DictdiffCol',DictRowStart,'DictRowStart',DictdiffRow,'DictdiffRow',bins);
%     ShowHist(Dictval,'Dictval',Dictneg,'Dictneg',bins);

[Dictvalcode,Dictvalcounts,Dictvallen] = EntropyEncodeVals(Dictval,bins);
[Dictnegcode] = Cell2CONT(Dictneg);

dictLen = DictSize(0,Kpar);% max dict len
[DictRowStartcode,DictRowStartcounts,DictRowStartlen] = EntropyEncodeVals(DictRowStart,dictLen);
[DictdiffRowcode,DictdiffRowcounts] = EntropyEncodediffRow(DictdiffRow,dictLen);

DictCOLBINS = CELLARRMAX(DictdiffCol);
[DictdiffColcode,DictdiffColcounts] = EntropyEncodediffCol(DictdiffCol,DictCOLBINS);

[Dictval5] = EntropyDecodeVals(Dictvalcode,Dictvalcounts,Dictvallen,bins,Wpar.level);
[Dictneg5] = CONT2Cell(Dictnegcode,Dictval5);
[DictRowStart5] = EntropyDecodeVals(DictRowStartcode,DictRowStartcounts,DictRowStartlen,dictLen,Wpar.level);
[DictdiffRow5 ] = EntropyDecodediffRow(DictdiffRowcode,DictdiffRowcounts,DictRowStart5,Dictval5,Wpar.level);
[DictdiffCol5 ] = EntropyDecodediffColDict(DictdiffColcode,DictdiffColcounts,Wpar.level,Kpar);

DictentValid = zeros(1,5);
DictentValid(1) = isequal(Dictval5,Dictval);
DictentValid(2) = isequal(Dictneg5,Dictneg);
DictentValid(3) = isequal(DictRowStart5,DictRowStart);
DictentValid(4) = isequal(DictdiffRow5,DictdiffRow);
DictentValid(5) = isequal(DictdiffCol5,DictdiffCol);

if(min(DictentValid)==1)
    fprintf('******ENTROPY encoding TEST PASS (Dict) ******\n')
else
    error('ERR: **ENTROPY encoding TEST FAILED (Dict) **')
end
    
%% What is for file Writing
    fprintf('****vars to file write code*****\n');
       whos('GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode',...
            'GAMMAdiffRowcode','GAMMAdiffColcode',...
            'Dictvalcode','Dictnegcode','DictRowStartcode',...
            'DictdiffRowcode','DictdiffColcode'...
            );
        
        whos('GAMMAvalcounts','GAMMARowStartcounts',...
             'GAMMAdiffRowcounts','GAMMAdiffColcounts',...
             'Dictvalcounts','DictRowStartcounts',...
             'DictdiffRowcounts','DictdiffColcounts'...
              );
        whos('GAMMAvalcode','GAMMAvalcounts','GAMMAvallen','GAMMAnegcode',...
             'GAMMARowStartcode','GAMMARowStartcounts','GAMMARowStartlen',...
             'GAMMAdiffRowcode','GAMMAdiffRowcounts',...
             'GAMMAdiffColcode','GAMMAdiffColcounts');
        whos('Dictvalcode','Dictvalcounts','Dictvallen','Dictnegcode',...
             'DictRowStartcode','DictRowStartcounts','DictRowStartlen',...
             'DictdiffRowcode','DictdiffRowcounts',...
             'DictdiffColcode','DictdiffColcounts');  
        whos('GAMMAqMAX');
        whos('Ap');
        
%% Write File and save stats
filename = 'im1';


fid    = fopen(filename,'w');

CODEHED = 0;
codevars = {'GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode'...
           ,'GAMMAdiffRowcode','GAMMAdiffColcode'...
           ,'Dictvalcode','Dictnegcode','DictRowStartcode'...
           ,'DictdiffRowcode','DictdiffColcode'...
            };
        
CODELEN  = zeros(size(codevars));
CODEHEDLEN = 0;           
for i=1:length(codevars)
    eval(sprintf('stream=%s;',codevars{i}));
    [CODELEN(i),HEDTMP] = write_stream2file (stream,fid);
    CODEHEDLEN = CODEHEDLEN + HEDTMP;
end

countsvars = {'GAMMAvalcounts','GAMMARowStartcounts',...
              'GAMMAdiffRowcounts','GAMMAdiffColcounts',...
              'Dictvalcounts','DictRowStartcounts',...
              'DictdiffRowcounts','DictdiffColcounts',...
              };



filesize = ftell(fid)
fclose(fid);
    
fid = fopen(filename,'r');
stream = read_streamfile(fid);
fclose(fid);
        
        
    