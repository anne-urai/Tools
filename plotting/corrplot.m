function [ ] = corrplot( data, varnames1, varnames2 )
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

% ============================================ %
% CORRELATE ALL MEASURES WITH EACH OTHER
% ============================================ %

close all;

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
            
            subplot(nsubpl, nsubpl, i + (j-1)*nsubpl)
            
            if i == j,
                % for autocorrelation, plot histfit
                h = histfit(dat(i).mean, round(length(dat(i).mean)/3));
                set(h(1), 'edgecolor', 'none', 'facecolor', 'b');
                set(h(2), 'color', 'k');
                axis square;
                
            elseif i < j,
                
                % for correlation, show scatter plot with errorbars
                h = ploterr(dat(i).mean, ...
                    dat(j).mean, ...
                    dat(i).ci, ...
                    dat(j).ci, ...
                    'ko','hhxy',0.1);
                
                % layout
                set(h(2),'Color',[0.8 0.8 0.8]);
                set(h(3),'Color',[0.8 0.8 0.8]);
                set(h(1), 'MarkerSize', 3, 'MarkerEdgeColor', linspecer(1), 'MarkerFaceColor', 'w');
                
                if all(dat(i).ci{1} == dat(i).ci{2}),
                    axisNotSoTight; 
                else
                    % find axis limits that make sense
                    % (if leaving this out, huge CIs could obscure the datapoints)
                    xlim([nanmin(dat(i).mean) - abs(nanmean(dat(i).mean)*0.5), nanmax(dat(i).mean) + abs(nanmean(dat(i).mean)*0.5)]);
                    ylim([nanmin(dat(j).mean) - abs(nanmean(dat(j).mean)*0.5), nanmax(dat(j).mean) + abs(nanmean(dat(j).mean)*0.5)]);
                end
                
                % test if there is a correlation
                [coef, pval] = corr(dat(i).mean, dat(j).mean, ...
                    'type', 'Spearman', 'rows', 'pairwise');
                % r = refline(1); set(r, 'color', [0.5 0.5 0.5]);
                % indicate significant correlation
                if pval < (0.05 / (nsubpl/2)) && abs(coef) > 0.5,
                    lh = lsline; set(lh, 'color', 'k');
                    title(sprintf('rho %.2f, p %.3f', coef, pval));
                end
                axis square;
            else
                
                % leave white, only plot the lower left triangle
                axis off;
            end
            
            % layout
            if j == nsubpl,     xlabel(varnames1{i}, 'interpreter', 'none'); end
            if i == 1,          ylabel(varnames1{j}, 'interpreter', 'none'); end
            if j < nsubpl,      set(gca, 'xticklabel', []); end
            if i > 1,           set(gca, 'yticklabel', []); end
            
            set(gca, 'tickdir', 'out', 'box', 'off');
            
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
    nsubpl = max([length(dat1) length(dat2)]);
    
    for i = 1:length(dat1),
        for j = 1:length(dat2),
            
            subplot(nsubpl, nsubpl, i + (j-1)*nsubpl)
            
            % for correlation, show scatter plot with errorbars
            h = ploterr(dat1(i).mean, ...
                dat2(j).mean, ...
                dat1(i).ci, ...
                dat2(j).ci, ...
                'ko','hhxy',0.1);
            
            % layout
            set(h(2),'Color',[0.8 0.8 0.8]);
            set(h(3),'Color',[0.8 0.8 0.8]);
            set(h(1), 'MarkerSize', 3, 'MarkerEdgeColor', linspecer(1), 'MarkerFaceColor', 'w');
            
            % test if there is a correlation
            [coef, pval] = corr(dat1(i).mean(:), dat2(j).mean(:), 'type', 'Spearman', 'rows', 'pairwise');
            % indicate significant correlation
            if pval < 0.01,
                lh = lsline; set(lh, 'color', 'k');
            end
            title(sprintf('r %.2f, p %.3f', coef, pval));
            
            % if all(dat1(i).ci{1} == dat1(i).ci{2}),
            axisNotSoTight; axis square;
            % r = refline(1); set(r, 'color', [0.5 0.5 0.5]);
            grid on;
            
            % layout
            if j == length(dat2),       xlabel(varnames1{i}, 'interpreter', 'none'); end
            if i == 1,                  ylabel(varnames2{j}, 'interpreter', 'none'); end
            if j < length(dat2),        set(gca, 'xticklabel', []); end
            if i > 1,                   set(gca, 'yticklabel', []); end
            set(gca, 'tickdir', 'out', 'box', 'off');
            
        end
    end
end

end
