function h = mysigstar(xpos, ypos, pval)
% replaces sigstar, which doesnt work anymore in matlab 2014b

if numel(ypos) > 1,
    assert(ypos(1) == ypos(2), 'line wont be straight!');
    ypos = ypos(1);
end

% draw line
hold on;
if numel(xpos) > 1,
    % plot the horizontal line
    newY = ypos+0.01*range(get(gca, 'ylim'));
    p = plot([xpos(1), xpos(2)], ...
        [newY newY], '-k', 'LineWidth',0.1);
    
    % also add small downward ticks
    plot([xpos(1) xpos(1)], [newY newY-0.05*range(get(gca, 'ylim'))], '-k', 'LineWidth', 0.1);
    plot([xpos(2) xpos(2)], [newY newY-0.05*range(get(gca, 'ylim'))], '-k', 'LineWidth', 0.1);
end

fz = 8;
if pval < 1e-3
    txt = '***';
elseif pval < 1e-2
    txt = '**';
elseif pval < 0.05
    txt = '*';
else
    % this should be smaller
    txt = 'n.s.';
    fz = 5;
end

% draw the stars in the bar
h = text(mean(xpos), mean(ypos), txt, 'horizontalalignment', 'center', 'backgroundcolor', 'w', 'margin', 1, 'fontsize', fz);

end