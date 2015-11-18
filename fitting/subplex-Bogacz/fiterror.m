function [error, devs, s, STEP, DELAY] = fiterror (param, model, startpar, g, typestat, d, iter, statweight, parange)

% This function calculates the cost function.

penalty = 0;
if nargin >= 9 & ~isempty (parange)
 difmin = param .* startpar - parange(:,1)';
 penalty = sum (abs(difmin)-difmin);
 difmax = parange(:,2)' - param .* startpar;
 penalty = penalty + sum (abs(difmax)-difmax);
end

if penalty > 0
 error = penalty * 100000 + 10000000;
else

if nargin < 7
 iter = 1;
end

EALL = find (typestat == 1);
TALL = find (typestat == 2);
DALL = find (typestat == 3);
ALL = [EALL TALL DALL];

goalen = length (g);
s = zeros (iter, goalen);

for i = 1:iter
 s (i,:) = feval (model, param .* startpar);
 [si, STEP, DELAY] = conveRT (s (i,:), g, typestat);
 s (i,:) = si;
end

devs = std(s,1);
s = mean(s,1);
 
% calculating the error
if (nargin < 6 | size(d,2) ~= goalen) & iter >= 10		%for iter >= 10 use just estimated standard deviations
 d = devs;
end
if nargin < 6 | size(d,2) ~= goalen
 error = sum ((g(EALL) - s(EALL)).^2 / mymean(g(EALL),1)^2 .* statweight(EALL)) + ...
	 sum ((g(TALL) - s(TALL)).^2 / mymean(g(TALL),1)^2 .* statweight(TALL)) + ...
	 sum ((g(DALL) - s(DALL)).^2 / mymean(g(DALL),1)^2 .* statweight(DALL));
else
 if ~isempty(EALL)
  d(EALL(find(d(EALL)==0))) = mymean (d(EALL(find(d(EALL)>0))));	%replacing d==0 by the mean of category
 end
 if ~isempty(TALL)
  d(TALL(find(d(TALL)==0))) = mymean (d(TALL(find(d(TALL)>0))));
 end
 if ~isempty(DALL)
  d(DALL(find(d(DALL)==0))) = mymean (d(DALL(find(d(DALL)>0))));
 end
 error = sum (((g(ALL) - s(ALL)) ./ d(ALL)) .^ 2 .* statweight(ALL));
end;
end

%disp (sprintf('Fit error = %f', error));
