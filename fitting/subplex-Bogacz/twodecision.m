function stat = twodecision (parameter)

if length(parameter) ~= 3
 disp ('The parameter of the function should be a vector of length 3');
 return;
end;

% parameters of the model
a = parameter(1);	% connection between input and correct output
b = parameter(2);	% connection between input and incorrect output
c = parameter(3);	% magnitude of noise
disp (sprintf ('Parameters: a=%f b=%f c=%f', a, b, c));

% parameters of the optimisation process
ITER = 1000;	% number of iterations

% measures of model behaviour
correct = zeros(1,ITER);	% =1 if trial correct; =0 for incorrect
RT = zeros(1,ITER);			% reaction times

% main simulation loop
for i=1:ITER
 time = 0;
 y1 = 0;    %activation of the correct mode
 y2 = 0;    %activation of the incorrect mode
 while y1<1 & y2<1
  y1 = y1 + a + c * (rand(1) - 0.5);
  y2 = y2 + b + c * (rand(1) - 0.5);
  time = time + 1;
 end;
 RT(i) = time;
 correct (i) = (y2 < y1);
end;

% statistics
stat = zeros (1, 5);
stat(1) = 1 - mean (correct);			% error rate
if stat(1) ~= 1
 stat(2) = mean (RT(find(correct)));	% mean reaction time for correct
 stat(3) = std (RT(find(correct)));		% standard deviation of reaction times for correct
end
if stat(1) ~= 0
 stat(4) = mean (RT(find(~correct)));	% mean reaction time for incorrect
 stat(5) = std (RT(find(~correct)));	% standard deviation of reaction times for incorrect
end
disp (sprintf ('Statistics: ER=%f RTc=%f SDc=%f RTi=%f SDi=%f', stat(1), stat(2), stat(3), stat(4), stat(5)));
