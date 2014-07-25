N = 20;
PSNR  = linspace(25,35,N);
BPP   = zeros(size(PSNR));
rPSNR = zeros(size(PSNR));
for i=1:N
    [rPSNR(i),BPP(i)] = Pmain(PSNR(i));
end
save('18DictRes.mat','BPP','rPSNR');
% figure;plot(BPP,rPSNR);
