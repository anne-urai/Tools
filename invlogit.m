
function out = invlogit(x)
% inverse logit
out = 1 ./ (1 + exp(-x));

end
