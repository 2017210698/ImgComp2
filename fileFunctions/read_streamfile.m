function stream = read_streamfile(fid)
    len    = fread(fid,1,'uint32'); 
    pad    = fread(fid,1,'uint8');
    streamU8 = fread(fid,len,'uint8');
    stream = de2bi(streamU8,8);
    stream = reshape(stream,1,[]);
    stream = stream(1:end-pad);
end

