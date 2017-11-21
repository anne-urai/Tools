function [] = plotBetas(beta, colors)
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

if ~exist('colors', 'var'); colors = cbrewer('qual', 'Set1', 8); end
if numel(colors) == 1, colors = colors * ones(size(beta, 1), 3); end
global mypath;

% barplot with individual datapoints
hold on;
for i = 1:size(beta, 2),
    b = bar(i, squeeze(nanmean(beta(:, i))), ...
        'edgecolor', 'none', 'facecolor', colors(i, :), 'barwidth', 0.4);
 %   b.BaseLine.LineStyle = 'none';
end

% add error bars for SEM
h = ploterr(1:size(beta, 2), squeeze(nanmean(beta)), [], ...
    squeeze(nanstd(beta)) ./ sqrt(size(beta,1)), 'k.', 'abshhxy', 0);
set(h(1), 'marker', 'none');
set(gca, 'xtick', [1 2], 'xminortick', 'off');
ylabel('Beta weights (a.u.)');

% stats
for i = 1:size(beta, 2),
    %pval = permtest(beta(:, i));
    %disp(pval);
    % [~, pval] = ttest(beta(:, i)
    % mysigstar(gca, i, max(get(gca, 'ylim')), pval);
end

axis tight;
if size(beta,2) == 2,
    [~, pval] = ttest(beta(:, 1), beta(:, 2));
    mysigstar(gca, [1 2], max(get(gca, 'ylim'))*1.02, pval);
end

end
