%% Plot result
function Smain(filename)
    fprintf('Level 1 == 256x256 , Level 6 == 8x8\n');
    if(nargin<1)
%         filename = '25PSNRres';
%         TITLE ='PSNR == 25';
        
        filename = '35PSNRres';
        TITLE ='PSNR == 32';        
    end
    
    IMGS = cell(3,9);
    load(sprintf('dataSimul/%s',filename));
    
    for i=1:length(IMGS)-1
        NNZD = IMGS{i,1};
        NNZG = IMGS{i,2};
        BPP  = IMGS{i,3};
        if(~isempty(NNZD))
            SmainTop(NNZD,NNZG,BPP,TITLE,i)
        end
    end
end

function SmainTop(NNZD,NNZG,BPP,TITLE,imNo)
    expLevel  = 1:size(NNZD,1);   %1:1:6
    PatchSize = (1:size(NNZD,2))+2; %3:1:8
    
    % plotting
    COL1 = lines(length(expLevel));
    m=1;n=4;
    figure('units','normalized','outerposition',[0 0 1 1])
    legendText1 = cell(1,length(COL1));

    % plotting BPP
    subplot(m,n,1)
    for ll=1:length(expLevel)
        plot(PatchSize,BPP(ll,:),'Color',COL1(ll,:));hold on;
        legendText1{ll}=sprintf('level %d',ll);
    end
    legend(legendText1);
    title('BPP vs PatchSize');
    xlabel('PatchSize');
    ylabel('BPP');

    % plotting NNZD, NNZG
    COL2 = copper(length(expLevel));
    legendText2 = cell(1,length(COL1)+length(COL2));
    subplot(m,n,2)
    for ll=1:length(expLevel)
        plot(PatchSize,NNZD(ll,:),'Color',COL1(ll,:));hold on;
        plot(PatchSize,NNZG(ll,:),'.-','Color',COL2(ll,:));hold on;
        legendText2{ll*2-1}  = sprintf('level %d NNZD',ll);
        legendText2{ll*2  }  = sprintf('level %d NNZG',ll);

    end
    legend(legendText2);
    title('NNZD,NNZG vs PatchSize');
    xlabel('PatchSize');
    ylabel('NNZ');

    % plotting TOTAL NNZ
    subplot(m,n,3)
    TOTNNZ = NNZD+NNZG; 
    legendText3 = cell(1,length(COL1));
    for ll=1:length(expLevel)
        plot(PatchSize,TOTNNZ(ll,:),'Color',COL1(ll,:));hold on;
        legendText3{ll}  = sprintf('level %d NNZTOT',ll);
    end
    legend(legendText3);
    title('NNZ TOT vs PatchSize');
    xlabel('PatchSize');
    ylabel('NNZ');

    % plotting the corresopnding image
    
    subplot(m,n,4)
    Im = imread(sprintf('images/%d.gif',imNo));
    imshow(Im,[]);
    
    
    suptitle(sprintf('%s,im %d',TITLE,imNo));

end