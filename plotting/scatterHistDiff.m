function scatterHistDiff(x, y, xeb, yeb, colors)
% takes paired data x and y, optional arguments for errorbars around
% individual datapoints (see ploterr) and plots a scatterplot as well as a
% rotated histogram of the differences between the two. 
% requires http://nl.mathworks.com/matlabcentral/fileexchange/22216-ploterr
% 
% Anne Urai, 2016

% when no errorbars are present
if ~exist('xeb', 'var') || isempty(xeb), xeb = nan(1, length(x)); end
if ~exist('yeb', 'var') || isempty(yeb), yeb = nan(1, length(y)); end
if ~exist('colors', 'var'), colors = [0.8 0.8 0.8]; end

% prepare figure proportions
hold on;
axis(gca, 'square');
main_fig        = findobj(gca,'Type','axes');
axpos           = get(main_fig, 'Position');

% make the main figure a bit smaller
axpos(3)        = axpos(3) * 0.8; 
axpos(4)        = axpos(4) * 0.8;
set(main_fig, 'Position', axpos);
h_inset         = copyobj(main_fig, main_fig.Parent);

% line of identity
plot(x,y, '.');

% ensure the same units on the x and y axes
xlims   = get(main_fig, 'xlim'); 
ylims   = get(main_fig, 'ylim');
minAx   = min([xlims ylims]); 
maxAx   = max([xlims ylims]);
% rangeAx = range([minAx maxAx]);
% minAx   = minAx - rangeAx*0.03; 
% maxAx   = maxAx + rangeAx*0.03;

xlim(main_fig, [minAx maxAx]); 
ylim(main_fig, [minAx maxAx]);
set(main_fig, 'xtick', get(main_fig, 'ytick'));

l = refline(1,0);
set(l, 'color', 'k', 'linestyle', '-', 'linewidth', 0.5);

% make a normal scatter plot using plot_err and individual datapoint errorbars
if size(colors, 1) > 1,
    for i = 1:size(x, 1),
        h = ploterr(x(i), y(i), xeb(i), yeb(i), 'o');
        set(h(1), 'color', colors(i, :), 'markerfacecolor', colors(i, :), 'markersize', 7);
        set(h(2), 'color', colors(i, :), 'linewidth', 0.5);
        set(h(3), 'color', colors(i, :), 'linewidth', 0.5);
    end
else
    % plot all with the same color
    scatter(x,y, 10, ...
    'LineWidth', 0.001, ...
    'markeredgecolor', 'w', 'markerfacecolor', colors);
end

% plot mean +- CI on top
h = ploterr(nanmean(x), nanmean(y), ...
    1.96 .* (nanstd(x) / sqrt(numel(x))), ...
    1.96 .* (nanstd(y) / sqrt(numel(y))), ...
    '.', 'abshhxy', 0);
set(h(1), 'color', 'k', 'markerfacecolor', 'k', 'markersize', 1);
set(h(2), 'color', 'k', 'linewidth', 1);
set(h(3), 'color', 'k', 'linewidth', 1);

% make sure the axes didnt change
xlim(main_fig, [minAx maxAx]); 
ylim(main_fig, [minAx maxAx]);
set(main_fig, 'xtick', get(main_fig, 'ytick'));

% show bar in inset
histogram(h_inset, x-y, 'edgecolor', [0 0 0], ...
    'facecolor', [0.4 0.4 0.4]);

try
    % do statistics on the pairs, paired t-test
    [~, pval] = ttest(x, y);
    mysigstar(h_inset, nanmean(x-y), max(get(h_inset, 'ylim')*1.1), pval);
end

% change position and rotation of the histogram inset
insetSize = axpos(3) * 0.5;
rightTopX = axpos(1) + axpos(3) - 0.4*insetSize;
rightTopY = axpos(2) + axpos(4) - 0.05*insetSize;
set(h_inset,'view', [45 90], ...
    'Position', [rightTopX rightTopY insetSize insetSize], ...
    'box', 'off', 'ytick', [], 'ycolor', 'w', 'fontsize', 3, ...
    'xlim', [-max(abs(x-y))*1.2 max(abs(x-y))*1.2]);

end
