function ImRE = ImgRead(outfilename,Kpar,Wpar,Qpar,Opar)
%% reading and reconstruction
fid = fopen(outfilename,'r');
DEFAULTBINS = 32; % keep fixed on 32/64
codevars = {'GAMMAvalcode','GAMMAnegcode','GAMMARowStartcode'...
           ,'GAMMAdiffRowcode','GAMMAdiffColcode'...
           ,'Dictvalcode','Dictnegcode','DictRowStartcode'...
           ,'DictdiffRowcode','DictdiffColcode'...
            };
        
for i=1:length(codevars)
    stream = read_streamfile(fid); %#ok<NASGU>
    eval(sprintf('%sRE=stream;',codevars{i}));
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
ImRE    = WaveletDecode(ApRE,tmpCoef6,Wpar);

end

