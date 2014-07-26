function [Dict] = TrainDictCells(Coef,Kpar)
    % train dictionary for each level each directions
    level = size(Coef,2);
    Dict  = cell(1,1);
    
    COEF  = zeros(8);
    for j=level:-1:1
            COEF = [COEF,Coef{1,j}];           %#ok<AGROW>
            COEF = [COEF;Coef{2,j},Coef{3,j}]; %#ok<AGROW>
    end
    
    % for each level each dirction train dictionary
    
    if(Kpar.plots);figure;suptitle('KSVD Dictionaries train reuslts');end

    Kpar.name  = 'ALL_COEF';
    % train Dictionary
    [Dict{1,1},err] = TrainDict(COEF,Kpar,1);   
    % plots
    if(Kpar.plots)
        subplot(1,2,2);plot(err); title(sprintf('%s S-KSVD error convergence',Kpar.name));xlabel('Iteration');ylabel('mean atom num');
        DictNZ = Dict{1,1}(Dict{1,1}~=0);
        subplot(1,2,1);hist(DictNZ,150); title(sprintf('%s Dict (NZ!) Histogram ',Kpar.name));
        drawnow;
    end

end