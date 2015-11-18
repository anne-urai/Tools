function data = getdata (filename)

% function data = getdata (filename);
%
% load file with behavioral data from Eriksen task
% into matrix.
% Expects a file that has 7 cols:
% 1: subject num, 2: block num, 3: trial num, 
% 4: stimulus, 5: accuracy, 6: RT, 7: compatibility
%
% outputs a matrix with same cols, but col 5 is error

eval(['data = load (''' filename ''');']);
data(:,5) = abs(1-data(:,5));