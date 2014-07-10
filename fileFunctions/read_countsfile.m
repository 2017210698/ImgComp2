function [COUNTS] = read_countsfile(fid,bins)
    stream = read_streamfile(fid,'COUNTS');
    tmp    = reshape(stream,[],log2(bins));
    COUNTS = bi2de(tmp)';
end

