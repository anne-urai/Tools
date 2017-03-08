function handles = prettyColorbar(titleStr)

% ==================================================================
% make colorbar look pretty
% ==================================================================
drawnow;

handles = findall(gcf,'Type','colorbar');
for h = 1:length(handles),
    handles(h).TickDirection = 'out';
    handles(h).Box = 'off';
    if exist('titleStr', 'var'),
        handles(h).Label.String = titleStr;
    end
    handles(h).Ticks = [-max(abs(handles(h).Limits)) 0 max(abs(handles(h).Limits))];
end
drawnow;

% get original axes
hAllAxes = findobj(gcf,'type','axes'); axpos = {};
for h = 1:length(hAllAxes), axpos{h} = hAllAxes(h).Position; end

% make colorbar thinner
for h = 1:length(handles),
    cpos = handles(h).Position;
    cpos(3) = 0.5*cpos(3);
    handles(h).Position = cpos;
end
drawnow;

% restore axis pos
for h = 1:length(hAllAxes), set(hAllAxes(h), 'Position', axpos{h}); end
drawnow;
end