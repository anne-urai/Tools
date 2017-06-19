function vout = rescale(vin, newmin, newmax)
% normalizes any vector between two values

a = min(vin);
b = max(vin);

c = newmin;
d = newmax;

vout = ((c+d) + (d-c)*((2*vin - (a+b))/(b-a)))/2;

end