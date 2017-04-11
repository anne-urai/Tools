function [] = plotBetasSwarm(beta, colors)
% This code reproduces the analyses in the paper
% Urai AE, Braun A, Donner THD (2016) Pupil-linked arousal is driven
% by decision uncertainty and alters serial choice bias.
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the "Software"),
% to deal in the Software without restriction, including without limitation
% the rights to use, copy, modify, merge, publish, distribute, sublicense,
% and/or sell copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% If you use the Software for your own research, cite the paper.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
% DEALINGS IN THE SOFTWARE.
%
% Anne Urai, 2016
% anne.urai@gmail.com

if ~exist('colors', 'var'); colors = cbrewer('qual', 'Set1', size(beta, 2));
    colors = [0 0 0; colors]; end % start with black
hold on; % paired

for i = 1:size(beta, 2),
    bar(i, squeeze(nanmean(beta(:, i))), 'edgecolor', 'none', ...
        'facecolor', [0.8 0.8 0.8], 'barwidth', 0.5);
end

% paired lines
if size(beta, 2) == 2,
    plot(beta', '-', 'color', [0.7 0.7 0.7], 'linewidth', 0.4);
end

% scatter all the points
for i = 1:size(beta, 2),
    scatter(i * ones(1, size(beta, 1)), beta(:, i), ...
        10, colors(i, :), 'o', 'linewidth', 0.5, 'jitter', 'on', 'jitteramount', 0);
end

set(gca, 'xtick', [1 2], 'xminortick', 'off');
ylabel('Beta weights (a.u.)');
axis tight;
xlim([0.5 size(beta,2) + 0.5]);
if size(beta, 2) == 1,
    xlim([0 2]);
end
ylims = get(gca, 'ylim');
yrange = range(ylims);
ylim([ylims(1) - yrange*0.1 ylims(2) + yrange*0.1]);

% stats
for i = 1:size(beta, 2),
    [~, pval, ~, stat] = ttest(beta(:, i), 0, 'tail', 'both');
    %pval = permtest(beta(:, i));
    disp(pval);
    mysigstar(gca, i, max(get(gca, 'ylim')), pval);
end

if size(beta,2) == 2,
    % pval = permtest(beta(:, 1), beta(:, 2));
    [~, pval, ~, stat] = ttest(beta(:, 1), beta(:, 2));
    mysigstar(gca, [1 2], max(get(gca, 'ylim'))*1.1, pval);
end

box off;
end
