function out = sem(in)
% computes the standard error of the mean, ignoring NaN entries
out = nanstd(in) ./ sqrt(numel(~isnan(in)));

end
