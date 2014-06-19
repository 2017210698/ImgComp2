function a = gomp(D,X,mode,thresh,maxval)
%GOMP Global orthogonal matching pursuit
%
%  GAMMA = GOMP(D,X,'psnr',psnr)
%  GAMMA = GOMP(D,X,'psnr',PSNR,MAXVAL)
%  GAMMA = GOMP(D,X,'error',EPSILON)

%  Ron Rubinstein
%  Computer Science Department
%  Technion, Haifa 32000 Israel
%  ronrubin@cs
%
%  May 2010

switch lower(mode)
  
  case 'psnr'               
    if (nargin<5)   
      maxval = 1;                   % For image values between 0 and 1
    end
    epsilon = maxval*sqrt(numel(X))*10^(-thresh/20);
    
  case 'error'
    epsilon = thresh;

  otherwise
    error('Invalid coding mode');
end


%%%%%%%%%%%%%%%%%%%%%


[n,m]=size(D);

Gamma = D'*X;
R=X;

Z=Gamma.*Gamma;
[maxval,atomids] = max(Z);

ind = cell(1,size(X,2)); i=1;
normR = norm(R,'fro')^2;
while (normR>epsilon^2)
  
  if (mod(i,10000)==0)
    fprintf('Atoms = %d\n',i); 
  end
  
  [val,sampid] = max(maxval);       % block with maximal inner product
  if (val < 1e-12*epsilon^2)        % inner product is zero
    warning('Could not achieve specified global error target');
    break;
  end
  atomid = atomids(sampid);         % the atom producing the max inner product
  
  ind{sampid} = sort([ind{sampid},atomid]);
  smallD = D(:,ind{sampid});
  normR = normR - norm(R(:,sampid))^2;
  R(:,sampid) = X(:,sampid) - smallD*((smallD'*smallD)\(smallD'*X(:,sampid)));
  Gamma(:,sampid) = D'*R(:,sampid);
  Z(:,sampid) = Gamma(:,sampid).*Gamma(:,sampid);
  [maxval(sampid),atomids(sampid)] = max(Z(:,sampid));
  normR = normR + norm(R(:,sampid))^2;
  
  i = i+1;
end

a = zeros(m,size(X,2));
for i = 1:size(X,2)
  smallD = D(:,ind{i});
  a(ind{i},i) = (smallD'*smallD)\(smallD'*X(:,i));
end

end
