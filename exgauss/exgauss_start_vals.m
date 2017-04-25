function [X0,LB,UB] = exgauss_start_vals(y)
% EXGAUSS_START_VALS estimates starting values and bounds for optimization
%  
% DESCRIPTION 
% Estimates starting values for optimization algorithm. The approach is
% based on Lacouture & Cousineau (2008).
%  
% SYNTAX 
% [X0,LB,UB] = EXGAUSS_START_VALS(y);
%
% y   - Nx1 vector of observed response times
% X0  - 1x3 vector of starting values estimated from y (mu,sigma,tau)
% LB  - 1x3 vector of lower bounds, loosely constrained by data
% UB  - 1x3 vector of upper bounds, loosely constrained by data
%  
% EXAMPLES 
% [X0,LB,UB] = exgauss_start_vals(y);
%  
% REFERENCES 
% Lacouture & Cousineau (2008) Tutorials Quant Meth Psych, vol. 4 no. 1, pp
% 35-45.
%
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Tue 07 Jan 2014 13:51:16 CST by bram 
% $Modified: Wed 08 Jan 2014 10:42:09 CST by bram

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 1. VARIABLE HANDLING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 1.1. Define dynamic variabls
% ========================================================================= 

% 1.1.1. Get rid of zeros and NaN in data, ensure a column vector
% ------------------------------------------------------------------------- 
y       = nonzeros(nonnans(y(:)));

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 2. COMPUTE STARTING VALUES AND BOUNDS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 2.1. Compute starting values
% ========================================================================= 
Tau     = std(y).*0.8;
Mu      = mean(y)-Tau;
Sigma   = sqrt(var(y)-(Tau^2));

% Put starting values in a row vector
X0      = [Mu,Sigma,Tau];

% 2.2. Compute bounds
% ========================================================================= 
LB      = [min(y), 0, 0];               % Mu, Sigma, Tau
UB      = [max(y), range(y), range(y)]; % Mu, Sigma, Tau