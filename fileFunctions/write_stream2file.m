%% wrtie stream 2 file function
function [BYTELEN,HEADBYTELEN] = write_stream2file (stream,fid,LEN)
    tmp_len = length(stream);
    pad     = mod(8-mod(tmp_len,8),8);
    stream  = [stream , zeros(1,pad)];
    % sainty check
        if(mod(size(stream,2),8)~=0);fprintf('ERR Padding write file BUG\n');end
    % shape as 8 byte stream
    streamU8 = reshape(stream,[],8);
    streamU8 = bi2de(streamU8);
    len      = length(streamU8);
    if(nargin<3)
        fwrite(fid,len,'uint32'); 
        strSize = 4;
            if(len>2^32-1)
                 error('ERR write_stream2file "len" overflows uint32'); 
            end
    elseif(strcmp(LEN,'COUNTS'))
        fwrite(fid,len,'uint8'); 
        strSize = 1;
            if(len>2^8-1)
                 error('ERR write_stream2file "len" overflows uint8'); 
            end
    end
    fwrite(fid,pad,     'uint8' );
    strSize = strSize + 1;
    fwrite(fid,streamU8,'uint8' );
    HEADBYTELEN = strSize;
    BYTELEN     = length(stream)/8;   
end
