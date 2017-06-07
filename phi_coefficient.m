function phi = phi_coefficient(x,y)
% phi coefficient is the correlation between two binary variables.

try
    table = crosstab(x,y);
    
    n11 = table(1,1);
    n10 = table(1,2);
    n01 = table(2,1);
    n00 = table(2,2);
    n1t = n11 + n10;
    n0t = n01 + n00;
    nt1 = n11 + n01;
    nt0 = n10 + n00;
    
    phi = (n11*n00 - n10*n01) ./ sqrt(n1t*n0t*nt0*nt1);
catch
    phi = NaN;
end

% see also
% https://github.com/sbitzer/Matlab-helpers/blob/master/matthewscorr.m

end