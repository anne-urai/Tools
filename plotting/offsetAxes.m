function [] = offsetAxes(ax, pt, addwhite)
% inspired by Seaborn's despine option, this takes the current axes and
% creates an offset at the origin
% the settings are optimised for subplot(4,4,x) size plots, and saving them
% will return pretty publication-ready figures
%
% Anne Urai, anne.urai@gmail.com

% get an axis handle if we don't have one
if ~exist('ax', 'var'); ax = gca; end
if ~exist('pt', 'var'); pt = 0.1; end % percentage of axes range
if ~exist('addwhite', 'var'); addwhite = false; end

% tickmarks out
set(ax, 'tickdir', 'out', 'tickdirmode', 'manual');
set(ax, 'units', 'points');

% get the axis ranges
axis tight;
xlims = get(ax, 'xlim'); xrange = range(xlims);
ylims = get(ax, 'ylim'); yrange = range(ylims);

% also see which ticks we want to keep
xticks = get(ax, 'xtick');
yticks = get(ax, 'ytick');

% now change the axes limits
xlim(ax, [xticks(1) - pt*xrange xticks(end)]);
ylim(ax, [yticks(1) - pt*yrange yticks(end)]);
set(ax, 'xtick', xticks, 'ytick', yticks);

% compute the size, in range of data, of the tickmark width
pos    = plotboxpos(ax);
xslack = 2 * range(get(ax, 'xlim'))  / pos(3);
yslack = 2 * range(get(ax, 'ylim'))  / pos(4);

if addwhite,
    % cover part of what might be extended data
    hold on;
    a1 = area([xticks(1) - pt*xrange+xslack/3 xticks(1)-xslack/3], [ylims(2) ylims(2)], ...
        'basevalue', yticks(1) - pt*yrange+yslack, 'showbaseline', 'off', 'edgecolor', 'none', 'facecolor', 'w');
    a2 = area([xticks(1) - pt*xrange+xslack/3 xticks(end)], [yticks(1)-yslack yticks(1)-yslack],   ...
        'basevalue', yticks(1) - pt*yrange+yslack, 'showbaseline', 'off', 'edgecolor', 'none', 'facecolor', 'w');
end

% now plot white lines on top of the axes so that they look 'offset'
l = line([xticks(1) - pt*xrange xticks(1)-xslack], [yticks(1) - pt*yrange yticks(1) - pt*yrange ]);
set(l, 'color', 'w', 'linewidth', 3); % horizontal line
l = line([xticks(1) - pt*xrange xticks(1) - pt*xrange], [yticks(1) - pt*yrange yticks(1)-yslack]);
set(l, 'color', 'w', 'linewidth', 3); % vertical line
hold off;

% saving this properly will only work on a white background
set(ax, 'color', 'w');
set(ax, 'linewidth', 1);
set(gca, 'xcolor', 'k', 'ycolor', 'k');

end

function pos = plotboxpos(h)
%PLOTBOXPOS Returns the position of the plotted axis region
%
% pos = plotboxpos(h)
%
% This function returns the position of the plotted region of an axis,
% which may differ from the actual axis position, depending on the axis
% limits, data aspect ratio, and plot box aspect ratio.  The position is
% returned in the same units as the those used to define the axis itself.
% This function can only be used for a 2D plot.
%
% Input variables:
%
%   h:      axis handle of a 2D axis (if ommitted, current axis is used).
%
% Output variables:
%
%   pos:    four-element position vector, in same units as h

% Copyright 2010 Kelly Kearney

% Check input

if nargin < 1
    h = gca;
end

if ~ishandle(h) || ~strcmp(get(h,'type'), 'axes')
    error('Input must be an axis handle');
end

% Get position of axis in pixels

currunit = get(h, 'units');
set(h, 'units', 'pixels');
axisPos = get(h, 'Position');
set(h, 'Units', currunit);

% Calculate box position based axis limits and aspect ratios

darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');

if ~darismanual && ~pbarismanual
    
    pos = axisPos;
    
else
    
    dx = diff(get(h, 'XLim'));
    dy = diff(get(h, 'YLim'));
    dar = get(h, 'DataAspectRatio');
    pbar = get(h, 'PlotBoxAspectRatio');
    
    limDarRatio = (dx/dar(1))/(dy/dar(2));
    pbarRatio = pbar(1)/pbar(2);
    axisRatio = axisPos(3)/axisPos(4);
    
    if darismanual
        if limDarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/limDarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * limDarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    elseif pbarismanual
        if pbarRatio > axisRatio
            pos(1) = axisPos(1);
            pos(3) = axisPos(3);
            pos(4) = axisPos(3)/pbarRatio;
            pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
        else
            pos(2) = axisPos(2);
            pos(4) = axisPos(4);
            pos(3) = axisPos(4) * pbarRatio;
            pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
        end
    end
end

% Convert plot box position to the units used by the axis
temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', get(h, 'parent'));
set(temp, 'Units', currunit);
pos = get(temp, 'position');
delete(temp);
end