function NNZ = cellArrayNNZ(varargin)
    N = nargin;
    NNZ = 0;
    for i=1:N
        NNZ = NNZ + NNZCELLARRY(varargin{i}); 
    end
end

function NNZ =NNZCELLARRY(GAMMA) 
    NNZ=0;
    for i=1:size(GAMMA,1)
        for j=1:size(GAMMA,2)
            NNZ=NNZ+nnz(GAMMA{i,j});
        end
    end
end

