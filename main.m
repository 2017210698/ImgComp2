%% get data
iternum      = 20;
IMGNUM       = 10;
TPSNR        = 25:1:35;
ONLINE_TRAIN = cell(2,IMGNUM);

for i=1:IMGNUM
    filename = sprintf('images/%d.gif',i);
    PSNRVEC = zeros(1,length(TPSNR));
    BPPVEC  = zeros(1,length(TPSNR));
    for p=1:length(TPSNR)
            [PSNRVEC(p),BPPVEC(p)] = Pmain(filename,TPSNR(p),iternum);
    end
    ONLINE_TRAIN{1,i} = BPPVEC; 
    ONLINE_TRAIN{2,i} = PSNRVEC; 
    
    save('dataSimul/Online_train_res','ONLINE_TRAIN');
end
