function [binnedx, binnedy, stdx, stdy, rho, pval] = divideintobins(x, y, nbins, corrtype, summaryFunc)
% take two vectors and divide x them into nbins, then compute the mean
% response of y for each x

if ~exist('corrtype', 'var'); corrtype = 'Spearman'; end
if ~exist('summaryFunc', 'var'); summaryFunc = @nanmean; end % to allow for median

switch func2str(summaryFunc)
    case 'nanmean'
        distFun = @nanstd;
    case {'nanmedian', 'median'}
        distFun = @iqr;
end

if nbins == length(unique(x)),
    % split into the categories of x
    thisx = unique(x);
    mybins = nan(1, length(thisx) - 1);
    for i = 1:length(thisx) -1,
        mybins(i) = mean(thisx(i:i+1));
    end
    binIdx = discretize(x, [-inf mybins inf]);
else
    binIdx = discretize(x, [-inf quantile(x, nbins-1) inf]);
end

% get the summary measure for each bin
binnedx = splitapply(summaryFunc, x, binIdx);
binnedy = splitapply(summaryFunc, y, binIdx);

% also get the distribution within each bin
stdx = splitapply(distFun, x, binIdx);
stdy = splitapply(distFun, y, binIdx);

% do some statistics
if ~isempty(corrtype),
    % on binned or non-binned data? binning will change rho, but not really
    % the p-value of the correlation
    [rho, pval] = corr(x(:), y(:), 'type', corrtype);
else
    rho = []; pval = [];
end

end
