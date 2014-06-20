function [DR,MIN,MAX] = DynamicRange(varargin)

X = varargin{1};
if(nargin>1)
par = varargin{2};
if(strcmp(par,'abs')); X = abs(X); end
end
    MIN = min(X(:));
    MAX = max(X(:));
    DR = MAX-MIN;
end

