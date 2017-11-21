function [h, p, stat] = regress_clustercorr(dat1, contrast, subjidx)
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

% ============================================= %
% GENERAL CFG
% ============================================= %

% do cluster stats across the group
cfgstats                  = [];
cfgstats.method           = 'montecarlo'; % permutation test
cfgstats.statistic        = 'ft_statfun_depsamplesregrT'; % also for one-sample (but then just against zero

% do cluster correction
cfgstats.correctm         = 'cluster';
cfgstats.clusteralpha     = 0.05;
cfgstats.tail             = 0; % two-tailed!
cfgstats.clustertail      = 0; % two-tailed!
cfgstats.alpha            = 0.025;
cfgstats.numrandomization = 1000; % make sure this is large enough
cfgstats.randomseed       = 1; % make the stats reproducible!

% use only our preselected sensors for the time being
cfgstats.channel          = 'channel';
cfgstats.neighbours       = []; % only cluster over data and time

% ============================================= %
% REGRESSION ONTO EXTERNAL VARIABLE
% ============================================= %

cfgstats.design   = [contrast subjidx];
cfgstats.uvar     = 2;
cfgstats.ivar     = 1;

% call the actual function
stat              =  ft_timelockstatistics(cfgstats, data1);

% output
h = stat.mask;
p = stat.prob;


end


