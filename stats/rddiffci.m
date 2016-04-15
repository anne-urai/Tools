function [rddiff,cilohi,p] = rddiffci(r13,r23,r12,n,alpha)
% function [rddiff,cilohi,p] = rddiffci(r13,r23,r12,n,alpha)
%
% computes a confidence interval (CI) for the difference of two DEPENDENT Pearson
% correlation coefficients and tests whether they are significantly different
%
% In this case, we compare two correlations which have been obtained on a single sample,
% and three interval-scaled variables were assessed. It is of interest whether variable 1
% and variable 2 differ significantly in their ability to predict variable 3.
%
% INPUTS
% r13       Pearson correlation value of variables 1 and 3 (may range from -1 to +1)
% r23       Pearson correlation value of variables 2 and 3 (may range from -1 to +1)
% r12       Pearson correlation value of variables 1 and 2 (may range from -1 to +1)
% n         sample size
% alpha     desired confidence level (usually, 0.05, which will yield a 1-alpha = 0.95 -> 95% CI)
%
% OUTPUTS
% rdiff     abs(r13-r23)
% cilohi    lower and upper confidence bounds for the difference of r1 and r2
% p         p-value for significance testing
%
% EXAMPLE
% [rddiff,cilohi,p] = rddiffci(-0.336,-0.126,0.413,342,alpha)

% FORMULAS TAKEN FROM:
% Diehl and Arbinger, Einfhrung in die Inferenzstatistik (2nd edition), pp. 382
% also see: Bortz, Statistik (4th edition), pp. 204
%
% Construction of confidence intervals is done according to:
% Zou, GY (2007) Toward using confidence intervals to compare correlations.
% Psychological Methods 12: 399.
%
% Note that CI95 and p-value do not agree completely; if you run the above example with 90 subjects,
% for example, the CI95 will not overlap zero but the p-value will still be somewhat >0.05. This is
% because the methods for calculating the p-value and constructing the CI are not 100% identical
%
% Maik C. Stttgen, July 2014
%% input check
if r12<-1 || r12>+1 || r13<-1 || r13>+1 || r23<-1 || r23>+1
    error('r out of bounds')
elseif n<20
    disp('sample size should be >=20 for valid results')
elseif alpha<0 || alpha>1
    error('alpha is out of bounds')
end
%% compute confidence interval according to Zou
critzval  = norminv(1-alpha/2);

covr13r23 = ((r12-0.5*r13*r23) * (1-r13^2-r23^2-r12^2) + r12^3)/n;    % formula 5
var13     = ((1-r13^2)^2)/n;                                          % formula 6
var23     = ((1-r13^2)^2)/n;                                          % formula 6

cilo      = r13 - r23 - critzval*sqrt(var13 + var23 - 2*covr13r23);   % formula 3
cihi      = r13 - r23 + critzval*sqrt(var13 + var23 - 2*covr13r23);   % formula 3

cilohi    = [cilo,cihi];
%% compute p-value according to Diehl and Kohr
rddiff   = r13-r23;

rm = (r13 + r23)/2;
A  = 1 + 2*r12*r13*r23 - r12^2 - r13^2 - r23^2;
W  = ((r13-r23)^2 * (n-1) * (1+r12)) / ...
    (2*A*(n-1)/(n-3) + rm^2*(1-r12)^3);

Tw = sqrt(W);               % critical t value with n-3 degrees of freedom
p  = 2*(1-tcdf(Tw,n-3));    % p-value
%% legacy: compute p-value according to Bortz (yields similar values as Diehl and Kohr)
% rddiff   = r13-r23;
% fz13     = 0.5*log((1+r13)/(1-r13));         % Fisher's z-value for r13
% fz23     = 0.5*log((1+r23)/(1-r23));         % Fisher's z-value for r23
%
% % Steiger's (1980) test statistic:
% % z = (sqrt(n-3) * (fz13 - fz23)) / sqrt(2-2*CV1)
% % CV1 = (1/(1-ra^2)^2) * (r12*(1-2*ra^2) - 0.5 * ra^2 * (1-2*ra^2-r12^2))
% % ra = (r13 + r23)/2
%
% ra  = (r13 + r23)/2;
% CV1 = (1/(1-ra^2)^2) * (r12*(1-2*ra^2) - 0.5 * ra^2 * (1-2*ra^2-r12^2));
% z   = (sqrt(n-3) * (fz13 - fz23)) / sqrt(2-2*CV1);
% critcdf = normcdf(abs(z));
% p = 2*(1-critcdf);
% disp(p)