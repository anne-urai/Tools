function [X,fVal,exitFlag,solverOutput] = exgauss_fit(y)
% EXGAUSS_FIT fits the ex-Gaussian distribution to a vector of data
%  
% DESCRIPTION 
% Optimizes fits between the data (y) and the ex-Gaussian distribution,
% using maximum likelihood estimation and a bounded Simplex algorithm.
%  
% SYNTAX 
% [X,fVal,exitFlag,solverOutput] = EXGAUSS_FIT(y);
%
% y             - Nx1 vector of observed response times
% X             - 1x3 best-fitting parameter values (mu,sigma,tau)
% fVal          - negative log-likelihood (-fVal is log-likelihood)
% exitFlag      - logical scalar, indicates exit condition of the 
%                 optimization algorithm; if true, the algorithm reached
%                 the pre-specified criteria
% solverOutput  - structure with the information about the optimization:
%                 * number of iterations,
%                 * number of function evaluations
%                 * algorithm
%
% REFERENCES 
% Stephan Lewandowsky, Simon Farrell (2010) Computational Modeling in 
% Cognition: Principles and Practice. SAGE Publications.
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Tue 07 Jan 2014 14:04:13 CST by bram 
% $Modified: Wed 08 Jan 2014 10:41:49 CST by bram


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 1. VARIABLE HANDLING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 1.1. Define static variabls
% ========================================================================= 

% 1.1.1. Cost function
% ------------------------------------------------------------------------- 
costFun                   = @exgauss_neg_lnl; % Negative log-likelihood

% 1.2. Define dynamic variabls
% ========================================================================= 

% 1.1.1. Get rid of zeros and NaN in data and ensure a column vector
% ------------------------------------------------------------------------- 
y                         = sort(nonzeros(nonnans(y(:))));

% 1.1.2. Starting values and bounds
% ------------------------------------------------------------------------- 
[X0,LB,UB]                = exgauss_start_vals(y);

% 1.1.3. Solver options
% ------------------------------------------------------------------------- 
solverOpts                = optimset(@fminsearch);
solverOpts.Display        = 'off';
solverOpts.PlotFcns       = {[]};
solverOpts.MaxFunEvals    = 200*numel(y);
solverOpts.MaxIter        = 200*numel(y);
solverOpts.TolFun         = 1e-6;
solverOpts.TolX           = 1e-6; 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 2. OPTIMIZATION
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

[X,fVal,exitFlag,solverOutput] = fminsearchbnd(@(X) costFun(y,X),X0,LB,UB,solverOpts);