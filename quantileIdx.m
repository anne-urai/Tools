function [idx] = quantileIdx(x, nbins)
% for a vector dat, divide into nbins quantiles and return the indices of
% which quantile each datapoint belongs

qs = quantile(x, nbins-1);
idx = zeros(size(x));

for q = 1:nbins,
    
    % determine which trials belong to this quantile
    if q == 1,
        idx(find(x <= qs(q))) = q;
    elseif q == length(qs) + 1,
        idx(find(x > qs(q-1))) = q;
    else
        idx(find(x <= qs(q) & x > qs(q-1))) = q;
    end
end

end