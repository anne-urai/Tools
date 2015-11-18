function h = mysigstar(xpos, ypos, pval)
% replaces sigstar, which doesnt work anymore in matlab 2014b

% draw line
hold on;
p = plot([xpos(1), xpos(1), xpos(2), xpos(2)], ...
    [ypos(2) ypos(1) ypos(1) ypos(2)],'-k','LineWidth',0.5);

 if pval < 1e-3
        txt = '***';
    elseif pval < 1e-2
       txt = '**';
    elseif pval < 0.05
        txt = '*';
    else
        txt = 'n.s.';
 end
    
 % draw the stars in the bar
h = text(mean(xpos), mean(ypos),txt,'backgroundcolor','w','horizontalalignment','center');

end