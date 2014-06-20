function DynamicRangeStats(GAMMA)
    level = size(GAMMA,2);
    mm    = 3; 
    band = {'H','V','D'};
    fprintf('******GAMMAS Dynamic Range stats******\n');
    names  = cell(level*mm,1);
    DR_vec = zeros(level*mm,1);
    iter   = 1;
    for j=1:level
        for i=1:mm
            name  = sprintf('%s{%d}',band{i},j);
            DR = DynamicRange(GAMMA{i,j},'abs');
            names{iter}  = name;
            DR_vec(iter) = DR;
            iter = iter+1;               
        end
    end
    
    [~,ind] = sort(DR_vec);
    for i=1:level*mm
        fprintf('%s: abs(GAMMA) DR:%.2f\n'...
               ,names {ind(i)}...
               ,DR_vec(ind(i)));
    end
 end

