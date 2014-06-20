function Dict  = DeQuantizeDict (Dictq ,DictNegSigns,Qpar)
    bins   = Qpar.Dictbins;
    level  = size(Dictq,2);
    band   = {'H','V','D'};
    Dict   = cell(size(Dictq));
    
    % de quantize
    for j = 1:level
        for i = 1:length(band)
            quant  = linspace(0,1,bins);
            % for each row of Dict 
            for row=1:size(Dictq{i,j},1)
                % recover values
                Dict{i,j}(row,:) = quant(Dictq{i,j}(row,:)+1);
                % recover signs
                ind  = DictNegSigns{i,j}(row,:);
                Dict{i,j}(row,ind) = -Dict{i,j}(row,ind);
            end
        end
    end
    
    % recover signs
     Dict{i,j}(DictNegSigns{i,j})=-Dict{i,j}(DictNegSigns{i,j});
end

