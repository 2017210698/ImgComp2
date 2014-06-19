function [C_r] = getWaveletStream(Ap,H,V,D)
C_r = reshape(Ap,1,[]);
for i=length(H):-1:1
   C_r = [C_r , reshape(H{i},1,[])] ;
   C_r = [C_r , reshape(V{i},1,[])] ;
   C_r = [C_r , reshape(D{i},1,[])] ;
end
end

