function [pSize] = PatchSize(level)
    global Gpar;
    if(level==Gpar.expLevel)
          pSize = Gpar.expPatchSize;
    elseif(level<3)
          pSize= Gpar.pSizeBig;
    else
          pSize= Gpar.pSizeSmall;
    end
end

