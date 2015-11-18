function [pval] = permtest_interaction(dat, nperms)
% does a permutation test across dimension dim

% shape
design = logical([ones(size(dat(:,1))) zeros(size(dat(:,2)))]);

dif1 = dat(:,1) - dat(:,2);
dif2 = dat(:,3) - dat(:,4);
difference = mean(dif1 - dif2);

% preallocate
dist = nan(1, nperms);

for n = 1:nperms,
    
    % create a shuffling vector
    for i = 1:length(dat),
        shuf(i, :) = design(i, randperm(size(design,2)));
    end
    
    % shuffle the values between the two vectors on each permutation
   % shuffle the values between the two vectors on each permutation
    tmpdat1 = dat(shuf==1);
    tmpdat2 = dat(shuf==0);
    
    %[~, ~, ~, tmpstats] = ttest(tmpdat1, tmpdat2);
    dist(n) = mean(tmpdat1 - tmpdat2);
    
end

% both of these pvals are one tailed, assuming dat1 > dat2 & dat3 > dat4
pval(1) = length(find(dist1 > difference(1))) / nperms;
pval(2) = length(find(dist2 > difference(2))) / nperms;

pval(3) = min([length(find(dist3 > difference(3))) / nperms ...
    length(find(dist3 < difference(3))) / nperms ]);


end