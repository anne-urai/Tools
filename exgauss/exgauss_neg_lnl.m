function fVal = exgauss_neg_lnl(y,X)
% EXGAUSS_NEG_LNL computes the negative log-likelihood of the ex-Gaussian
%  
% DESCRIPTION 
% Computes the negative log-likelihood of the ex-Gaussian.
% 
% SYNTAX 
% fVal = EXGAUSS_NEG_LNL(y,X); 
%
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Tue 07 Jan 2014 14:45:34 CST by bram 
% $Modified: Wed 08 Jan 2014 10:41:54 CST by bram

% Compute the negative log-likelihood
fVal = -sum(log(exgauss_pdf(y,X)));

