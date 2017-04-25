n=250;
eg1=exgausrnd(200,20,100,1,n);
nr=normrnd(300,20,1,n);
er=exprnd(300,1,n);
al=[eg1; nr ;er]';
mean(al)
fh=figure(1)
set(fh,'Units','inches','PaperUnits','inches');
orient landscape
set(fh,'position',[0.25 0.25 8 3]);
set(fh,'paperposition',[0.25 0.25 8 3]);

clf
subplot(1,3,1)
br=hist(eg1);
hist(eg1)
% fb=bar(br)
% xlim([0,11])
% set(fb,'BarWidth', 1,'FaceColor', 'w');
% 
subplot(1,3,2)
hist(nr)
% br=hist(nr);
% fb=bar(br)
% xlim([0,11])
% set(fb,'BarWidth', 1,'FaceColor', 'w')
% 
subplot(1,3,3)
hist(er)
% br=hist(er);
% fb=bar(br)
% xlim([0,11])
% set(fb,'BarWidth', 1,'FaceColor', 'w')

fh=figure(2)
set(fh,'Units','inches','PaperUnits','inches');
orient landscape
set(fh,'position',[0.25 0.25 8 3]);
set(fh,'paperposition',[0.25 0.25 8 3]);

clf
subplot(1,3,3)
br=hist(eg1);
% hist(eg1)
fb=bar(br)
xlim([0 11])
set(fb,'BarWidth', 1,'FaceColor', 'w');
set(gca,'XTick',[0  11])
set(gca,'XTickLabel',['0   ' ; '1000'])
title('C');

subplot(1,3,2)
% hist(nr)
br=hist(nr);
fb=bar(br)
xlim([0,11])
set(fb,'BarWidth', 1,'FaceColor', 'w')
set(fb,'BarWidth', 1,'FaceColor', 'w');
set(gca,'XTick',[0  11])
set(gca,'XTickLabel',['250' ; '350'])
title('B');


subplot(1,3,1)
% hist(er)
br=hist(er);
fb=bar(br)
xlim([0,11])
set(fb,'BarWidth', 1,'FaceColor', 'w')
set(fb,'BarWidth', 1,'FaceColor', 'w');
set(gca,'XTick',[0  11])
set(gca,'XTickLabel',['0   ' ; '1500'])
title('A');
