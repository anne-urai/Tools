function [ci] = ci_fromHessian(hessian, alpha)
% An additional method for estimating confidence intervals is to use 
% the covariance matrix (this is completely analogous to using the sum 
% of squares (variances) in simple linear regression. We can get the 
% covariance matrix from our maximum likelihood optimization by inverting
% a matrix known as the hessian (output of fmincon). The diagonal of the covariance 
% matrix contains the parameter variances and therefore if we use 
% the square root of the diagonal scaled by the critical value for the 
% confidence interval we desire (e.g. 95% confidence interval). 

if ~exist('alpha', 'var'), alpha = 0.95; end

varcov  = inv(hessian); % covariance matrix is the inverse of the negative hessian
stderrs = sqrt(diag(varcov)); % standard errors are the sqrt of the diagonal of the covariance matrix
ci      = stderrs*sqrt(chi2inv(alpha,1)); % turn the standard errors into single-sided CI by multiplying by 1.96 (for 95% confidence intervals

end
