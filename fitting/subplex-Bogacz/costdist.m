function y = costdist (x, numstat, cdf)

% function y = costdist (x, numstat {, cdf})
%
% Function calculates the distribution of the cost function
% Inputs:
%  x - the value of cost function
%  numstat - number of statistics being fitted by fitparam
%  cdf - if = 1 cumulative distribution is found; default = 0

if exist ('fcdf')

if nargin < 3
    cdf = 0;
end

MAXX = 100;
DX = 0.01;
DF = 9;    %degrees of freedom of F dist

xx = 0:DX:MAXX;
fx = (fcdf (xx+DX/2, 1, DF) - fcdf (xx-DX/2, 1, DF)) / DX;   % F(1,9) on the basis of cdf
sfx = fx;               % sum of fx

fprintf ('Finding value of cost function disstribution');
for stat = 2:numstat
    for z = 1:length(xx)
        newsfx(z) = sfx (z:-1:1) * fx(1:z)' * DX;
    end
    sfx = newsfx;
    sfx = sfx / sum (sfx) / DX;
    fprintf ('.');
end
fprintf ('\n');

xindex = round(x/DX) + 1;
if xindex > MAXX / DX
    xindex = round (MAXX / DX);
end

if ~cdf
    y = sfx (xindex);
else
    cdfx(1) = DX * sfx(1)/2;
    for z = 2:max(xindex)
        cdfx(z) = cdfx(z-1) + DX * (sfx(z-1)+sfx(z)) / 2;
    end
    y = cdfx (xindex);
end

else
    disp ('Statistics toolbox must be instaled to find distribution of cost function')
    y = 0;
end