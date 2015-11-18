function y = mymean (x, nozero)

% function y = mymean (x {,nozero})
% Works like standard Matlab function "mean",
% but when x is empty, it returns 1
% When the option nonzero = 1, then also if mean is 0, 
% the function returns 1 (but default nozero = 0)

if nargin == 1
 nozero = 0;
end

if isempty (x)
 y = 1;
else
 y = mean (x);
 if y==0 & nozero
  y = 1;
 end
end
