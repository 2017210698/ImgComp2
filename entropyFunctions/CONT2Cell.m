function [GAMMAneg] = CONT2Cell(negcode,GAMMAval)
    m=size(GAMMAval,1);
    n=size(GAMMAval,2);
    GAMMAneg=cell(m,n);
    
    ptr = 1;
    for j=1:n
        for i=1:m
             LEN = length(GAMMAval{i,j});
             GAMMAneg{i,j} = negcode(ptr:ptr+LEN-1);
             ptr=ptr+LEN;
        end
    end
end

