function [Dict] = TrainDictCells(Coef,Kpar)
    % train dictionary for each level each directions
    level = length(Coef);
    Dict = cell(3,level);
    
    band = {'H','V','D'};
    % for each level each dirction train dictionary
    
    if(Kpar.plots);figure;suptitle('KSVD Dictionaries train reuslts');end
    count=1;
    
    m = length(band);
      
    for i = 1:level
        for j=1:m
            Kpar.name  = sprintf('%s{%d}',band{j},i);
            [Dict{j,i},err] = TrainDict(Coef{j,i},Kpar);    
            if(Kpar.plots)
                subplot(level,m*2,count*2);plot(err); title(sprintf('%s S-KSVD error convergence',Kpar.name));xlabel('Iteration');ylabel('mean atom num');
                DictNZ = Dict{j,i}(Dict{j,i}~=0);
                subplot(level,m*2,count*2-1);hist(DictNZ,150); title(sprintf('%s Dict (NZ!) Histogram ',Kpar.name));
                drawnow;
                count = count+1;
                
            end
        end
    end

end