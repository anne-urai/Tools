function [ridiff,cilohi,p] = ridiffci(r1,r2,n1,n2,alpha)
% function [ridiff,cilohi,p] = ridiffci(r1,r2,n1,n2,alpha)
% 
% computes a confidence interval (CI) for the difference of two INDEPENDENT Pearson 
% correlation coefficients and tests whether they are significantly different
% 
% INPUTS
% r1        Pearson correlation value of sample 1 (may range from -1 to +1)
% r2        Pearson correlation value of sample 2 (may range from -1 to +1)
% n1        size of sample 1
% n2        size of sample 2
% alpha     desired confidence level (usually, 0.05, which will yield a 1-alpha = 0.95 -> 95% CI)
% 
% OUTPUTS
% ridiff    r1-r2
% cilohi    lower and upper confidence bounds for the difference of r1 and r2
% p         p-value for significance testing
% 
% EXAMPLE
% [ridiff,cilohi,p] = ridiffci(.55,.42,80,75,0.05) yields
% rdiff = 0.13; cilohi = -0.15 0.46; p = 0.298.

% FORMULAS TAKEN FROM: 
% http://davidmlane.com/hyperstat/
% Validated with data from Bortz, Statistik (4th edition), p. 202
% 
% An alternative approach can be found in:
% Zou, GY (2007) Toward using confidence intervals to compare correlations.
% Psychological Methods 12: 399.
% 
% Maik C. Stttgen, July 2014
%% input check
if r1<-1 || r1>+1 || r2<-1 || r2>+1
  error('r out of bounds')
elseif n1<2 || n2<2
  error('sample size is <2')
elseif alpha<0 || alpha>1
  error('alpha is out of bounds')
end
%% compute confidence interval
ridiff   = r1-r2;
critzval = norminv(1-alpha/2);

fz1     = 0.5*log((1+r1)/(1-r1));         % Fisher's z-value for r1
fz2     = 0.5*log((1+r2)/(1-r2));         % Fisher's z-value for r1
serdiff = sqrt((1/(n1-3)) + (1/(n2-3)));  % standard error of the difference (in units of Fisher's z)

ciloz = fz1-fz2 - critzval*serdiff;       % lower bound in z-units
cihiz = fz1-fz2 + critzval*serdiff;       % upper bound in z-units

cilo = (exp(1)^(2*ciloz)-1) / (exp(1)^(2*ciloz)+1);   % lower bound in r-units
cihi = (exp(1)^(2*cihiz)-1) / (exp(1)^(2*cihiz)+1);   % upper bound in r-units

cilohi = [cilo,cihi];
%% compute p-value
critcdf = normcdf(abs(fz1-fz2),0,serdiff);
p = 2*(1-critcdf);