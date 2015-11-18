function [ ] = corrplot_imagesc( data, varnames1, varnames2 )
% mimics the corrplot function from the econometrics toolbox, which I sadly
% do not have. data has to be a table, and varnames the names of the variables
% that should be correlated. if present, will use varname_cilow and varname_cihigh
% to plot confidence intervals around each datapoint.
%
% if 1 cell array of variable names is given, all will be correlated to all
% if 2 cell arrays are given, they will be correlated against each other
% input bounds, not distance from x/y!
%
% Anne Urai, 1 april 2015

figure; set(gcf, 'DefaultAxesFontSize', 7);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORRELATE ALL MEASURES WITH EACH OTHER
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

                % test if there is a correlation
                [coef, pval] = corr(dat(i).mean, dat(j).mean, 'type', 'Spearman', 'rows', 'pairwise');
                corrdata(i, j) = coef;
            
        end
    end
    
    colormap linspecer;
    h = imagesc(corrdata, [-1 1]);
    set(gca, 'YDir', 'normal');
    axis tight;
    set(gca, 'XTickLabel', varnames1, 'YTickLabel', varnames1, 'TickDir', 'out');
    cb = colorbar; cb.Label.String = 'Spearman''s rho';
    
else
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CORRELATE TWO SETS OF MEASURES WITH EACH OTHER
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
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

    corrdata = nan(length(dat1), length(dat2));
    
    for i = 1:length(dat1),
        for j = 1:length(dat2),
             
            % test if there is a correlation
            [coef, pval] = corr(dat1(i).mean, dat2(j).mean, 'type', 'Spearman', 'rows', 'pairwise');
            corrdata(i, j) = coef;

        end
    end
    
    colormap linspecer;
    h = imagesc(corrdata, [-1 1]);
    set(gca, 'YDir', 'normal');
    axis tight;
    set(gca, 'XTick', 1:length(varnames2),  'XTickLabel', varnames2, ...
        'YTick', 1:length(varnames1), 'YTickLabel', varnames1, 'TickDir', 'out');
    cb = colorbar; cb.Label.String = 'Spearman''s rho';
    
end

end
