function main(TPSNR)
%% High PSNR patch size fit
PatchSize = 4:5;
expLevel  = 1:2;

NNZD = -1*ones(length(expLevel),length(PatchSize));
NNZG = -1*ones(size(NNZD));
BPP = -1*ones(size(NNZD));

 for pp=1:length(PatchSize)
    for ll=1:length(expLevel) 
        [tNNZD,tNNZG,tPSNR,tBPP] = Pmain(expLevel(ll),PatchSize(pp),TPSNR);
        if((tPSNR-TPSNR)<0.1)
            NNZD(ll,pp) = tNNZD;
            NNZG(ll,pp) = tNNZG;
            BPP (ll,pp) = tBPP;
        end
        save(sprintf('dataSimul/%dPSNRres',TPSNR));
    end
 end
 
end
  