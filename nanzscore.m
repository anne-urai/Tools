function out = nanzscore(in)

out = (in - nanmean(in)) ./ nanstd(in);
end