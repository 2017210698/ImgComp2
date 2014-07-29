%% Plot result
load('dataSimul/32PSNRres');

% plotting
COL = copper(length(expLevel));
m=1;n=5;
figure; 

% plotting BPP
subplot(m,n,1)
for ll=1:length(expLevel)
    plot(PatchSize,BPP(ll,:),'Color',COL(ll,:));hold on;
end
title('BPP vs PatchSize');
xlabel('PatchSize');
ylabel('BPP');

% plotting NNZD, NNZG
COL1 = copper(length(expLevel));
COL2 = winter(length(expLevel));
subplot(m,n,2)
for ll=1:length(expLevel)
    plot(PatchSize,NNZD(ll,:),'Color',COL1(ll,:));hold on;
    plot(PatchSize,NNZG(ll,:),'Color',COL2(ll,:));hold on;
end
title('NNZD(copeer),NNZG(winter) vs PatchSize');
xlabel('PatchSize');
ylabel('NNZ');

% plotting TOTAL NNZ
subplot(m,n,3)
TOTNNZ = NNZD+NNZG; 
for ll=1:length(expLevel)
    plot(PatchSize,TOTNNZ(ll,:),'Color',COL(ll,:));hold on;
end
title('NNZ TOT vs PatchSize');
xlabel('PatchSize');
ylabel('NNZ');

% plotting legened COL1
subplot(m,n,4)
for ll=1:length(expLevel)
    plot(expLevel(ll),expLevel(ll),'.','MarkerSize',30,'Color',COL1(ll,:));hold on;
end
title('legened NNZD');
xlabel('level');
ylabel('level');

% plotting legened
subplot(m,n,5)
for ll=1:length(expLevel)
    plot(expLevel(ll),expLevel(ll),'.','MarkerSize',30,'Color',COL2(ll,:));hold on;
end
title('legened NNZG');
xlabel('level');
ylabel('level');


