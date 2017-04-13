function h = mysigstar(ax, xpos, ypos, pval, color, whichWay)
% replaces sigstar, which doesnt work anymore in matlab 2014b

if ~exist('ax', 'var'); ax = gca; end
if ~exist('color', 'var'); color = 'k'; end
if ~exist('whichWay', 'var'), whichWay = 'down'; end

if numel(ypos) > 1,
    assert(ypos(1) == ypos(2), 'line wont be straight!');
    ypos = ypos(1);
end

% draw line
hold on;
if numel(xpos) > 1,
    % plot the horizontal line
    p = plot(ax, [xpos(1), xpos(2)], ...
        [ypos ypos], '-', 'LineWidth', 0.5, 'color', color);
    
    %     % also add small downward ticks
    %     switch whichWay
    %         case 'down'
    %             plot([xpos(1) xpos(1)], [newY newY-0.05*range(get(gca, 'ylim'))], '-k', 'LineWidth', 0.5, 'color', color);
    %             plot([xpos(2) xpos(2)], [newY newY-0.05*range(get(gca, 'ylim'))], '-k', 'LineWidth', 0.5, 'color', color);
    %         case 'up'
    %             plot([xpos(1) xpos(1)], [newY newY+0.05*range(get(gca, 'ylim'))], '-k', 'LineWidth', 0.5, 'color', color);
    %             plot([xpos(2) xpos(2)], [newY newY+0.05*range(get(gca, 'ylim'))], '-k', 'LineWidth', 0.5, 'color', color);
    %     end
    
    % use white background
    txtBg = 'w';
else
    txtBg = 'none';
end

fz = 8; fontweight = 'bold';
if pval < 1e-3
    txt = '***';
elseif pval < 1e-2
    txt = '**';
elseif pval < 0.05
    txt = '*';
elseif ~isnan(pval),
    % this should be smaller
    txt = 'n.s.';
    %txt = '';
    fz = 6; fontweight = 'normal';
else
    return
end

% draw the stars in the bar
h = text(mean(xpos), mean(ypos), txt, ...
    'horizontalalignment', 'center', 'backgroundcolor', ...
    txtBg, 'margin', 1, 'fontsize', fz, 'fontweight', fontweight, 'color', color, 'Parent', ax);
end
