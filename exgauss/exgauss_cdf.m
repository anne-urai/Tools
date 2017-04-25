function F = exgauss_cdf(y,X)
% EXGAUSS_CDF computed cumlative distribution function 
%  
% DESCRIPTION 
% Computes cumulative distribution function for each of the data points in
% y, given the vector of ex-Gaussian parameters X
%  
% SYNTAX 
% F = EXGAUSS_CDF(y,X);
% 
% EXAMPLES
% Mu    = 400;
% Sigma = 50;
% Tau   = 100;
% X     = [Mu, Sigma, Tau];
% y     = 200:0.1:1000;
% F     = EXGAUSS_CDF(y,X);
%
% REFERENCES 
%  
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Fri 24 Jan 2014 16:18:10 CST by bram 
% $Modified: Fri 24 Jan 2014 16:18:10 CST by bram 

% Decode parameters
Mu    = X(1);
Sigma = X(2);
Tau   = X(3);

% Compute cumulative distribution of ex-Gaussian
part1 = -exp(-y./Tau + Mu./Tau + Sigma.^2./2./Tau.^2);
part2 = normcdf((y-Mu-Sigma.^2./Tau)./Sigma);
part3 = normcdf((y-Mu)/Sigma);
F = part1.*part2 + part3;