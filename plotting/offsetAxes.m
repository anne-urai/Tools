function offsetAxes(ax, offset)
% this function 'despines' the x- and y-axes, letting them begin at the
% first tick mark
% thanks to Pierre Morel & undocumented Matlab
% and https://stackoverflow.com/questions/38255048/separating-axes-from-plot-area-in-matlab
%
% by Anne Urai, 2016

if ~exist('ax', 'var'), ax = gca; end
if ~exist('offset', 'var'), offset = 4; end

% set(gca, 'xcolor', 'k', 'ycolor', 'k');

% modify the x and y limits to below the data (by a small amount)
ax.XLim(1) = ax.XLim(1)-(ax.XTick(2)-ax.XTick(1))/offset;
ax.YLim(1) = ax.YLim(1)-(ax.YTick(2)-ax.YTick(1))/offset;

% this will keep the changes constant even when resizing axes
addlistener(ax, 'MarkedClean', @(obj,event)resetVertex(ax));

end

function resetVertex ( ax )
% extract the x axis vertext data

% X, Y and Z row of the start and end of the individual axle.
ax.XRuler.Axle.VertexData(1,1) = min(get(ax, 'Xtick'));
ax.XRuler.Axle.VertexData(1,2) = max(get(ax, 'Xtick'));

% repeat for Y (set 2nd row)
ax.YRuler.Axle.VertexData(2,1) = min(get(ax, 'Ytick'));
ax.YRuler.Axle.VertexData(2,2) = max(get(ax, 'Ytick'));

end
