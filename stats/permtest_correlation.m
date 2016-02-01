function [pval, RealCorrDiff] = permtest_correlation(x, y1, y2, tail, nrand)
% test if two correlations are different

if ~exist('nrand', 'var'), nrand = 10000; end
if ~exist('tail', 'var'), tail = 0; end

% the real correlations of both y1 and y2
RealCorrDiff = corr(x, y1, 'type', 'Pearson', 'rows', 'pairwise') ...
    - corr(x, y2, 'type', 'Pearson', 'rows', 'pairwise');

alldat = [y1 y2];
permDiff = nan(1, nrand);
randdat = nan(length(x), 2);

for n = 1:nrand,

    % flip every subject or not
    for i = 1:length(x),
        randdat(i, :) = alldat(i, randperm(size(alldat,2)));
    end
    
    % compute the difference
    permDiff(n) = corr(x, randdat(:, 1), 'type', 'Pearson', 'rows', 'pairwise') - ...
        corr(x, randdat(:, 2), 'type', 'Pearson', 'rows', 'pairwise');
end

% based on the tail, compute our pvalue
switch tail
    case 0
        pval = length(find(abs(permDiff) >= abs(RealCorrDiff)))/nrand;
    case {-1,1}
        pval = length(find(tail*(permDiff) >= tail*(RealCorrDiff)))/nrand;
end

end