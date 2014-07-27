function [NNZD,NNZG,PSNR,BPP] = ImgComp(filename,outfilename,Kpar,Wpar,Qpar,Opar)
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
    addpath('contourlet_toolbox/');
%% get Image 
Im= imread(filename);
f1m=2;f1n=2;
    global Gpar;
%     Gpar.pSizeBig   = 7;
%     Gpar.pSizeSmall = 3;
      Gpar.mIm        = size(Im,1);
      Gpar.nIm        = size(Im,2);
      
if(Gpar.plotReconst)
    f1 = figure();subplot(f1m,f1n,1);imshow(Im,[]);title('Original Image')
end
%% Wavelet Transform
%     Wpar.wavelet_name = 'sym8'; dwtmode('per','nodisp');  
%     Wpar.plots = 1;
%     Wpar.level = 6;
    [Ap,Coef] = WaveletEncode(Im,Wpar);
    % Coef are H,V,D 2d wavelet coeffiencets in cell array

if(Gpar.plotReconst)    
    % Reconstruction Check
    Im_rec = WaveletDecode(Ap,Coef,Wpar);
    MSE    =  norm(double(Im)-Im_rec,'fro')/numel(Im);
    PSNR   =  10*log10(255^2/MSE);
    fprintf(sprintf('Wavelet PSNR %.2f\n',PSNR));
end
%% Sparse KSVD (Train Dictionaries)
%     Kpar.perTdictBig   = 0.01;
%     Kpar.perTdictSmall = 0.02;
%     Kpar.Rbig          = 3;
%     Kpar.Rsmall       = 3;
%     Kpar.trainPSNR = 32;
%     Kpar.iternum   = 15;
%     Kpar.printInfo = 0;
%     Kpar.plots     = 0;
    Dict = TrainDictCells(Coef,Kpar);
%% Normalize Dictionaries (degree of freedom)
    for i=1:size(Dict,1)
        for j=1:size(Dict,2)     
                Dict{i,j}=Dict{i,j}./max(abs(Dict{i,j}(:)));
        end
    end
    
%% GOMP (Sparse representations) 
%     Kpar.gomp_test =1;
%     Kpar.targetPSNR = 40;
    [GAMMA] = OMPcells(Coef,Dict,Wpar,Kpar);

    
% eval 
NNZG    = cellArrayNNZ(GAMMA);
NNZD    = cellArrayNNZ(Dict);
    
if(Gpar.plotReconst)    
    % Reconstruction
    tmpCoef0   = SparseToCoef(GAMMA,Dict);
    Im_rec0    = WaveletDecode(Ap,tmpCoef0,Wpar);
    
    % eval 
    MSE    = norm(double(Im)-Im_rec0,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf('*******GOMP END *******\n');
    fprintf(' GOMP PSNR:%.2f, nnz(GAMMA):%d, nnz(Dict):%d, Tot=%d\n',PSNR,NNZG,NNZD,NNZD+NNZG);
    figure(f1);subplot(f1m,f1n,2);imshow(Im_rec0,[]);title(sprintf('GOMP reconstrucion PSNR:%.2f',PSNR));
end
%% Quantization (GAMMA,Dict)
%     Qpar.GAMMAbins = 2^6;
%     Qpar.Dictbins  = 2^5;
%     Qpar.infoDyRange = 0;

    [GAMMAq,GAMMAqMAX,GAMMANegSigns] = QuantizeGAMMA(GAMMA,Qpar);
    [Dictq ,DictNegSigns]            = QuantizeDict(Dict,Qpar);

if(Gpar.plotReconst)   
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
end    
%% Optimazie Gamma
%     Opar.plots = 0;
%     Opar.order = 'GAMMA'; % gamma columned descend population
    [GAMMAq,Dictq,GAMMANegSigns,DictNegSigns] = AlterRowCol(GAMMAq,Dictq,GAMMANegSigns,DictNegSigns,Opar);

if(Gpar.plotReconst)    
    % Reconstruction
    GAMMA2 = DeQuantizeGAMMA(GAMMAq,GAMMAqMAX,GAMMANegSigns,Qpar);
    Dict2  = DeQuantizeDict (Dictq ,DictNegSigns,Qpar);
    tmpCoef2   = SparseToCoef(GAMMA2,Dict2); 
    Im_rec2    = WaveletDecode(Ap,tmpCoef2,Wpar);
    
    % eval
    MSE    = norm(double(Im)-Im_rec2,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf(' Optim PSNR:%.2f\n',PSNR);
end
%%  CCS (Coulmned compressed GAMMA,Dict) 

    [GAMMAval,GAMMAneg,GAMMArow,GAMMAcol]= CssGAMMA(GAMMAq,GAMMANegSigns);
    [Dictval,Dictneg,Dictrow,Dictcol]    = CssDict (Dictq,DictNegSigns);
    
if(Gpar.plotReconst)    
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
end
%% Diff Code (for GAMMAcol ,Dictcol)
    [GAMMAdiffCol,GAMMARowStart,GAMMAdiffRow] = DiffColCCS(GAMMArow,GAMMAcol);
    [DictdiffCol,DictRowStart,DictdiffRow   ] = DiffColCCS(Dictrow ,Dictcol);

if(Gpar.plotReconst)
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
end
%% What is for entropy code 
%     fprintf('****vars to entropy code*****\n');
%         whos('GAMMAval','GAMMAneg','GAMMAdiffCol','GAMMARowStart','GAMMAdiffRow');
%         whos('Dictval','Dictneg','DictdiffCol','DictRowStart','DictdiffRow');
        
%% Entropy Encode (GAMMA)
bins = Qpar.GAMMAbins;
DEFAULTBINS = 32; % keep fixed on 32/64
countsBinsValsGAMMA      = DEFAULTBINS;
countsBinsRowStartGAMMA  = DEFAULTBINS;
countsBinsRowDiffGAMMA   = DEFAULTBINS;
countsBinsColDiffGAMMA   = DEFAULTBINS;
%     ShowHist(GAMMAdiffCol,'GAMMAdiffCol',GAMMARowStart,'GAMMARowStart',GAMMAdiffRow,'GAMMAdiffRow',bins);
%     ShowHist(GAMMAval,'GAMMAval',GAMMAneg,'GAMMAneg',bins);

[GAMMAvalcode,GAMMAvalcounts,GAMMAvallen] = EntropyEncodeVals(GAMMAval,bins,countsBinsValsGAMMA);
[GAMMAnegcode] = Cell2CONT(GAMMAneg);

dictLen = max(DictSize(0,Kpar),DictSize(Wpar.level,Kpar));% max dict len
[GAMMARowStartcode,GAMMARowStartcounts,GAMMARowStartlen] = EntropyEncodeVals(GAMMARowStart,dictLen,countsBinsRowStartGAMMA);
[GAMMAdiffRowcode,GAMMAdiffRowcounts] = EntropyEncodediffRow(GAMMAdiffRow,dictLen,countsBinsRowDiffGAMMA);

GAMMACOLBINS = CELLARRMAX(GAMMAdiffCol);
[GAMMAdiffColcode,GAMMAdiffColcounts] = EntropyEncodediffCol(GAMMAdiffCol,GAMMACOLBINS,countsBinsColDiffGAMMA);

if(Gpar.plotReconst)
% reconstructoin
    [GAMMAval5] = EntropyDecodeVals(GAMMAvalcode,GAMMAvalcounts,GAMMAvallen,bins,countsBinsValsGAMMA,Wpar.level);
    [GAMMAneg5] = CONT2Cell(GAMMAnegcode,GAMMAval5);
    [GAMMARowStart5] = EntropyDecodeVals(GAMMARowStartcode,GAMMARowStartcounts,GAMMARowStartlen,dictLen,countsBinsRowStartGAMMA,Wpar.level);
    [GAMMAdiffRow5 ] = EntropyDecodediffRow(GAMMAdiffRowcode,GAMMAdiffRowcounts,GAMMARowStart5,GAMMAval5,countsBinsRowDiffGAMMA,Wpar.level);
    [GAMMAdiffCol5 ] = EntropyDecodediffColGAMMA(GAMMAdiffColcode,GAMMAdiffColcounts,countsBinsColDiffGAMMA,Wpar.level,Kpar);

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
end
%% Entropy Encode (Dict)
bins = Qpar.Dictbins;
DEFAULTBINS = 32;
countsBinsValsDict      = DEFAULTBINS;
countsBinsRowStartDict  = DEFAULTBINS;
countsBinsRowDiffDict   = DEFAULTBINS;
countsBinsColDiffDict   = DEFAULTBINS;
%     ShowHist(DictdiffCol,'DictdiffCol',DictRowStart,'DictRowStart',DictdiffRow,'DictdiffRow',bins);
%     ShowHist(Dictval,'Dictval',Dictneg,'Dictneg',bins);

[Dictvalcode,Dictvalcounts,Dictvallen] = EntropyEncodeVals(Dictval,bins,countsBinsValsDict);
[Dictnegcode] = Cell2CONT(Dictneg);

dictLen = max(DictSize(0,Kpar),DictSize(Wpar.level,Kpar));
[DictRowStartcode,DictRowStartcounts,DictRowStartlen] = EntropyEncodeVals(DictRowStart,dictLen,countsBinsRowStartDict);
[DictdiffRowcode,DictdiffRowcounts] = EntropyEncodediffRow(DictdiffRow,dictLen,countsBinsRowDiffDict);

DictCOLBINS = CELLARRMAX(DictdiffCol);
[DictdiffColcode,DictdiffColcounts] = EntropyEncodediffCol(DictdiffCol,DictCOLBINS,countsBinsColDiffDict);

if(Gpar.plotReconst)
% Reconstruction
    [Dictval5] = EntropyDecodeVals(Dictvalcode,Dictvalcounts,Dictvallen,bins,countsBinsValsDict,Wpar.level);
    [Dictneg5] = CONT2Cell(Dictnegcode,Dictval5);
    [DictRowStart5] = EntropyDecodeVals(DictRowStartcode,DictRowStartcounts,DictRowStartlen,dictLen,countsBinsRowStartDict,Wpar.level);
    [DictdiffRow5 ] = EntropyDecodediffRow(DictdiffRowcode,DictdiffRowcounts,DictRowStart5,Dictval5,countsBinsRowDiffDict,Wpar.level);
    [DictdiffCol5 ] = EntropyDecodediffColDict(DictdiffColcode,DictdiffColcounts,countsBinsColDiffDict,Wpar.level,Kpar);

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
end
%% What is for file Writing
%     fprintf('****vars to file write code*****\n');
%        whos('GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode',...
%             'GAMMAdiffRowcode','GAMMAdiffColcode',...
%             'Dictvalcode','Dictnegcode','DictRowStartcode',...
%             'DictdiffRowcode','DictdiffColcode'...
%             );
%         
%         whos('GAMMAvalcounts','GAMMARowStartcounts',...
%              'GAMMAdiffRowcounts','GAMMAdiffColcounts',...
%              'Dictvalcounts','DictRowStartcounts',...
%              'DictdiffRowcounts','DictdiffColcounts'...
%               );
%         whos('GAMMAvallen','GAMMARowStartlen',...
%              'Dictvallen','DictRowStartlen'...
%               );
%         whos('GAMMAqMAX');
%         whos('Ap');
        
%% Write File and save stats
% outfile = 'im1';
fid    = fopen(outfilename,'w');

codevars = {'GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode'...
           ,'GAMMAdiffRowcode','GAMMAdiffColcode'...
           ,'Dictvalcode','Dictnegcode','DictRowStartcode'...
           ,'DictdiffRowcode','DictdiffColcode'...
            };
        
CODEVARSLEN  = zeros(size(codevars));
CODEVARSHEDLEN = 0;           
for i=1:length(codevars)
    eval(sprintf('stream=%s;',codevars{i}));
    [CODEVARSLEN(i),HEDTMP] = write_stream2file (stream,fid);
    CODEVARSHEDLEN = CODEVARSHEDLEN + HEDTMP;
end

countsvars = {'GAMMAvalcounts','GAMMARowStartcounts',...
              'GAMMAdiffRowcounts','GAMMAdiffColcounts',...
              'Dictvalcounts','DictRowStartcounts',...
              'DictdiffRowcounts','DictdiffColcounts',...
              };
          
COUNTVARSLEN  = zeros(size(countsvars));
COUNTVARSHEDLEN = 0;  
for i=1:length(countsvars)
    eval(sprintf('COUNTS=%s;',countsvars{i}));
    [COUNTVARSLEN(i),HEDTMP] = write_counts2file (COUNTS,fid,DEFAULTBINS);
    COUNTVARSHEDLEN = COUNTVARSHEDLEN + HEDTMP;
end

varlenvars = {'GAMMAvallen','GAMMARowStartlen',...
              'Dictvallen','DictRowStartlen'...
              };

VALLENVARSLEN = 0;
for i=1:length(varlenvars)
    eval(sprintf('LENS=%s;',varlenvars{i}));
    fwrite(fid,LENS,'uint32');
    VALLENVARSLEN = VALLENVARSLEN + 4;
end



GAMNAMAXLEN = 0;
for i=1:size(GAMMAqMAX,1)
    for j=1:size(GAMMAqMAX,2)
        GAMMAXq = GAMMAqMAX{i,j};
        fwrite(fid,GAMMAXq,'single'); 
        GAMNAMAXLEN = GAMNAMAXLEN + 4;
    end
end

APLEN = 0;
for i=1:size(Ap,1)
    for j=1:size(Ap,2)
        fwrite(fid,Ap(i,j),'single'); 
        APLEN = APLEN+ 4;
    end
end


filesize = ftell(fid);
BPP = filesize/numel(Im);

fclose(fid);
%% stat
if(Gpar.plotBppPie)
    varslabels = {'GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode'...
                  ,'GAMMAdiffRowcode','GAMMAdiffColcode'...
                  ,'Dictvalcode','Dictnegcode','DictRowStartcode'...
                  ,'DictdiffRowcode','DictdiffColcode'...
                  ,'GAMMAvalcounts','GAMMARowStartcounts'...
                  ,'GAMMAdiffRowcounts','GAMMAdiffColcounts'...
                  ,'Dictvalcounts','DictRowStartcounts'...
                  ,'DictdiffRowcounts','DictdiffColcounts'...
                  ,'Ap'...
                  ,'GAMMAmaxq'...
                  ,'CodeHeaders'...
                  ,'CountsHeaders'...
                  ,'vallen'...
                  };
    VARSLEN      = [CODEVARSLEN,COUNTVARSLEN,APLEN,GAMNAMAXLEN,CODEVARSHEDLEN,COUNTVARSHEDLEN,VALLENVARSLEN];

    [VARSLENS,ind]=sort(VARSLEN,'descend');
    varslabelsS = cell(size(varslabels));
    for i=1:length(varslabels)
        if(i<13)
            varslabelsS{i}=varslabels{ind(i)};
        else
            varslabelsS{i}=' ';
        end
    end
    figure; pie(VARSLENS,varslabelsS)
end
%% reading and reconstruction
    % outfilename = 'im1';
    fid = fopen(outfilename,'r');

    codevars = {'GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode'...
               ,'GAMMAdiffRowcode','GAMMAdiffColcode'...
               ,'Dictvalcode','Dictnegcode','DictRowStartcode'...
               ,'DictdiffRowcode','DictdiffColcode'...
                };

    for i=1:length(codevars)
        stream = read_streamfile(fid); %#ok<NASGU>
        eval(sprintf('%sRE=stream;',codevars{i}));
    end

    % test
    for i=1:length(codevars)
        eval(sprintf('res=isequal(%sRE,%s);',codevars{i},codevars{i}));
        if(res==0)
            error('ERR: reading err');
        end
    end

    countsvars = {'GAMMAvalcounts','GAMMARowStartcounts',...
                  'GAMMAdiffRowcounts','GAMMAdiffColcounts',...
                  'Dictvalcounts','DictRowStartcounts',...
                  'DictdiffRowcounts','DictdiffColcounts',...
                  };

    for i=1:length(countsvars)
        stream = read_countsfile(fid,DEFAULTBINS);
        eval(sprintf('%sRE=stream;',countsvars{i}));
    end

    % test
    for i=1:length(countsvars)
        eval(sprintf('res=isequal(%sRE,%s);',countsvars{i},countsvars{i}));
        if(res==0)
            error('ERR: reading err');
        end
    end 


    varlenvars = {'GAMMAvallen','GAMMARowStartlen',...
                  'Dictvallen','DictRowStartlen'...
                  };
    for i=1:length(varlenvars)
        stream = fread(fid,1,'uint32');
        eval(sprintf('%sRE=stream;',varlenvars{i}));
    end

    GAMMAqMAXRE = cell(3,Wpar.level);
    for i=1:size(GAMMAqMAXRE,1)
        for j=1:size(GAMMAqMAXRE,2)
            GAMMAqMAXRE{i,j} = fread(fid,1,'single'); 
        end
    end

    ApRE = zeros(8);
    for i=1:size(ApRE,1)
        for j=1:size(ApRE,2)
            ApRE(i,j) = fread(fid,1,'single'); 
        end
    end
    fclose(fid);

    % reconstruction
    bins = Qpar.GAMMAbins;
    DEFAULTBINS = 32; % keep fixed on 32/64
    countsBinsValsGAMMA      = DEFAULTBINS;
    countsBinsRowStartGAMMA  = DEFAULTBINS;
    countsBinsRowDiffGAMMA   = DEFAULTBINS;
    countsBinsColDiffGAMMA   = DEFAULTBINS;
    dictLen = max(DictSize(0,Kpar),DictSize(Wpar.level,Kpar));
    [GAMMAval6] = EntropyDecodeVals(GAMMAvalcodeRE,GAMMAvalcountsRE,GAMMAvallenRE,bins,countsBinsValsGAMMA,Wpar.level);
    [GAMMAneg6] = CONT2Cell(GAMMAnegcodeRE,GAMMAval6);
    [GAMMARowStart6] = EntropyDecodeVals(GAMMARowStartcodeRE,GAMMARowStartcountsRE,GAMMARowStartlenRE,dictLen,countsBinsRowStartGAMMA,Wpar.level);
    [GAMMAdiffRow6 ] = EntropyDecodediffRow(GAMMAdiffRowcodeRE,GAMMAdiffRowcountsRE,GAMMARowStart6,GAMMAval6,countsBinsRowDiffGAMMA,Wpar.level);
    [GAMMAdiffCol6 ] = EntropyDecodediffColGAMMA(GAMMAdiffColcodeRE,GAMMAdiffColcountsRE,countsBinsColDiffGAMMA,Wpar.level,Kpar);

    bins = Qpar.Dictbins;
    DEFAULTBINS = 32;
    countsBinsValsDict      = DEFAULTBINS;
    countsBinsRowStartDict  = DEFAULTBINS;
    countsBinsRowDiffDict   = DEFAULTBINS;
    countsBinsColDiffDict   = DEFAULTBINS;
    [Dictval6] = EntropyDecodeVals(DictvalcodeRE,DictvalcountsRE,DictvallenRE,bins,countsBinsValsDict,Wpar.level);
    [Dictneg6] = CONT2Cell(DictnegcodeRE,Dictval6);
    [DictRowStart6] = EntropyDecodeVals(DictRowStartcodeRE,DictRowStartcountsRE,DictRowStartlenRE,dictLen,countsBinsRowStartDict,Wpar.level);
    [DictdiffRow6 ] = EntropyDecodediffRow(DictdiffRowcodeRE,DictdiffRowcountsRE,DictRowStart6,Dictval6,countsBinsRowDiffDict,Wpar.level);
    [DictdiffCol6 ] = EntropyDecodediffColDict(DictdiffColcodeRE,DictdiffColcountsRE,countsBinsColDiffDict,Wpar.level,Kpar);

    [GAMMArow6,GAMMAcol6]   = DeDiffCCS(GAMMAdiffCol6,GAMMARowStart6,GAMMAdiffRow6);
    [Dictrow6 ,Dictcol6   ] = DeDiffCCS(DictdiffCol6,DictRowStart6,DictdiffRow6);

    [GAMMAq6,GAMMANegSigns6] = DeCssGAMMA(GAMMAval6,GAMMAneg6,GAMMArow6,GAMMAcol6,Kpar);
    [Dictq6 ,DictNegSigns6 ] = DeCssDict (Dictval6,Dictneg6,Dictrow6,Dictcol6,Kpar);
    GAMMA6 = DeQuantizeGAMMA(GAMMAq6,GAMMAqMAXRE,GAMMANegSigns6,Qpar);
    Dict6  = DeQuantizeDict (Dictq6 ,DictNegSigns6,Qpar);
    tmpCoef6   = SparseToCoef(GAMMA6,Dict6); 
    Im_rec6    = WaveletDecode(ApRE,tmpCoef6,Wpar);

    % eval
    MSE    = norm(double(Im)-Im_rec6,'fro')^2/numel(Im);
    PSNR   = 10*log10(255^2/MSE);
    fprintf(' FINAL  PSNR:%.2f\n',PSNR);
    fprintf(' FINAL  Bpp :%.4f\n',BPP);
if(Gpar.plotReconst)
    figure(f1);subplot(f1m,f1n,4);imshow(Im_rec6,[]);title(sprintf('Final reconstrucion PSNR:%.2f,BPP:%.3f',PSNR,BPP));
end
end

