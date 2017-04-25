function f = exgauss_pdf(y,X)
% EXGAUSS_PDF computes probability density
%  
% DESCRIPTION 
% Computes probability density for each of the data points in y, given the
% the vector of ex-Gaussian parameters X
%  
% SYNTAX 
% f = EXGAUSS_PDF(y,X);
% 
% EXAMPLES
% Mu    = 400;
% Sigma = 50;
% Tau   = 100;
% X     = [Mu, Sigma, Tau];
% y     = 200:0.1:1000;
% f     = EXGAUSS_PDF(y,X);
%
% REFERENCES 
% Stephan Lewandowsky, Simon Farrell (2010) Computational Modeling in 
% Cognition: Principles and Practice. SAGE Publications.
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Tue 07 Jan 2014 15:32:09 CST by bram 
% $Modified: Wed 08 Jan 2014 10:41:57 CST by bram

% Decode parameters
Mu    = X(1);
Sigma = X(2);
Tau   = X(3);

% Compute density of ex-Gaussian
f     = (1./Tau).* ...
        exp(((Mu - y)./Tau) + ((Sigma.^2)./(2.*Tau.^2))).* ...
        .5.*(1+erf((((y-Mu)./Sigma) - (Sigma./Tau))./sqrt(2)));