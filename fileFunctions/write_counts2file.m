function [LEN,HED] = write_counts2file (counts,fid,bins)
    tmp = de2bi(counts,log2(bins));
    stream = tmp(:)';
    [LEN,HED] = write_stream2file (stream,fid,'COUNTS');
end

