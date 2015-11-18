function effects = mystat (info)

% function effects = mystat (info)
%
% calculate the following descriptive statistics: 
% effects(1) = error rate compatibile
% effects(2) = error rate incompatible
% effects(3) = RT compatible
% effects(4) = RT incompatible
% effects(5) = RT correct - RT incorrect
% effects(6) = stdev RT compatible
% effects(7) = stdev RT incompatible
%
% with given matrix of data
% matrix has following cols:
% 1: subject num
% 2: block num (where the block is a session where the sub sat for a while
% 3: trial num
% 4: stimulus: 0 is compatible right; 1 is comp. left; 2 is incomp. right; 3 is inc. left
% 5: error: 1 is error, 0 is correct 
% 6: RT
% 7: compatibility: 0 is comp, 1 is incomp.

effects = zeros(7,1);
trials = size(info,1);
ER = 5;
RT = 6;

%Basic markers of trials
good = (info(:,RT) ~= 100);
correct = ~info(:,ER) & good;
incorrect = info(:,ER) & good;
compat = ~info(:,7) & good;
incompat = info(:,7) & good;

%Calculate statistics
effects(2) = mean (info(find(incompat), ER));
effects(1) = mean (info(find(compat), ER));
effects(4) = mean (info(find(incompat), RT));
effects(3) = mean (info(find(compat), RT));
effects(7) = std (info(find(incompat), RT));
effects(6) = std (info(find(compat), RT));
effects(5) = mean (info(find(correct), RT)) - mean (info(find(incorrect), RT));
