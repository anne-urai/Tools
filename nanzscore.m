function out = nanzscore(in, dim)

if ~exist('dim', 'var'),
out = (in - nanmean(in)) ./ nanstd(in);
else
out = (in - nanmean(in, dim)) ./ nanstd(in, [], dim);
end
end
