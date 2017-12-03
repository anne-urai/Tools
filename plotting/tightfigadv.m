function hfig = tightfigadv(hfig)
% tightfigadv (Tight Figure Advanced): Alters a figure so that it has the
% minimum size necessary to enclose all axes in the figure without excess
% space around them.
%
% tightfigadv is inspired ny tightfig and contains improvements and bug
% fixes for HG2, colorbars, legends and manually positioned labels.
%
% Note that tightfigadv will expand the figure to completely encompass all
% axes if necessary. If any 3D axes are present which have been zoomed,
% tightfigadv will produce an error, as these cannot easily be dealt with.
%
% hfig - handle to figure, if not supplied, the current figure will be used
% instead.

% The following code is an extension of tightfig
% Copyright (c) 2011, Richard Crozier (BSD 2-clause license)
% See: https://au.mathworks.com/matlabcentral/fileexchange/34055-tightfig

% Modifications by: Jacob Donley
% University of Wollongong
% Email: jrd089@uowmail.edu.au
% Date: 09 November 2017
% Version: 0.1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    hfig = gcf;
end

% There can be an issue with tightfigadv when the user has been modifying
% the contnts manually, the code below is an attempt to resolve this,
% but it has not yet been satisfactorily fixed
set(hfig, 'WindowStyle', 'normal');

% 1 point is 0.3528 mm for future use

% get all the axes handles note this will also fetch legends and
% colorbars as well
hax = findall(hfig, 'type', 'axes');
% Concatenate HG2 objects into hax as graphics array and sort
hax = [hax; findall(hfig, 'type', 'legend')];

% get all the text handles so we can determine the tightinset manually
% because manual placement of labels and text removes them from
% tightinset calculations.
htx = findall(hfig, 'type', 'text');
hcb = findall(hfig, 'type', 'colorbar');
if ~isempty(hcb)
    htx = [htx; [hcb.Label]'];
end
htx(contains({htx.Visible}, 'off')) = [];

% get the original units, so we can change and reset these again
% later
origaxunits = get(hax, 'Units');
origtxunits = get(htx, 'Units');

% change the units to cm
set(hax, 'Units', 'centimeters');
set(htx, 'Units', 'centimeters');

% get various position parameters of the axes
hax_ti_ind = arrayfun(@(x) (isa(x,'matlab.graphics.axis.Axes')),...
    hax,'UniformOutput',false);
hax_ti=hax([hax_ti_ind{:}]); % Returns only Axes handles
if numel(hax) > 1
    pos = cell2mat(get(hax, 'Position'));
    ti_ = get(hax_ti,'TightInset');
    if iscell(ti_)
        ti_ = cell2mat(ti_);
    end
    ti = [ti_; ...
        zeros(size(pos)-[sum([hax_ti_ind{:}]) 0])];
else
    pos = get(hax, 'Position');
    ti = get(hax_ti,'TightInset');
end

% get the global extents of the text objects
if numel(htx) > 1
    ext = cell2mat(get(htx, 'Extent'));
    extPar = get(htx, 'Parent');
    extParPos = cell2mat(get([extPar{:}],'Position'));
    ext(:,1:2) = ext(:,1:2) + extParPos(:,1:2);
else
    ext = get(htx, 'Extent');
    extPar = get(htx, 'Parent');
    ext(1:2) = ext(1:2) + extPar.Position(1:2);
end

% ensure very tiny border so outer box always appears
ti(ti < 0.1) = 0.15;

% we will check if any 3d axes are zoomed, to do this we will check if
% they are not being viewed in any of the 2d directions
views2d = [0,90; 0,0; 90,0];

for i = 1:numel(hax_ti)
    set(hax(i), 'LooseInset', ti(i,:));
    % get the current viewing angle of the axes
    [az,el] = view(hax(i));
    % determine if the axes are zoomed
    iszoomed = strcmp(get(hax(i), 'CameraViewAngleMode'), 'manual');
    % test if we are viewing in 2d mode or a 3d view
    is2d = all(bsxfun(@eq, [az,el], views2d), 2);
    
    if iszoomed && ~any(is2d)
        error('TIGHTFIGADV:haszoomed3d', 'Cannot make figures containing zoomed 3D axes tight.')
    end
end

% we will move all the axes down and to the left by the amount
% necessary to just show the bottom and leftmost axes and labels etc.
moveleft = min( min(pos(:,1) - ti(:,1)), min(ext(:,1)) );

movedown = min(min(pos(:,2) - ti(:,2)), min(ext(:,2)));

% we will also alter the height and width of the figure to just
% encompass the topmost and rightmost axes and lables
figwidth = max(max(pos(:,1) + pos(:,3) + ti(:,3)), max(sum(ext(:,[1 3]),2))) - moveleft;

figheight = max(max(pos(:,2) + pos(:,4) + ti(:,4)), max(sum(ext(:,[2 4]),2))) - movedown;

% Resets temporary changes made to colorbar pos
if numel(hax) > 1
    pos = cell2mat(get(hax, 'Position'));
else
    pos = get(hax, 'Position');
end

% move all the axes
for i = 1:numel(hax)
    set(hax(i), 'Position', [pos(i,1:2) - [moveleft,movedown], pos(i,3:4)]);
end

origfigunits = get(hfig, 'Units');

set(hfig, 'Units', 'centimeters');

% change the size of the figure
figpos = get(hfig, 'Position');

set(hfig, 'Position', [figpos(1), figpos(2), figwidth, figheight]);

% change the size of the paper
set(hfig, 'PaperUnits','centimeters');
set(hfig, 'PaperSize', [figwidth, figheight]);
set(hfig, 'PaperPositionMode', 'manual');
set(hfig, 'PaperPosition',[0 0 figwidth figheight]);

% reset to original units for axes and figure
if ~iscell(origaxunits)
    origaxunits = {origaxunits};
end
if ~iscell(origtxunits)
    origtxunits = {origtxunits};
end

for i = 1:numel(hax)
    set(hax(i), 'Units', origaxunits{i});
end
for i = 1:numel(htx)
    set(htx(i), 'Units', origtxunits{i});
end

set(hfig, 'Units', origfigunits);

end