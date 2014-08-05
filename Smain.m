function [X,Y] = Smain(FEATURE_IND,activeInd,markerSize,im)
% use: [X,Y] = Smain(FEATURE_IND,ACTIVEVALUES,markerSize)
% exp: [X,Y] = Smain(4,[4,5,6],10);
% exp: [X,Y] = Smain(4,0,10); ACTIVEVALUES = [0] means all values
% 
% Feature vector:
% X = [PSNR                  ...
%     ,Kpar.targetPSNR       ...
%     ,Kpar.trainPSNR        ...
%     ,Gpar.pSizeBig         ...
%     ,Gpar.pSizeSmall       ... 
%     ,wave_ind              ...
%     ,Kpar.Rbig             ... 
%     ,Kpar.Rsmall           ... 
%     ,Kpar.dictBigMaxAtoms  ... 
%     ,Kpar.dictSmallMaxAtoms... 
%     ,Qpar.GAMMAbins        ...
%     ,Qpar.Dictbins         ...
%     ,ImgNo                 ...
%     ];
% TAGS vector
% Y = [NNZD,NNZG,BPP];

    if(nargin>0);
        [X,Y] = SmainTOP(FEATURE_IND,activeInd,markerSize,im);
    else
        FEATURE = 11;
        VALS    = 20:10:60;
        im      = [1];
            SmainTOP(FEATURE,VALS,20,im);        
        X=0;Y=0;
        
        
%         FEATURE = 11;
%         VALS    = 30:10:80;
%         im      = [1,6];
%         for i =1:length(VALS)
%             SmainTOP(FEATURE,VALS(i),10,im);        
%         end
%         X=0;Y=0;
    end

end



function [X,Y] = SmainTOP(FEATURE_IND,activeInd,markerSize,im)

%% Get data

s    = what('dataSimul');
LEN = length(s.mat); 
X   = [];
Y   = [];
for i=1:LEN 
   fullpath = sprintf('%s/%s',s.path,s.mat{i});
   tmpl=load(fullpath);
   X=[X;tmpl.XTOT]; %#ok<AGROW>
   Y=[Y;tmpl.YTOT]; %#ok<AGROW>
end

%% Plot Bpp vs PSNR

% FEATURE_IND = 5;
    global ImgNo;
    global MarkerSize;
    global ActiveInd;
    MarkerSize = markerSize;
    ActiveInd  = activeInd;
    ImgNo      = im;
    
    switch FEATURE_IND
        % natural
        case 0  
            BPP     = Y(:,3);   
            figure;plot(BPP,X(:,1),'.');title('PSNR vs bpp');
        % Patch size Big
        case 4
            FEATURE = 4;
            VALS = 3:8;
            map = lines(length(VALS));
            TITLE = 'Color by Patch Size Big';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % Patch size Small
        case 5
            FEATURE = 5;
            VALS = 3:8;
            map = lines(length(VALS));
            TITLE = 'Color by Patch Size Small';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % wavelet ind
        case 6
            FEATURE = 6;
            VALS = 1:3;
            map = lines(length(VALS));
            TITLE = 'Color by Wavelet';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % Rbig
        case 7 
            FEATURE = 7;
            VALS = 1:0.5:3.5;
            map = lines(length(VALS));
            TITLE = 'Color by Rbig';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % RSmall
        case 8 
            FEATURE = 8;
            VALS = 1:0.5:3.5;
            map = lines(length(VALS));
            TITLE = 'Color by RSmall';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % dictBigMaxAtoms
        case 9
            FEATURE = 9;
            VALS = 7:-1:1;
            map = lines(length(VALS));
            TITLE = 'Color by dictBigMaxAtoms';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % dictSmallMaxAtoms
        case 10
            FEATURE = 10;
            VALS = 7:-1:1;
            map = lines(length(VALS));
            TITLE = 'Color by dictSmallMaxAtoms';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % GAMMAbins
        case 11
            FEATURE = 11;
            VALS = 20:10:80;
            map = lines(length(VALS));
            TITLE = 'Color by GAMMAbins Quant';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % Dictbins
        case 12
            FEATURE = 12;
            VALS = 20:10:80;
            map = lines(length(VALS));
            TITLE = 'Color by Dictbins Quant';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);


    end
end

function paint_and_leg(X,Y,map,FEATURE,VALS,TITLE)
    global MarkerSize;
    global ActiveInd;
    global ImgNo;
    figure('units','normalized','outerposition',[0 0 1 1])
    xyBestFit = cell(1,length(ImgNo));
    for i=1:length(xyBestFit)
        xyBestFit{i} = inf(2,10);
    end
    MARKERS = {'.','*','x','d','v','o'};
    
    for i=1:length(X)
        BPPTMP = Y(i,3); % Bpp
        PSNRTMP = X(i,1); % PSNR
        IMNOTMP = X(i,end); % imgNo
        ind     = (IMNOTMP==ImgNo);
        if(max(ind)==1)
            for m=1:size(xyBestFit{1},2)
                if(abs(m+25-PSNRTMP)<0.4)
                    if(BPPTMP<xyBestFit{ind}(1,m))
                        xyBestFit{ind}(1,m)=BPPTMP;
                        xyBestFit{ind}(2,m)=PSNRTMP;
                    end
                end
            end
        end
    end

    % sperate colors by feature values
    % also speparte by image
    BPP  = cell(1,length(ImgNo));
    PSNR = cell(1,length(ImgNo));
    for j=1:length(ImgNo)
        BPP {j} = NaN(length(VALS),size(X,1));
        PSNR{j} = NaN(length(VALS),size(X,1));
        for i=1:size(X,1)
            ind  = (X(i,FEATURE)==VALS);
            IMNOTMP = X(i,end); % imgNo
            ImInd   = (IMNOTMP==ImgNo);
            if(ImInd(j)==1)
                if(max(VALS(ind)==ActiveInd) || max(ActiveInd==0))
                    BPP {j}(ind,i) = Y(i,3);
                    PSNR{j}(ind,i) = X(i,1);
                end
            end
        end
    end
    
    % plot best fit
    for i=1:length(ImgNo)
        xyBestFit{i}(xyBestFit{i}==inf)=NaN;
        plot(xyBestFit{i}(1,:),xyBestFit{i}(2,:),'Marker',MARKERS{i},'MarkerSize',10); hold on;
    end
    
 
    % plot values
    valhandler = zeros(1,length(ActiveInd));
    for j=1:length(ImgNo)
        for i=1:length(VALS)
            ind = VALS(i)==ActiveInd;
            if(max(ind)==1)
                valhandler(ind) = plot(BPP{j}(i,:),PSNR{j}(i,:),'Marker',MARKERS{j},'MarkerSize',MarkerSize,'MarkerEdgeColor',map(i,:),'color',[1,1,1]); hold on;
            end
        end 
    end

     
    % labels
    labels = cell(1,length(ActiveInd));
    for i=1:length(labels)
        labels{i} = sprintf('%d',ActiveInd(i));
    end
    legend(valhandler,labels);
    
    xlim([0 0.2]);
    ylim([25 36]);
    
    
    ImText = '';
    for i=1:length(ImgNo)
        ImText = strcat(ImText,sprintf('Im:%d(%s),',ImgNo(i),MARKERS{i}));
    end
    
    title(sprintf('%s, ActiveValues:%s, ActiveImg:%s',TITLE,mat2str(ActiveInd),ImText));
    
end