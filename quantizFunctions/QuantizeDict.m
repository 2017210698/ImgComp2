function  [Dict ,DictNegSigns] = QuantizeDict(Dict,Qpar)
    if(Qpar.infoDyRange);DynamicRangeStats(Dict,'Dict');end
    bins   = Qpar.Dictbins;
    
    level = 1;
    band = {'HVD'};
    
    MAX = 1;
    DictNegSigns = cell(size(Dict));
    for j = 1:level
        for i = 1:length(band)
            NegSigns  = Dict{i,j}<0;
            Dict{i,j} = abs(Dict{i,j});
            codebook  = linspace(0,bins-1,bins);
            tmpParti  = linspace(0,MAX,bins+1);
            partition = tmpParti(2:end-1); 
            % quatize each row of GAMMA
            for row=1:size(Dict{i,j},1)
                [Dict{i,j}(row,:),~] = quantiz(Dict{i,j}(row,:),partition,codebook);
            end
            DictNegSigns {i,j}= NegSigns;
        end
    end
end

