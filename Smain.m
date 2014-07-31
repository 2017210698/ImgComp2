%% Plot result

% filename = '32PSNRres';
filename = '25PSNRres';
load(sprintf('dataSimul/%s',filename));


fprintf('Level 0 == Approx , Level 6 8x8\n');

% plotting
COL1 = lines(length(expLevel));
m=1;n=3;
figure('units','normalized','outerposition',[0 0 1 1])
legendText1 = cell(1,length(COL1));

% plotting BPP
subplot(m,n,1)
for ll=1:length(expLevel)
    plot(PatchSize,BPP(ll,:),'Color',COL1(ll,:));hold on;
    legendText1{ll}=sprintf('level %d',ll);
end
legend(legendText1);
title('BPP vs PatchSize');
xlabel('PatchSize');
ylabel('BPP');

% plotting NNZD, NNZG
COL2 = copper(length(expLevel));
legendText2 = cell(1,length(COL1)+length(COL2));
subplot(m,n,2)
for ll=1:length(expLevel)
    plot(PatchSize,NNZD(ll,:),'Color',COL1(ll,:));hold on;
    plot(PatchSize,NNZG(ll,:),'.-','Color',COL2(ll,:));hold on;
    legendText2{ll*2-1}  = sprintf('level %d NNZD',ll);
    legendText2{ll*2  }  = sprintf('level %d NNZG',ll);
    
end
legend(legendText2);
title('NNZD,NNZG vs PatchSize');
xlabel('PatchSize');
ylabel('NNZ');

% plotting TOTAL NNZ
subplot(m,n,3)
TOTNNZ = NNZD+NNZG; 
legendText3 = cell(1,length(COL1));
for ll=1:length(expLevel)
    plot(PatchSize,TOTNNZ(ll,:),'Color',COL1(ll,:));hold on;
    legendText3{ll}  = sprintf('level %d NNZTOT',ll);
end
legend(legendText3);
title('NNZ TOT vs PatchSize');
xlabel('PatchSize');
ylabel('NNZ');

suptitle(sprintf('%s',filename));

