function varargout=sigstar_vertical(xpos, p)
% Adds a vertical significance bar at xpos
% Anne Urai, 2015

hold on

% determine the y positions for this xpos

h = findobj(gca,'Type','line');
x=get(h,'Xdata');
y=get(h,'Ydata');

ymin = min([y{1}(floor(xpos)) y{2}(floor(xpos))]);
ymax = max([y{1}(floor(xpos)) y{2}(floor(xpos))]);
clear y;
y(1) = ymin; y(2) = ymax;

% plot a vertical line
H(1) = plot(repmat(xpos, 1, 2),y,'-k','LineWidth',0.5);

% which stars will we display?
if p<=1E-3
    stars='***';
elseif p<=1E-2
    stars='**';
elseif p<=0.05
    stars='*';
elseif isnan(p)
    stars='n.s.';
elseif p > 0.05
    stars='n.s.';
end

%Increase offset between line and text if we will print "n.s."
%instead of a star.
if isnan(p) || p > 0.05,
    offset=0.3;
else
    offset=0.1;
end

if p <=0.05,
    H(2)=text(xpos+offset,mean(y),stars,...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none', 'rotation', 270);
else % plot the stars in a smaller font
    H(2)=text(xpos+offset,mean(y),stars,...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none', 'fontsize', 5, 'rotation',270);
end

