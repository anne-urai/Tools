% Script for running a simple ex-Gaussian analysis
% =========================================================================
% 
% Dependencies:
% - MATLAB's Statistics and Optimization Toolboxes
% - John D'Errico's fminsearchbnd file: http://bit.ly/Ky3xll
%
% Explanation of variables:
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
% plotType      - char array, indicating how to plot the data:
%                 * 'pdf', probability density function (PDF)
%                 * 'cdf', cumulative distribution function (CDF)
%                 * 'both', PDF and CDF
% fileName      - char array, Filename of the figure (without path). Figure
%                 is saved as a .png-file in presented working directory.

plotType  = 'both';
fileName  = sprintf('subject_%.4d',1);

% Fit the ex-Gaussian model to the RT data through log-likelihood
% maximization using a constrained Simplex algorithm
[X,fVal,exitFlag,solverOutput] = exgauss_fit(y);

% Compute the goodness of fit using Pearson's chi-squared statistic
chiSquare = exgauss_chi_square(y,X);

% Plot a histogram of the observations with on top the normalized
% ex-Gaussian probability density function (left panel) and the quantiles
% (.1, .3, .5, .7, .9 with on top the ex-Gaussian cumulative distribution 
% function (right panel).
figure;hold on
exgauss_plot(plotType,y,X,fileName);