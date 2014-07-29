function [X,Y] = Smain(FEATURE_IND,markerSize,marker)

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
%     ];
% Y = [NNZD,NNZG,BPP];


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
    global MarkerSize;
    global Marker;
    MarkerSize = markerSize;
    Marker     = marker;
    switch FEATURE_IND
        % natural
        case 0  
            BPP     = Y(:,3);   
            figure;plot(BPP,X(:,1),'.');title('PSNR vs bpp');
        % Patch size Big
        case 4
            FEATURE = 4;
            VALS = 3:8;
            map = copper(length(VALS));
            TITLE = 'Color by Patch Size Big';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % Patch size Small
        case 5
            FEATURE = 5;
            VALS = 3:6;
            map = copper(length(VALS));
            TITLE = 'Color by Patch Size Small';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % wavelet ind
        case 6
            FEATURE = 6;
            VALS = 1:3;
            map = hsv(length(VALS));
            TITLE = 'Color by Wavelet';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % Rbig
        case 7 
            FEATURE = 7;
            VALS = 1:0.5:3.5;
            map = hsv(length(VALS));
            TITLE = 'Color by Rbig';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % RSmall
        case 8 
            FEATURE = 8;
            VALS = 1:0.5:3.5;
            map = hsv(length(VALS));
            TITLE = 'Color by RSmall';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % dictBigMaxAtoms
        case 9
            FEATURE = 9;
            VALS = 7:-1:1;
            map = copper(length(VALS));
            TITLE = 'Color by dictBigMaxAtoms';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % dictSmallMaxAtoms
        case 10
            FEATURE = 10;
            VALS = 7:-1:1;
            map = copper(length(VALS));
            TITLE = 'Color by dictSmallMaxAtoms';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % GAMMAbins
        case 11
            FEATURE = 11;
            VALS = 10:10:80;
            map = hsv(length(VALS));
            TITLE = 'Color by GAMMAbins Quant';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);
        % Dictbins
        case 12
            FEATURE = 12;
            VALS = 10:10:80;
            map = hsv(length(VALS));
            TITLE = 'Color by Dictbins Quant';
            paint_and_leg(X,Y,map,FEATURE,VALS,TITLE);


    end
end

function paint_and_leg(PSNR,BPP,map,FEATURE,VALS,TITLE)
    global MarkerSize;
    global Marker;
    figure;
    subplot(1,2,1);
    xyBestFit = inf(2,10);
    
    for i=1:length(PSNR)
        BPPTMP = BPP(i,3); % Bpp
        PSNRTMP = PSNR(i,1); % PSNR
        for m=1:length(xyBestFit)
            if(abs(m+25-1-PSNRTMP)<0.4)
                if(BPPTMP<xyBestFit(1,m))
                    xyBestFit(1,m)=BPPTMP;
                    xyBestFit(2,m)=PSNRTMP;
                end
            end
        end
    end
    xyBestFit(xyBestFit==inf)=NaN;

    
    
    for i=1:length(PSNR)
        BPPTMP = BPP(i,3); % Bpp
        PSNRTMP = PSNR(i,1); % PSNR
        ind  = (PSNR(i,FEATURE)==VALS);
        COL  = map(ind,:); % Big patch size
        plot(BPPTMP,PSNRTMP,Marker,'color',COL,'MarkerSize',MarkerSize); hold on;
    end
        plot(xyBestFit(1,:),xyBestFit(2,:),'MarkerSize',30);

    title(TITLE);

    LEG = cell(1,length(VALS));
    subplot(1,2,2);
    for i=1:size(map,1)
        plot(VALS(i),VALS(i),'.','color',map(i,:),'MarkerSize',30); hold on;
         LEG{i} = sprintf('%g',VALS(i));
    end
    legend(LEG);
    title(TITLE);
    
    
    
end