function A = convnfft_light(A,B)
% light version of
% http://nl.mathworks.com/matlabcentral/fileexchange/24504-fft-based-convolution
% behaviour: size 'same'

% save memory
A = single(A);
B = single(B);

% eliminate loop
m = size(A);
n = size(B);

% IFUN function will be used later to truncate the result
% M and N are respectively the length of A and B in some dimension
% in this case, use 'same'
ifun = @(m,n) (1:m) + ceil((n-1)/2);

% subset of datapoints for same size
subs = arrayfun(ifun, size(A), size(B), 'uniformoutput', 0);

% compute the FFT length
l = m+n-1;

% find the next fast size for the fft that will be fast, but not that much bigger
% http://www.univie.ac.at/nuhag-php/mmodule/m-files/nextfastfft.m
l2 = nextfastfft(l);

% fftn in 1 step
A = convMe(A,B, l2);

% truncate the results
A = A(subs{:});

end % convnfft

function A = convMe(A, B, l)
% will this use inplace mem?
A = ifftn(fftn(A, l) .* fftn(B, l));
end
