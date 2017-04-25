function chiSquare = exgauss_chi_square(y,X)
% EXGAUSS_CHI_SQUARE Computes the chi-square statistic
%
% DESCRIPTION 
% Pearson's chi-squared test provides a measure of goodness-of-fit, based
% on the observed and predicted frequencies. The observed response times
% are grouped into bins. The edges of these bins are based on response time
% quantiles corresponding to the cumulative probabilities .1, .3, .5, .7,
% and .9. Next, the number of observed and predicted response times between
% these bin edges is determined, based on which the Chi-squared statistic
% is computed.
%
% SYNTAX 
% chiSquare = CHI_SQUARE(y,X);   
%
% y             - Nx1 vector of observed response times
% X             - 1x3 best-fitting parameter values (mu,sigma,tau)
%
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Thu 26 Jun 2014 20:01:05 CDT by bramzandbelt 
% $Modified: Thu 26 Jun 2014 20:01:05 CDT by bramzandbelt

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 1. VARIABLE HANDLING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 1.1. Define static variables
% =========================================================================
CUM_PROB            = .1:.2:.9; % Quantiles for defining response time bins

% 1.2. Get rid of zeros and NaN in data and ensure a column vector
% =========================================================================
y                   = sort(nonzeros(nonnans(y(:))));

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 2. COMPUTE BIN EDGES AND PROBABILITY MASSES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 2.1. Response time bin edges of observed response times
% =========================================================================
binEdges            = quantile(y,CUM_PROB);

% 2.2. Probability masses for observed response times
% =========================================================================
histCount           = histc(y,[-Inf,binEdges,Inf]);
histCount           = histCount(1:end-1);
pMObs               = histCount./sum(histCount);
pMObs               = pMObs(:);

% 2.3. Probability masses for predicted response times
% =========================================================================
pMPrd               = diff([0,exgauss_cdf(binEdges,X),1]);
pMPrd               = pMPrd(:);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 3. COMPUTE PEARSON'S CHI-SQUARED STATISTIC
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
nObs                = numel(y);
chiSquare           = nObs.*sum(((pMObs - pMPrd).^2)./pMPrd);