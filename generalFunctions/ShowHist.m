function ShowHist(varargin)
    N = (nargin-1)/2;
    
    bins = varargin{nargin};
    for i=1:N
        [ENTSUM,ENTCONCAT] = SHOWHIST(varargin{i*2-1},bins);
        title = varargin{i*2};
        suptitle(sprintf('%s Histograms\n SUM H:%.3e, SUM H CONCAT:%.3e',title,ENTSUM,ENTCONCAT));
    end
end

function [ENTSUM,ENTCONCAT] = SHOWHIST(GAMMA,bins)
    n=size(GAMMA,1);
    m=size(GAMMA,2);
    band = {'H','V','D'};
    figure;
    count = 1;
    ENTSUM = 0;
    GAMCONCAT = []; 
    for j=1:m
        for i=1:n
            name  = sprintf('%s{%d}',band{i},j);
            ENT   =  EntropyCalc(GAMMA{i,j});
            subplot(m,n,count);hist(GAMMA{i,j},bins);title(sprintf('%s,H:%.3e',name,ENT));
            count=count+1;
            ENTSUM=ENTSUM+ENT;
            GAMCONCAT=[GAMCONCAT,GAMMA{i,j}];
        end
    end
    ENTCONCAT = EntropyCalc(GAMCONCAT);
    
end