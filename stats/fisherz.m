function z = fisherz(r)
% transforms correlation coefficients to normally distributed z scores

z = 0.5* (log(1+r) - log(1-r));

end
