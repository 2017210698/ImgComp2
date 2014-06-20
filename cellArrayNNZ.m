function NNZ = cellArrayNNZ(GAMMA)
    NNZ=0;
    for i=1:size(GAMMA,1)
        for j=1:size(GAMMA,2)
            NNZ=NNZ+nnz(GAMMA{i,j});
        end
    end
end

