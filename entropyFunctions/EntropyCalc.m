function [ z ] = EntropyCalc(x)
    n = numel(x);
    x = reshape(x,1,n);
%     [u,~,label] = unique(x);
%     p = full(mean(sparse(1:n,label,1,n,numel(u),n),1));
%     z = -dot(p,log2(p+eps));
label = unique(x); 
ENTi = zeros(1,length(label));
parfor i=1:length(label)
    TMP = label(i)==x;
    Pi  = sum(TMP)/n;
    ENTi(i)= Pi*log2(Pi);  
end
z = -1*sum(ENTi);
 
end
