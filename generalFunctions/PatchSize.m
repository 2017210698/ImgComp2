function [pSize] = PatchSize(level)
    global Gpar;
    if(level<3)
%         pSize=8;
          pSize= Gpar.pSizeBig;
    else
%         pSize=4;
          pSize= Gpar.pSizeSmall;
    end
end

