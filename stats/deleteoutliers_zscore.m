function outliers = deleteoutliers_zscore(X, threshold, maxiter)
% see https://github.com/mne-tools/mne-python/blob/master/mne/preprocessing/bads.py

outliers = zeros(1, length(X));
if ~exist('threshold', 'var'), threshold = 3; end % zscore cutoff
if ~exist('maxiter', 'var'), maxiter = 1; end % iterations

for it = 1:maxiter,
    
    % zscore
    this_z = nan(1, length(X));
    this_z(~outliers) = abs(zscore(X(~outliers)));
    local_bad = find(this_z > threshold);
    outliers(local_bad) = 1;
    
    if isempty(local_bad),
        break;
    end
end

% return idx
outliers = find(outliers == 1);
