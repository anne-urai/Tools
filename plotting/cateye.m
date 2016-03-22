function h = cateye(Y, x, col, wid, rawhist)
%
%cateye(Y, x, [c=hsv(size(Y,2)), wid=2, rawhist])
%
% Plots cat eye graph showing how data X are distributed (using kernel density function).
%  Each column of Y is a variable to plot a cat eye for.
%  The input x defines the x position of each cat eye.
%   This can be left empty if you want to use 1:size(Y,2).
%
%  The optional col defines the colour.
%  The optional wid defines the line width.
%  If the optional rawhist is true, the raw histogram is plotted.
%

% Number of variables
n = size(Y,2);

if nargin < 2
    x = [];
    col = hsv(n);
    wid = 2;
    rawhist = false;
elseif nargin < 3
    col = hsv(n);
    wid = 2;
    rawhist = false;
elseif nargin < 4
    wid = 2;
    rawhist = false;
elseif nargin < 5
    rawhist = false;
end

% Standard x range?
if isempty(x)
    x = 1:n;
end

% All same colour?
if size(col,1) == 1
    col = repmat(col, n, 1);
end

% Plot cat eyes
hold on
h = [];
for i = 1:n
    qs = prctile(Y(:,i), [25 75]); % Quartiles
    if rawhist
        [dn, dx] = hist(Y(:,i)); % Raw histogram
    else
        [dn, dx] = ksdensity(Y(:,i), min(Y(:,i)):range(Y(:,i))/100:max(Y(:,i))); % Smooth distribution
    end
    dn = dn / max(dn) * 0.3; % Normalise density
    % Plot cat eye
    h = [h; fill([dn -fliplr(dn)]+x(i), [dx fliplr(dx)], (col(i,:)+[2 2 2])/3, 'edgecolor', col(i,:), 'linewidth', wid)];
    % Plot inter-quartile range
    line([1 1] * x(i), qs, 'color', (col(i,:)+[0 0 0])/2, 'linewidth', wid);
    % Plot median
    scatter(x(i), median(Y(:,i)), 10, 'o', 'markeredgecolor', (col(i,:)+[0 0 0])/2, 'markerfacecolor', (col(i,:)+[0 0 0])/2, 'linewidth', wid);
    % Plot mean
    scatter(x(i), mean(Y(:,i)), 10, '*', 'markeredgecolor', (col(i,:)+[0 0 0])/2, 'linewidth', wid);
end
hold off

set(gca, 'xtick', x(1):x(end));
xlim([0 x(end)+1]);
