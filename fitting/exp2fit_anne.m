function [params] = exp2fit_anne(x, y)
% estimates the starting points for exponential fit of the shape:
% a + b * (1-exp(-x/tau))

a = min(y);
b = max(y);

ytmp = 1 - (y - a) ./ b;

[estparams] = exp2fit(x, ytmp, 1);

tau = estparams(3);

params = [a*estparams(1) b*estparams(2) tau];

end