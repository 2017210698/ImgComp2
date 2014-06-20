function DynamicRangeStats(X,Xname)
    level = size(X,2);
    mm    = size(X,1); 
    band = {'H','V','D'};
    fprintf('******%s Dynamic Range stats******\n',Xname);
    names  = cell(level*mm,1);
    DR_vec = zeros(level*mm,1);
    iter   = 1;
    for j=1:level
        for i=1:mm
            name  = sprintf('%s{%d}',band{i},j);
            DR = DynamicRange(X{i,j},'abs');
            names{iter}  = name;
            DR_vec(iter) = DR;
            iter = iter+1;               
        end
    end
    
    [~,ind] = sort(DR_vec);
    for i=1:level*mm
        fprintf('%s: abs(%s) DR:%.2f\n'...
               ,names {ind(i)}...
               ,Xname...
               ,DR_vec(ind(i)));
    end
 end

