function [h, p, stat] = corr_clustercorr(dat1, behav)
% wrapper around fieldtrip's cluster-based permutation test on a
% timecourse, behaves similarly to matlab's corr
% input: nsubjects x time
% behavioural inputs: nsubjects x 1

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
cfgstats.statistic        = 'ft_statfun_correlationT'; % also for one-sample (but then just against zero

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

% ====================================================== %
% ADD BEHAVIOUR INTO DESIGN MATRIX AS THE FIRST COLUMN
% ====================================================== %

nsubj = size(dat1, 1);
cfgstats.design(1, 1:nsubj) = behav(:)'; % make sure that this is the right dimensions
cfgstats.ivar     = 1;

% call the actual function
stat              =  ft_timelockstatistics(cfgstats, data1);

% output
h = stat.mask;
p = stat.prob;


end


