function violinPlot_distribution(x, y, color, shrinky)
% inspired by violinPlot, plots a nice-looking patch

if isempty(color), 
	color = [0 0 0];
end

if ~exist('shrinky', 'var'),
	shrinky = 10;
end

[xHist,yHist] = ksdensity(y);
xHist = xHist / shrinky;

% find the percentiles and make patch
xPatch = xHist;
yPatch = yHist;

lowerbnd = prctile(y, 2.5);
upperbnd = prctile(y, 97.5);
yPatch(yPatch < lowerbnd) = lowerbnd;
yPatch(yPatch > upperbnd) = upperbnd;

patch(xPatch+x, yPatch,  color, 'facecolor', color, 'edgecolor', 'none', 'facealpha', 0.5);
hold on;

% outline mean
plot([min(xHist+x) max(xHist+x)], [mean(y) mean(y)], 'w-', 'linewidth', 1);

% outline thicker, on top
plot(xHist+x, yHist, '-', 'color', color, 'linewidth', 0.5);

end