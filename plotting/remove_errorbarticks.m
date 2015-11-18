function [] = remove_errorbarticks()

% remove errorbar ticks
xlims = get(gca, 'xlim'); ylims = get(gca, 'ylim');
hold on;
plot(xlim*100000, ylim*10000); % fool matlab into thinking we have much more data, which will automatically resize the errorbars
xlim(xlims); ylim(ylims); hold off;

end