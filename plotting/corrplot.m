function [pvals, pvalsgroup] = corrplot( data, varnames1, varnames2, groupvar, critp)
% mimics the corrplot function from the econometrics toolbox, which I sadly
% do not have. data has to be a table, and varnames the names of the variables
% that should be correlated. if present, will use varname_cilow and varname_cihigh
% to plot confidence intervals around each datapoint.
%
% data can be a table or a structure
%
% if 1 cell array of variable names is given, all will be correlated to all
% if 2 cell arrays are given, they will be correlated against each other
% input bounds, not distance from x/y!
%
% Anne Urai, 1 april 2015

if exist('varnames2', 'var'),
    if isempty(varnames2), clear varnames2; end
end

pvals = [];
pvalsgroup = [];
if ~exist('critp', 'var'), critp = 0.05; end
colormap(linspecer);

% ============================================ %
% CORRELATE ALL MEASURES WITH EACH OTHER
% ============================================ %

if ~exist('varnames2', 'var'),
    
    % prepare data
    for v = 1:length(varnames1),
        dat(v).mean = data.(varnames1{v});
        try
            dat(v).ci = {data.([varnames1{v} '_cilow']); data.([varnames1{v} '_cihigh'])};
        catch
            % fill with zeros so that the ploterr does not crash
            dat(v).ci = {data.(varnames1{v}); data.(varnames1{v})};
        end
    end
    
    nsubpl = length(dat);
    
    for i = 1:nsubpl,
        for j = 1:nsubpl,
            
            subplot(nsubpl, nsubpl, i + (j-1)*nsubpl); hold on;
            
            xslack = 0.1 * range(dat(i).mean);
            yslack = 0.1 * range(dat(j).mean);
            % axisNotSoTight;
            
            if i == j,
                
                if exist('groupvar', 'var'),
                    gr = findgroups(data.(groupvar));
                    if length(unique(gr)) == length(data.(groupvar)),
                        grH = ones(size(gr));
                    else
                        grH = gr;
                    end
                    
                    for g = 1:length(unique(grH)),
                        h = histogram(dat(i).mean(grH == g), round(length(dat(i).mean(grH == g))));
                        set(h(1), 'edgecolor', 'none');
                    end
                    
                    % do stats between the groups!
                    try
                        pvalsgroup = [pvalsgroup ranksum(dat(i).mean(grH == 1), dat(i).mean(grH == 2))];
                        pvalsgroup = [pvalsgroup ranksum(dat(i).mean(grH == 2), dat(i).mean(grH == 3))];
                        pvalsgroup = [pvalsgroup ranksum(dat(i).mean(grH == 1), dat(i).mean(grH == 3))];
                    end
                    
                else
                    % for autocorrelation, plot histfit
                    h = histogram(dat(i).mean, round(length(dat(i).mean)/5));
                    set(h(1), 'edgecolor', 'none', 'facecolor', linspecer(1));
                end
                
                % set(h(2), 'color', 'k', 'linewidth', 0.5);
                axis square;
                axisNotSoTight;
                set(gca, 'yticklabel', [], 'ycolor', 'w');
                % vline(nanmean(dat(i).mean), 'color', 'k', 'linewidth', 1);
                ylim([0 max(get(gca, 'ylim'))]);
                
            elseif i < j,
                
                if exist('groupvar', 'var'),
                    scatter(dat(i).mean, dat(j).mean, 3, findgroups(data.(groupvar)));
                    
                else
                    % for correlation, show scatter plot with errorbars
                    h = ploterr(dat(i).mean, ...
                        dat(j).mean, ...
                        dat(i).ci, ...
                        dat(j).ci, ...
                        'k.','hhxy',0.1);
                    
                    % layout
                    set(h(2),'Color',[0.8 0.8 0.8]);
                    set(h(3),'Color',[0.8 0.8 0.8]);
                    set(h(1), 'MarkerSize', 8, 'MarkerEdgeColor', linspecer(1), 'MarkerFaceColor', 'w');
                end
                
                if all(dat(i).ci{1} == dat(i).ci{2}),
                    axisNotSoTight;
                else
                    % find axis limits that make sense
                    % (if leaving this out, huge CIs could obscure the datapoints)
                end
                
                
                % test if there is a correlation
                [coef, pval] = corr(dat(i).mean, dat(j).mean, ...
                    'type', 'Pearson', 'rows', 'pairwise');
                pvals = [pvals pval];
                bf = corrbf(coef, sum(~isnan(dat(i).mean)));
                
                % r = refline(1); set(r, 'color', [0.5 0.5 0.5]);
                % indicate significant correlation
                if pval < critp,
                    lh = lsline; set(lh, 'color', 'k', 'linewidth', 0.5);
                end
                % title(sprintf('\\rho = %.2f p = %.3f bf = %.3f', coef, pval, bf), 'fontweight', 'normal');
                
                fz = 5;
                text(nanmin(dat(i).mean), nanmin(dat(j).mean+yslack), sprintf('r = %.3f', coef), 'fontweight', 'normal', 'fontsize', fz);
                if pval < 0.0001,
                    text(nanmin(dat(i).mean), nanmin(dat(j).mean), 'p < 0.0001', 'fontweight', 'normal', 'fontsize', fz);
                else
                    text(nanmin(dat(i).mean), nanmin(dat(j).mean), sprintf('p = %.4f', pval), 'fontweight', 'normal', 'fontsize', fz);
                end
                
                % hline(0, 'color', [0.5 0.5 0.5], 'linewidth', 0.5);
                % vline(0, 'color', [0.5 0.5 0.5], 'linewidth', 0.5);
                axis square;
                
                % plot the group stats on top
                if ~exist('groupvar', 'var'),
                    plot(dat(i).mean, dat(j).mean, '.', 'MarkerSize', 5, 'MarkerEdgeColor', linspecer(1));
                end
                
                h = ploterr(mean(dat(i).mean), mean(dat(j).mean), ...
                    std(dat(i).mean) ./ sqrt(numel(dat(i).mean)), ...
                    std(dat(j).mean) ./ sqrt(numel(dat(j).mean)), ...
                    'k.','abshhxy', 0);
                
            else
                % leave white, only plot the lower left triangle
                axis off;
            end
            
            
            % layout
            if numel(varnames1{i}) > 20,
                [xtoken,remain] = strsplit(varnames1{i}, '__');
            else
                xtoken = varnames1{i};
            end
            
            if numel(varnames1{j}) > 20,
                [ytoken,remain] = strsplit(varnames1{j}, '__');
            else
                ytoken = varnames1{j};
            end
            
            % do layout
            if j == nsubpl,     xlabel(xtoken, 'interpreter', 'none', 'fontweight', 'bold'); end
            if i == 1,          ylabel(ytoken, 'interpreter', 'none', 'fontweight', 'bold'); end
            %if j < nsubpl,      set(gca, 'xticklabel', []); end
            % if i > 1,           set(gca, 'yticklabel', []); end
            
            set(gca, 'tickdir', 'out', 'box', 'off');
            
            xlim([nanmin(dat(i).mean) - xslack, nanmax(dat(i).mean) + xslack]);
            if j ~= i,
                ylim([nanmin(dat(j).mean) - yslack, nanmax(dat(j).mean) + yslack]);
            end
            
            offsetAxes;
            if j == i,
                % axis tight;
                ylim([0 max(get(gca, 'ylim'))]);
            end
        end
    end
    
else
    
    % ============================================ %
    % CORRELATE TWO SETS OF MEASURES WITH EACH OTHER
    % ============================================ %
    
    % prepare data1
    for v = 1:length(varnames1),
        dat1(v).mean = data.(varnames1{v});
        try
            dat1(v).ci = {data.([varnames1{v} '_cilow']); data.([varnames1{v} '_cihigh'])};
        catch
            % fill with zeros so that the ploterr does not crash
            dat1(v).ci = {data.(varnames1{v}); data.(varnames1{v})};
        end
    end
    
    for v = 1:length(varnames2),
        dat2(v).mean = data.(varnames2{v});
        try
            dat2(v).ci = {data.([varnames2{v} '_cilow']); data.([varnames2{v} '_cihigh'])};
        catch
            % fill with zeros so that the ploterr does not crash
            dat2(v).ci = {data.(varnames2{v}); data.(varnames2{v})};
        end
    end
    
    cnt = 1;
    nsubpl = max([length(dat1) + 1 length(dat2) + 1]);
    
    for i = 1:length(dat1) + 1,
        for j = 1:length(dat2) + 1,
            
            subplot(nsubpl, nsubpl, i + (j-1)*nsubpl); hold on;
            
            if j > length(dat2) && i > length(dat1),
                axis off; continue;
            elseif i > length(dat1)
                % histogram(dat2(j).mean);
                
                if exist('groupvar', 'var'),
                    gr = findgroups(data.(groupvar));
                    
                    for g = 1:length(unique(gr)),
                        h = histogram(dat2(j).mean(gr == g), round(length(dat2(j).mean(gr == g))), 'orientation', 'horizontal');
                        set(h(1), 'edgecolor', 'none');
                    end
                    
                    % do stats between the groups!
                    try
                        pvalsgroup = [pvalsgroup ranksum(dat2(j).mean(gr == 1), dat2(j).mean(gr == 2))];
                        pvalsgroup = [pvalsgroup ranksum(dat2(j).mean(gr == 2), dat2(j).mean(gr == 3))];
                        pvalsgroup = [pvalsgroup ranksum(dat2(j).mean(gr == 1), dat2(j).mean(gr == 3))];
                    end
                    
                else
                    % for autocorrelation, plot histfit
                    h = histogram(dat2(j).mean, round(length(dat2(j).mean)/5) , 'orientation', 'horizontal');
                    set(h(1), 'edgecolor', 'none', 'facecolor', linspecer(1));
                end
                
                % set(h(2), 'color', 'k', 'linewidth', 0.5);
                axisNotSoTight;
                axis square;
                offsetAxes;
                hline(nanmean(dat2(j).mean), 'k');
                set(gca, 'xticklabel', [], 'xcolor', 'w');
                % vline(nanmean(dat(i).mean), 'color', 'k', 'linewidth', 1);
                xlim([0 max(get(gca, 'xlim'))]);
                
                prevhandle = subplot(nsubpl, nsubpl, -1 + i + (j-1)*nsubpl);
                currhandle = subplot(nsubpl, nsubpl, i + (j-1)*nsubpl);
                set(currhandle, 'ylim', get(prevhandle, 'ylim'), 'ytick', get(prevhandle, 'ytick'));
                
                continue;
            elseif j > length(dat2)
                if exist('groupvar', 'var'),
                    gr = findgroups(data.(groupvar));
                    
                    for g = 1:length(unique(gr)),
                        h = histogram(dat1(i).mean(gr == g), round(length(dat1(i).mean(gr == g))));
                        set(h(1), 'edgecolor', 'none');
                    end
                else
                    % for autocorrelation, plot histfit
                    h = histogram(dat1(i).mean, round(length(dat1(i).mean)/5));
                    set(h(1), 'edgecolor', 'none', 'facecolor', linspecer(1));
                end
                
                axisNotSoTight;
                axis square;
                offsetAxes;
                vline(nanmean(dat1(i).mean), 'k');
                set(gca, 'yticklabel', [], 'ycolor', 'w');
                % vline(nanmean(dat(i).mean), 'color', 'k', 'linewidth', 1);
                ylim([0 max(get(gca, 'ylim'))]);
                %
                %                 prevhandle = subplot(nsubpl, nsubpl, -1 + i + (j-1)*nsubpl);
                %                 currhandle = subplot(nsubpl, nsubpl, i + (j-1)*nsubpl);
                %                 set(currhandle, 'ylim', get(prevhandle, 'ylim'), 'ytick', get(prevhandle, 'ytick'));
                %
                
                continue;
            end
            
            if exist('groupvar', 'var'),
                scatter(dat1(i).mean, dat2(j).mean, 4, findgroups(data.(groupvar)));
            else
                % for correlation, show scatter plot with errorbars
                h = ploterr(dat1(i).mean, ...
                    dat2(j).mean, ...
                    dat1(i).ci, ...
                    dat2(j).ci, ...
                    'k.','hhxy',0.1);
                
                % layout
                set(h(2),'Color',[0.8 0.8 0.8]);
                set(h(3),'Color',[0.8 0.8 0.8]);
                set(h(1), 'MarkerSize', 8, 'MarkerEdgeColor', linspecer(1), 'MarkerFaceColor', 'w');
            end
            axisNotSoTight;
            axis square;
            
            % test if there is a correlation
            [coef, pval] = corr(dat1(i).mean(:), dat2(j).mean(:), ...
                'type', 'Pearson', 'rows', 'pairwise');
            try
            bf = corrbf(coef, sum(~isnan(dat1(i).mean)));
            pvals = [pvals pval];
            end
            
            % indicate significant correlation
            if pval < critp,
                lh = lsline; set(lh, 'color', 'k');
            end
            %title(sprintf('\\rho = %.2f, p = %.3f, bf = %.3f', coef, pval, bf), 'fontweight', 'normal');
            % title(sprintf('r = %.2f, p = %.3f', coef, pval), 'fontweight', 'normal');
            
            text(nanmin(dat1(i).mean), nanmin(dat2(j).mean+0.1 * range(dat2(j).mean)), sprintf('r = %.3f', coef), 'fontweight', 'normal', 'fontsize', 5);
            if pval < 0.0001,
                text(nanmin(dat1(i).mean), nanmin(dat2(j).mean), 'p < 0.0001', 'fontweight', 'normal', 'fontsize', 5);
            else
                text(nanmin(dat1(i).mean), nanmin(dat2(j).mean), sprintf('p = %.4f', pval), 'fontweight', 'normal', 'fontsize', 5);
            end
            
            % show the group mean on top
            ploterr(mean(dat1(i).mean), mean(dat2(j).mean), ...
                std(dat1(i).mean) ./ sqrt(numel(dat1(i).mean)), ...
                std(dat2(j).mean) ./ sqrt(numel(dat2(j).mean)), ...
                'k.','abshhxy', 0);
            
            % if all(dat1(i).ci{1} == dat1(i).ci{2}),
            % r = refline(1); set(r, 'color', [0.5 0.5 0.5]);
            % grid on;
            
            % layout
            if j == length(dat2),       xlabel(varnames1{i}, 'interpreter', 'none'); end
            if i == 1,                  ylabel(varnames2{j}, 'interpreter', 'none'); end
            if j < length(dat2),        set(gca, 'xticklabel', []); end
            if i > 1,                   set(gca, 'yticklabel', []); end
            set(gca, 'tickdir', 'out', 'box', 'off');
            offsetAxes;
        end
    end
end

end
