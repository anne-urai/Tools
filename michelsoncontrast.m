function out = michelsoncontrast(inp1, inp2)
% contrast
out = (inp1 - inp2) ./ (inp1 + inp2);
end