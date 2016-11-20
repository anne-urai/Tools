function out = nancumsum(in, dim)

nanidx = find(isnan(in));
in(nanidx) = 0;
out = cumsum(in, dim);
out(nanidx) = nan;

end