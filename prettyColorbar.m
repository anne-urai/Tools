function handles = prettyColorbar(titleStr, thinning)
if ~exist('thinning', 'var'), thinning = 0.5; end

% ==================================================================
% make colorbar look pretty
% ==================================================================
drawnow;

handles = findall(gcf,'Type','colorbar');
for h = 1:length(handles),
    handles(h).TickDirection = 'out';
    handles(h).Box = 'off';
    % handles(h).LineWidth = 0;
    lims = roundn(max(abs(handles(h).Limits)), -2);
    handles(h).Ticks = [-lims 0 lims];
    handles(h).Limits = [-lims lims];
end
drawnow;

% get original axes
hAllAxes = findobj(gcf,'type','axes'); axpos = {};
for h = 1:length(hAllAxes), axpos{h} = hAllAxes(h).Position; end

% make colorbar thinner
for h = 1:length(handles),
    cpos = handles(h).Position;
    cpos(3) = thinning*cpos(3);
    handles(h).Position = cpos;
    
    if exist('titleStr', 'var'),
        handles(h).Label.String = titleStr;
      %  handles(h).Label.Position(1) = handles(h).Label.Position(1) - 0.3;
    end
end
drawnow;

% restore axis pos
for h = 1:length(hAllAxes), set(hAllAxes(h), 'Position', axpos{h}); end
drawnow;

% move 
end