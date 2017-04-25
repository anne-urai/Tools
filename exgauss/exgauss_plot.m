function exgauss_plot(plotType,y,X,varargin)
% EXGAUSS_PLOT plots a histogram of the data and a line plot of the mode
%  
% DESCRIPTION 
% Plots a histogram of the data and a line plot of the ex-Gaussian
% distribution with best-fitting parameters
%  
% SYNTAX 
% EXGAUSS_PLOT(plotType,y,X); 
% plotType      - char array, indicating how to plot the data:
%                 * 'pdf', probability density function (PDF)
%                 * 'cdf', cumulative distribution function (CDF)
%                 * 'both', PDF and CDF
% y             - Nx1 vector of observed response times
% X             - 1x3 best-fitting parameter values (mu,sigma,tau)
%
% EXGAUSS_PLOT(plotType,y,X,fileName); 
% fileName      - char array, tag for the filename of figure (optional). 
%                 Figure is saved in presented working directory.
%  
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Tue 07 Jan 2014 14:04:32 CST by bram 
% $Modified: Wed 08 Jan 2014 10:42:02 CST by bram

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 1. VARIABLE HANDLING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 1.1. Define static variables
% ========================================================================= 

% 1.1.1. Quantiles
% ------------------------------------------------------------------------- 
qntls       = .1:.2:.9;

% 1.2. Define dynamic variables
% ========================================================================= 

% 1.2.1. Get rid of zeros and NaN in data, ensure a column vector
% ------------------------------------------------------------------------- 
y           = sort(nonzeros(nonnans(y(:))));
x           = linspace(0,max(y),2000)';

% 1.2.2. Compute number of bins, frequency, and bin centers
% ------------------------------------------------------------------------- 
nBin        = ceil(sqrt(numel(y)));
[N,binCtr]  = hist(y,nBin);
binWidth    = range(binCtr)/nBin;

% 1.1.3. Normalized ex-Gaussian PDF
% ------------------------------------------------------------------------- 
f           = exgauss_pdf(x,X);
fNorm       = numel(y)*f*binWidth;

% 1.1.4. Observed quantiles
% ------------------------------------------------------------------------- 
qObs        = quantile(y,qntls);

% 1.1.4. Predicted cumulative distribution function
% ------------------------------------------------------------------------- 
FPrd        = exgauss_cdf(x,X);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 2. PLOT THE DATA
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

switch lower(plotType)
  case 'pdf'
    hold on;
    plot_pdf
  case 'cdf'
    hold on;
    plot_cdf;
  case 'both'
    hold on;
    subplot(1,2,1);
    plot_pdf;
    subplot(1,2,2);
    plot_cdf;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 3. WRITE FIGURE TO PNG FILE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if ~isempty(varargin)
  print('-dpng',fullfile(pwd,[varargin{1},'.png']));
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 4. NESTED FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% 4.1. Function for computing an empirical distribution function
% =========================================================================
function F = edf(t,y)
%% Empirical distribution function (edf)
%
%% Syntax
% F = mtb_edf(t,y)
%
%% Description
% |F = edf(t,y)| takes an ordered column vector |y| and a column vector of
% points |t| for which the edf is desired. It returns a column vector |F| equal
% in length to the vector |t| containing the points of the edf.
%
%% References
% Van Zandt, T. (2002). Analysis of response time distributions. In: Pashler, H.
% Stevens' handbook of experimental psychology. New York: John Wiley & Sons.
%
% This function is a modified version of Trisha van Zandt's edf.m, accessed at
% http://maigret.psy.ohio-state.edu/~trish/Downloads/matlab/EDF.m on January 6,
% 2012

% Bram Zandbelt, January 2012

% Make sure x and y are sorted column vectors
t = sort(t(:));
y = sort(y(:));

% Compute EDF
F = ones(length(t),1);
for iX=1:length(t)
    F(iX) = sum(y<=t(iX))/length(y);
end

% Replace any nans in data with nan in F
F(isnan(y)) = nan;

end

% 4.2. Function for plotting the probability density function
% =========================================================================
function plot_pdf
  
  cla;hold on;
  
  % 4.2.1. Histogram of observed RT data, white bins
  % -----------------------------------------------------------------------
  bar(binCtr,N,'w');

  % 4.2.2. Normalized ex-Gaussian probability density function, red line
  % -----------------------------------------------------------------------
  plot(x,fNorm,'r-','LineWidth',2);

  % 4.2.3. Labels
  % -----------------------------------------------------------------------
  xlabel('Response time (ms)');
  ylabel('Frequency')
  title(sprintf('\\mu = %.2f, \\sigma = %.2f, \\tau = %.2f',X));
  
  % 4.2.4. Set plot box aspect ratio to golden ratio
  % -----------------------------------------------------------------------
  set(gca,'PlotBoxAspectRatio',[1.6 1,1]);
  
end

% 4.3. Function for plotting the cumulative distribution function
% =========================================================================
function plot_cdf
  
  cla;hold on;
  
  % 4.3.1. Observed RT quantiles, circles
  % -----------------------------------------------------------------------
  plot(qObs,qntls,'ko');

  % 4.3.2. Ex-Gaussian cumulative distribution function, red line
  % -----------------------------------------------------------------------
  plot(x,FPrd,'r-','LineWidth',2);

  % 4.3.3. Labels
  % -----------------------------------------------------------------------
  xlabel('Response time (ms)');
  ylabel('Frequency')
  title(sprintf('\\mu = %.2f, \\sigma = %.2f, \\tau = %.2f',X));
  
  % 4.3.4. Set plot box aspect ratio to golden ratio
  % -----------------------------------------------------------------------
  set(gca,'PlotBoxAspectRatio',[1.6 1,1]);
end

end