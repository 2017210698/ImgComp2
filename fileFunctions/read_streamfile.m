function stream = read_streamfile(fid,LEN)
    if(nargin<3)
        len    = fread(fid,1,'uint32');
    elseif(strcmp(LEN,'COUNTS'))
        len    = fread(fid,1,'uint8');
    end
     
    pad    = fread(fid,1,'uint8');
    streamU8 = fread(fid,len,'uint8');
    stream = de2bi(streamU8,8);
    stream = reshape(stream,1,[]);
    stream = stream(1:end-pad);
end

