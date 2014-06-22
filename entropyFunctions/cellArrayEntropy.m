function ENT = cellArrayEntropy( varargin )
    N = nargin;
    ENT = 0;
    for i=1:N
        ENT = ENT + CELLARRAYENT(varargin{i}); 
    end
end

function ENT = CELLARRAYENT(GAMMA)
    m = size(GAMMA,1);
    n = size(GAMMA,2);
    ENT = 0;
    for i=1:m
        for j=1:n
            ENT = ENT + EntropyCalc(GAMMA{i,j});
        end
    end


end