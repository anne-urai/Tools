function idx = quadrant(inp, whichQuadrant)
% extract one quadrant of a square matrix

% % test
% qs = {'top', 'bottom', 'left', 'right'};
% for q = 1:length(qs),
%     subplot(2,2,q); surf(quadrant(randn(100, 100), qs{q})); axis square;
%     title(qs{q});
% end

if ~exist('inp', 'var'); inp = randn(100, 100); end
if ~exist('whichQuadrant', 'var'); whichQuadrant = 'north'; end

% make axes
x = linspace(-1, 1, size(inp, 1));
y = linspace(-1, 1, size(inp, 2));

% make a grid
[xgr, ygr] = meshgrid(x,y);

% select one quadrant
switch whichQuadrant
    case 'north'
        idx = (xgr < ygr) & (abs(xgr) < abs(ygr));
    case 'east'
        idx = (xgr > ygr) & (abs(xgr) > abs(ygr));
    case 'south'
        idx = (xgr > ygr) & (abs(xgr) < abs(ygr));
    case 'west'
        idx = (xgr < ygr) & (abs(xgr) > abs(ygr));
end

% now output the original matrix with only this quadrant *not* set to zero
outp = inp;
outp((idx == 0)) = 0; % use idx as a mask
assert(all(size(outp) == size(inp)), 'something went horribly wrong');

end


