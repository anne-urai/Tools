function [sorted, idx] = orderByDate(files)
% return a list of file by the time of their creation, useful when
% appending datafiles 

dates = cat(1, files(:).datenum);
[~, idx] = sort(dates);
sorted = files(idx);

end