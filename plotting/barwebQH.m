function [hb,he]=barwebQH(barvalues, errors, bw_legend, width, bw_colormap, pval)
%
% [hb,he]=barweb(barvalues, errors, bw_colormap, bw_legend, width )
%
% barweb is the m-by-n matrix of barvalues to be plotted.  barweb calls the
% MATLAB bar function and plots m groups of n bars using the width and
% bw_colormap parameters.  If you want all the bars to be the same color,
% then set bw_colormap equal to the RBG matrix value ie. (bw_colormap = [1
% 0 0] for all red bars) barweb then calls the MATLAB errorbar function to
% draw barvalues with error bars of length error.  The errors matrix is of
% the same form of the barvalues matrix, namely m group of n errors.  No
% legend will be shown if the legend paramter is not provided
%
% See the MATLAB functions bar and errorbar for more information
%
% [hb,he]=barweb(...) will give handle HB to the bars and HE to the errorbars.
%
% Author: Bolu Ajiboye
% Created: October 18, 2005 (ver 1.0)
% Updated: April 22, 2006 (ver 2.0)
%
% Modified by Quentin Huys November 2006
% Modified by Anne Urai 2015, addition of p-values and use of sigstar

% Get function arguments
if nargin < 2
    error('Must have at least the first two arguments:  barweb(barvalues, errors, width, groupnames, bw_title, bw_xlabel, bw_ylabel, bw_colormap, gridstatus, bw_legend)');
elseif nargin == 2
    width = .8;
    bw_legend=[];
    bw_colormap = [];
elseif nargin == 3
    width = 1;
    bw_colormap = [];
elseif nargin == 4
    bw_colormap = [];
end

change_axis = 0;

if size(barvalues,1) ~= size(errors,1) || size(barvalues,2) ~= size(errors,2)
    error('barvalues and errors matrix must be of same dimension');
else
    if size(barvalues,2) == 1
        barvalues = barvalues';
        errors = errors';
        pval = pval';
    end
    if size(barvalues,1) == 1
        barvalues = [barvalues; zeros(1,length(barvalues))];
        errors = [errors; zeros(1,length(barvalues))];
        change_axis = 1;
    end
    numgroups = size(barvalues, 1); % number of groups
    numbars = size(barvalues, 2); % number of bars in a group
    if isempty(width)
        width = 1;
    end
    
    % Plot bars and errors
    hb=bar(barvalues, width, 'edgecolor', 'none');
    shading flat; %turns off the edges
    hold on;
    
    if length(bw_colormap)
        colormap(bw_colormap);
    else
    end
    groupwidth = min(0.8, numbars/(numbars+1.5));
    he=[];
    
    for i = 1:numbars
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);
        th=errorbar(x, barvalues(:,i), errors(:,i), 'k', 'linestyle', 'none');
        set(th, 'LineWidth', 1.4);
        he=[he;th];
        for ii = 1:length(x),
            if barvalues(ii, i) > 0,
                thisY = barvalues(ii, i) + errors(ii, i)+ 0.2*range(get(gca, 'ylim'));
            else
                thisY = barvalues(ii, i) - errors(ii, i)- 0.2*range(get(gca, 'ylim'));
            end
            try
                mysigstar(x(ii), thisY, pval(ii, i));
            catch
                mysigstar(x(ii), thisY, pval(i, ii));
            end
        end
    end
    
    xlim([0.5 numgroups-change_axis+0.5]);
    
    if ~isempty(bw_legend)
        legend(bw_legend);%, 'location', 'best');%, 'fontsize',12);
        legend boxoff;
    end
    hold off;
end

return
