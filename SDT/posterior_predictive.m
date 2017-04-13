function posterior_predictive(stimulus, response, rt, spstart)
% plot posterior predictive as done in Python
% see de Gee et al. eLife 2017, figure 4

if ~exist('spstart', 'var'), spstart = 1; end
colors = linspecer(2);

% recode RTs to be negative
resps = unique(response);
rt(response == resps(1)) = -rt(response == resps(1));

stims = unique(stimulus)';
for s = stims,
    
    subplot(2,2,find(s==stims) + spstart-1);
    hold on;
    
    [dn, dx] = ksdensity(rt(stimulus == s)); % Smooth distribution
    [~, zeropoint] = min(abs(dx));
    ymax = ceil(max(dn)); if ymax == 1, ymax = 2; end
    
    % add the mode
    [~, md1] = max(dn(1:zeropoint));
    [~, md2] = max(dn(zeropoint:end));
    plot(dx([md1 md1]), [0 ymax], 'k');
    plot(dx([md2 md2] + zeropoint), [0 ymax], 'k');
    
    % plot on top again
    histogram(rt(stimulus == s), 'binwidth', 0.1, 'edgecolor', 'none', ...
        'normalization', 'pdf', 'facecolor', [0.5 0.5 0.5]);
    
    % add a smoothed line
    % this is not really the same as the posterior predictive...
    plot(dx(1:zeropoint), dn(1:zeropoint), '-', 'color', colors(1, :), 'linewidth', 2);
    plot(dx(zeropoint:end), dn(zeropoint:end), '-', 'color', colors(2, :), 'linewidth', 2);
    
    % axis tight;
    xlim([-2 2]); ylim([0 ymax]);
    title(sprintf('Stimulus = %d', s));
    xlabel('RT (s)');
    ylabel('Probability');
    box off;
    
end
end