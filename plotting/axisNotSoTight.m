function h = axisNotSoTight(h)
% after axes tight, enable a bit of white space

if ~exist('h', 'var'); h = gca; end

% enforce axis tight
axis(h, 'tight');

% find the current limits
xlims = get(h, 'xlim');
ylims = get(h, 'ylim');

% get the range
xrange = range(xlims);
yrange = range(ylims);

% enlarge with X percent of this range
xAdd = 0.1 * range(xlims);
yAdd = 0.1 * range(ylims);

set(h, 'xlim', [xlims(1) - xAdd xlims(2) + xAdd]);
set(h, 'ylim', [ylims(1) - yAdd ylims(2) + yAdd]);

end

