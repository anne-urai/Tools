function [dist, pval] = permtest(dat1, dat2, nperms)
% does a permutation test between two vectors

if ~exist('dat2', 'var'),   dat2 = zeros(size(dat1)); end
if ~exist('nperms', 'var'), nperms = 10000; end

% reshape
dat1 = dat1(:);
dat2 = dat2(:);
dat = [dat1 dat2];

% shape
design = logical([ones(size(dat(:,1))) zeros(size(dat(:,2)))]);
difference = mean(dat1 - dat2);

% preallocate
dist = nan(1, nperms);
shuf = nan(length(dat), size(design, 2));

for n = 1:nperms, 
    
    % create a shuffling vector
    for i = 1:length(dat),
        shuf(i, :) = design(i, randperm(size(design,2)));
    end
    
    % shuffle the values between the two vectors on each permutation
    tmpdat1 = dat(shuf==1);
    tmpdat2 = dat(shuf==0);
    
    %[~, ~, ~, tmpstats] = ttest(tmpdat1, tmpdat2);
    dist(n) = mean(tmpdat1 - tmpdat2);
end

% two-tailed
pval1 = length(find(dist > difference)) / nperms;
pval2 = length(find(dist < difference)) / nperms;

pval = min([pval1, pval2]);

if isnan(difference),
    pval = nan;
end
end