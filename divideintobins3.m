function [binnedx, binnedy, binnedz, stdx, stdy, stdz] = divideintobins3(x, y, z, nbins)
% take two vectors and divide x them into nbins, then compute the mean
% response of y for each x

if ~exist('corrtype', 'var'); corrtype = 'Spearman'; end
%assert(~any(isnan(x)), 'x contains nans');
%assert(~any(isnan(y)), 'y contains nans');

if nbins == 2,
    % use quantile rather than histcounts, we want each bin to contain the same nr of points!
    qs      = quantile(x, 0.5);
elseif nbins == 3,
    qs      = quantile(x, [0.33 0.67]);
else
    qs      = quantile(x, nbins - 1);
end

binnedx = nan(1, nbins);
binnedy = nan(1, nbins);
binnedz = nan(1, nbins);

stdx = nan(1, nbins);
stdy = nan(1, nbins);
stdz = nan(1, nbins);

for q = 1:length(qs) + 1,
    
    % determine which trials belong to this quantile
    if q == 1,
        findtrls = find(x <= qs(q));
    elseif q == length(qs) + 1,
        findtrls = find(x > qs(q-1));
    else
        findtrls = find(x <= qs(q) & x > qs(q-1));
    end
    
    % nicer: get bin centres
    % [~, idx] = min(abs(centres-x));
    
    % assert(~isempty(findtrls), 'no trials found in this bin');
    
    % find the mean x and y 
    binnedx(q) = nanmean(x(findtrls));
    binnedy(q) = nanmean(y(findtrls));
    binnedz(q) = nanmean(z(findtrls));
    
    assert(~isnan(binnedx(q)));
    
    % also compute variance
    stdx(q)   = nanstd(x(findtrls));
    stdy(q)   = nanstd(y(findtrls));
    stdz(q)   = nanstd(z(findtrls));
    
end

end