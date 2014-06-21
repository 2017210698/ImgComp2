function GAMMA = DeQuantizeGAMMA(GAMMAq,GAMMAqMAX,GAMMANegSigns,Qpar)
    bins   = Qpar.GAMMAbins;
    level  = size(GAMMAq,2);
    band   = {'H','V','D'};
    GAMMA   = cell(size(GAMMAq));
    % de quantize
    for j = 1:level
        for i = 1:length(band)
            quant  = linspace(0,GAMMAqMAX{i,j},bins);
            % for each col of Gamma 
            for col=1:size(GAMMAq{i,j},2)
               % recover values
               GAMMA{i,j}(:,col) = quant(GAMMAq{i,j}(:,col)+1);
               % recover signs
               ind  = GAMMANegSigns{i,j}(:,col);
               GAMMA{i,j}(ind,col) = -GAMMA{i,j}(ind,col);
            end
        end
    end 
     
end

