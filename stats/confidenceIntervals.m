function [avg, CIlow, CIup] = confidenceIntervals(x, alpha)
% from a vector, compute the mean and lower and upper confidence intervals

% make sure this has the shape we want
% x = x(:);

if ~exist('alpha', 'var'), alpha = 0.05; end

SEM     = std(x)/sqrt(size(x, 1));                       % Standard Error
ts      = tinv([alpha/2  1-alpha/2],size(x, 1)-1);       % T-Score
avg     = mean(x);
CIlow   = -ts(1)*SEM;                           	     % Confidence Intervals
CIup    = ts(2)*SEM;

end