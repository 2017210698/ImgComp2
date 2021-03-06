function [GAMMA,Dict,GAMMANegSigns,DictNegSigns] = AlterRowCol(GAMMA,Dict,GAMMANegSigns,DictNegSigns,Opar)
    plots = Opar.plots;
    order = Opar.order; % if 'Dict':by dict column population descend
                        % if 'GAMMA': by Gamma row population descend
    
    level  = size(GAMMA,2);
    mm     = size(GAMMA,1);
    
    % plots
    if(plots)
        n=4;
        m=4;
        band = {'H','V','D'};
        count=1;
        figure(); suptitle('Alter row and col results sample');
        ploti = randi(mm,1,m);
        plotj = randperm(level); plotj = plotj(1:m);
        plotj = sort(plotj);
    end
    
    % alter row col
    for j = 1:level
        for i = 1:mm
           GAM = GAMMA{i,j};
           GAMNE = GAMMANegSigns{i,j};
           DIC = Dict{i,j}; 
           DICNE = DictNegSigns{i,j};
           if(strcmp(order,'GAMMA'))
               % reorder by GAMMA row descending order
                 NNZ = GAM~=0;
                 NNZ = sum(NNZ,2);
           elseif(strcmp(order,'Dict'))
               % reorder by A columns descending order
                 NNZ = DIC~=0;
                 NNZ = sum(NNZ,1);
           end
           
           [~,ind] = sort(NNZ,'descend');
           
           for k=1:length(ind)
                GAMMA        {i,j}(k,:) = GAM  (ind(k),:);
                GAMMANegSigns{i,j}(k,:) = GAMNE(ind(k),:);
                
                Dict        {i,j}(:,k) = DIC  (:,ind(k));
                DictNegSigns{i,j}(:,k) = DICNE(:,ind(k));
           end
           
           % plot if plotij
           if(plots && count<=m)
                if(plotj(count)==j)
                   if(ploti(count)==i)
                       name    =  sprintf('%s{%d}',band{i},j);
                       subplot(m,n,count*4-3);spy(DIC);title(sprintf('Dict %s',name));
                       subplot(m,n,count*4-2);spy(GAM);title(sprintf('GAMMA %s',name));
                       subplot(m,n,count*4-1);spy(Dict{i,j}) ;title(sprintf('Dict %s',name));
                       subplot(m,n,count*4-0);spy(GAMMA{i,j});title(sprintf('GAMMA %s',name));
                       count=count+1;
                   end
                end
           end  
        end
    end
end

