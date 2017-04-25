function outp = criterionshift(response, nextstim, nextresp)
% similar to Fruend choice weights, take the shift in criterion as a
% function of previous trial choice

resps = unique(response); resps = resps(~isnan(resps));

if isempty(resps),
    outp = NaN;
    return
end

assert(numel(resps) <= 2);
for r = 1:length(resps),
    trls = find(response == resps(r));
    [d(r), c(r)] = dprime(nextstim(trls), nextresp(trls));
end

% difference in criterion as a function of previous trial
outp = c(1) - c(end);

end
