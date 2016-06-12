function scatterHistDiff(x, y, xeb, yeb, colors)
% Anne Urai, 2016

% when no errorbars are present
if ~exist('xeb', 'var'), xeb = []; end
if ~exist('yeb', 'var'), yeb = []; end
if ~exist('colors', 'var'), colors = [0.8 0.8 0.8]; end

% make an inset in the corner with histogram
hold on;
axis(gca, 'square');
main_fig        = findobj(gca,'Type','axes');
axpos           = get(main_fig, 'Position');
h_inset         = copyobj(main_fig, main_fig.Parent);

% make a normal scatter plot using plot_err and individual datapoint errorbars
if size(colors, 1) > 1,
    for i = 1:size(x, 1),
        h = ploterr(x(i), y(i), xeb(i), yeb(i), '.');
        set(h(1), 'color', colors(i, :), 'markerfacecolor', colors(i, :), 'markersize', 7);
        set(h(2), 'color', colors(i, :), 'linewidth', 0.5);
        set(h(3), 'color', colors(i, :), 'linewidth', 0.5);
    end
else
    % plot all with the same color
    h = ploterr(x, y, xeb, yeb, '.k');
    set(h(1), 'markersize', 7);
end

% set axes
axis(main_fig, 'tight');
xlims = get(main_fig, 'xlim'); ylims = get(main_fig, 'ylim');
minAx = min([xlims ylims]); maxAx = max([xlims ylims]);
rangeAx = range([minAx maxAx]);
minAx = minAx - rangeAx*0.03; maxAx = maxAx + rangeAx*0.03;
xlim(main_fig, [minAx maxAx]); ylim(main_fig, [minAx maxAx]);
set(main_fig, 'xtick', get(main_fig, 'ytick'));

% line of identity
l = refline(1,0);
set(l, 'color', 'k', 'linestyle', '-', 'linewidth', 0.5);

% show bar in inset
histogram(h_inset, x-y, 'edgecolor', [0 0 0], ...
    'facecolor', [0.4 0.4 0.4]);

% do statistics on the pairs, paired t-test
[~, pval] = ttest(x, y);
mysigstar(h_inset, nanmean(x-y), max(get(h_inset, 'ylim')*1.1), pval);

% change position and rotation of the histogram inset
insetSize = axpos(3) * 0.5;
rightTopX = axpos(1) + axpos(3) - 0.5*insetSize;
rightTopY = axpos(2) + axpos(4);
set(h_inset,'Position', ...
    [rightTopX rightTopY insetSize insetSize], ...
    'view', [45 90], 'box', 'off', 'ytick', [], 'ycolor', 'w', 'fontsize', 5, ...
    'xlim', [-max(abs(x-y))*1.2 max(abs(x-y))*1.2]);

end
