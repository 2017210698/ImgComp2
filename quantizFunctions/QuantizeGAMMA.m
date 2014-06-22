function [GAMMAq,GAMMAqMAX,GAMMANegSigns] = QuantizeGAMMA(GAMMA,Qpar)
    
    if(Qpar.infoDyRange);DynamicRangeStats(GAMMA,'GAMMA');end
    bins   = Qpar.GAMMAbins;
    level = size(GAMMA,2);
    band = {'H','V','D'};
    
    GAMMAq        = cell(size(GAMMA));
    GAMMAqMAX     = cell(size(GAMMA));
    GAMMANegSigns = cell(size(GAMMA));
    for j = 1:level
        for i = 1:length(band)
            NegSigns  = GAMMA{i,j}<0;
            GAMMA{i,j}= abs(GAMMA{i,j});
            MAX       = max(GAMMA{i,j}(:));
            codebook  = linspace(0,bins-1,bins);
            tmpParti  = linspace(0,MAX,bins+1);
            partition = tmpParti(2:end-1); 
            % quatize each column of GAMMA
            for col=1:size(GAMMA{i,j},2)
                [GAMMAq{i,j}(:,col),~] = quantiz(GAMMA{i,j}(:,col),partition,codebook);
            end
            GAMMAqMAX{i,j}=MAX;
            GAMMANegSigns{i,j}= NegSigns;
            GAMMANegSigns{i,j}(GAMMAq{i,j}==0)=0;
        end
    end
end