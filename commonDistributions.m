function [idx_keep, idx_reject] = commonDistributions(binstep, inps)
% take a binstep and a set of distributions (in a cell array) as input
% returns for each distribution the indices of the values that are common
% in all of them
% Anne Urai, 2015

if ~exist('binsize', 'var'), binstep = 0.020; end

% make behaviour of randsample replicable!
rng default

% get the start and end of both the distributions
binmin = cellfun(@min, inps) - binstep;
binmax = cellfun(@max, inps) + binstep;

% preallocate indices
for i = 1:length(inps),
    idx{i} = zeros(size(inps{i}));
end

% compute the edges at which we will compare the two distributions
edges = binmin:binstep:binmax;

% loop over edgebins
for e = 1:length(edges) - 1,
    
    % which idx are in this bin?
    for i = 1:length(inps), this_idx{i} = find(inps{i} > edges(e) & inps{i} < edges(e+1));  end
    
    % what's the smallest nr of entries that we have in this bin
    minNr = min(cellfun(@length, this_idx, 'UniformOutput', true));
    
    % for each edge, select this lowest nr of samples from all distribution
    for i = 1:length(inps),
        rand_idx = this_idx{i}(randsample(numel(this_idx{i}), minNr));
        idx{i}(rand_idx) = 1;
    end
end

% return idx rather than logical
for i = 1:length(inps),
    idx_keep{i} = find(idx{i} == 1);
    idx_reject{i} = find(idx{i} == 0);
end

end % function


