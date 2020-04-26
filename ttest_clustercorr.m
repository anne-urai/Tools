function [h, p, stat] = ttest_clustercorr(dat1, dat2)
% wrapper around fieldtrip's cluster-based permutation test on a
% timecourse, behaves similarly to matlab's ttest
% input: nsubjects x time

addpath('~/Documents/fieldtrip'); ft_defaults;

% ============================================= %
% RESHAPE DATA
% ============================================= %

data1.time          = 1:size(dat1, 2);
data1.label         = {'channel'};
data1.dimord        = 'subj_chan_time';
data1.individual    = permute(dat1, [1 3 2]); % make sure there is an empty channel dimension

if exist('dat2', 'var'),
    data2.time          = 1:size(dat2, 2);
    data2.label         = {'channel'};
    data2.dimord        = 'subj_chan_time';
    data2.individual    = permute(dat2, [1 3 2]); % make sure there is an empty channel dimension
else
    data2                = data1;
    data2.individual     = zeros(size(data1.individual)); % fill with zeros
end

% ============================================= %
% GENERAL CFG
% ============================================= %

% do cluster stats across the group
cfgstats                  = [];
cfgstats.method           = 'montecarlo'; % permutation test
cfgstats.statistic        = 'ft_statfun_depsamplesT'; % also for one-sample (but then just against zero
cfgstats.spmversion       = 'spm12';
cfgstats.alpha            = 0.05;
cfgstats.tail             = 0; % two-tailed!
cfgstats.correcttail      = 'prob';

% do cluster correction
cfgstats.correctm         = 'cluster';
cfgstats.clusteralpha     = 0.05;
cfgstats.clustertail      = 0; % two-tailed!
cfgstats.numrandomization = 10000; % make sure this is large enough
cfgstats.randomseed       = 123; % make the stats reproducible!

% use only our preselected sensors for the time being
cfgstats.channel          = 'channel';
cfgstats.neighbours       = []; % only cluster over data and time

% ============================================= %
% SINGLE-SAMPLE TTEST
% ============================================= %

nsubj = size(dat1, 1);
design = zeros(2,2*nsubj);
for i = 1:nsubj,  design(1,i) = i;        end
for i = 1:nsubj,  design(1,nsubj+i) = i;  end
design(2,1:nsubj)         = 1;
design(2,nsubj+1:2*nsubj) = 2;

cfgstats.design   = design;
cfgstats.uvar     = 1;
cfgstats.ivar     = 2;

% call the actual function
stat              =  ft_timelockstatistics(cfgstats, data1, data2);

% output
h = stat.mask;
p = stat.prob;


end


