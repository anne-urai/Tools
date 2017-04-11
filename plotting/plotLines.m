function [] = plotLines(refdata, reftp, stimdata, stimtp, respdata, resptp, fbdata, fbtp)
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

xticks = []; xlabels = {};
for t = 1:length(reftp),
    xticks = [xticks dsearchn(refdata.time', reftp(t))];
    if reftp(t) == 0,
        xlabels = [xlabels '0'];
    else
        xlabels = [xlabels reftp(t)];
    end
end

for t = 1:length(stimtp),
    xticks = [xticks length(refdata.time) + dsearchn(stimdata.time', stimtp(t))];
    if stimtp(t) == 0,
        xlabels = [xlabels '0'];
    else
        xlabels = [xlabels stimtp(t)];
    end
end

for t = 1:length(resptp),
    xticks = [xticks length(refdata.time) + length(stimdata.time) + ...
        dsearchn(respdata.time', resptp(t))];
    if resptp(t) == 0,
        xlabels = [xlabels '0'];
    else
        xlabels = [xlabels resptp(t)];
    end
end

for t = 1:length(fbtp),
    xticks = [xticks length(refdata.time) + length(stimdata.time) + ...
        length(respdata.time) + dsearchn(fbdata.time', fbtp(t))];
    if fbtp(t) == 0,
        xlabels = [xlabels '0'];
    else
        xlabels = [xlabels fbtp(t)];
    end
end

set(gca,  'XTick', xticks, 'XTickLabel', xlabels, ...
    'tickdir', 'out', 'box', 'off');
% offsetAxes;
%xlabel({'Time'; 'from response (s)'});
xlabel('Time (s)');

% add white lines to indicate transitions between intervals
ylims = get(gca, 'ylim'); ylims(1) = ylims(1)*1.1;
x = length(refdata.time)+.5;
l = line([x x], ylims); set(l, 'Color', 'w', 'LineStyle', '-', 'LineWidth', 2);
x = length(refdata.time) + length(stimdata.time) +.5;
l = line([x x], ylims); set(l, 'Color', 'w', 'LineStyle', '-', 'LineWidth', 2);
x = length(refdata.time) + length(stimdata.time) + length(respdata.time) +.5;
l = line([x x], ylims); set(l, 'Color', 'w', 'LineStyle', '-', 'LineWidth', 2);

% add dotted  black lines to indicate event onset
x = dsearchn(refdata.time', 0);
l = line([x x], ylim); set(l, 'Color', 'k', 'LineStyle', '-', 'LineWidth', 0.2);
x = length(refdata.time) + dsearchn(stimdata.time', 0);
l = line([x x], ylim); set(l, 'Color', 'k', 'LineStyle', '-', 'LineWidth', 0.2);
x = length(refdata.time) + length(stimdata.time) + dsearchn(respdata.time', 0);
l = line([x x], ylim); set(l, 'Color', 'k','LineStyle', '-', 'LineWidth', 0.2);
x = length(refdata.time) + + length(stimdata.time) + ...
    length(respdata.time) + dsearchn(fbdata.time', 0);
l = line([x x],ylim); set(l, 'Color', 'k', 'LineStyle', '-', 'LineWidth', 0.2);

set(gca, 'xcolor', 'k', 'ycolor', 'k', 'linewidth', 0.5);
end
