function [outp] = quantize(inp, nbins)
% http://matlabdatamining.blogspot.nl/2007/02/dividing-values-into-equal-sized-groups.html

outp = ceil(nbins * tiedrank(inp) / length(inp));
end