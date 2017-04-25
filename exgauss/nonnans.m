function y = nonnans(y)
% NONNANS non-NaN matrix elements
%  
% DESCRIPTION 
% Returns a column vector of the non-NaN elements of y.
%  
% SYNTAX 
% y = NONNANS(y); 
% y   - vector of data
%
% EXAMPLES 
% y = [NaN NaN 3 4 5 6 NaN];
% z = nonnans(y);
%
% ......................................................................... 
% Bram Zandbelt, bramzandbelt@gmail.com 
% $Created : Tue 07 Jan 2014 14:15:05 CST by bram 
% $Modified: Wed 08 Jan 2014 10:44:43 CST by bram

y = y(~isnan(y(:)));