function axisEqual

% axisNotSoTight;
xlims = get(gca, 'xlim');
ylims = get(gca, 'ylim');
newlim(1) = min([xlims(1) ylims(1)]);
newlim(2) = max([xlims(2) ylims(2)]);

% set the two axes to be the same
xlim(newlim); ylim(newlim);
set(gca, 'xtick', get(gca, 'ytick'));
end