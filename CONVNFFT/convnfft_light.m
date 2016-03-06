function A = convnfft_light(A,B)
% light version of
% http://nl.mathworks.com/matlabcentral/fileexchange/24504-fft-based-convolution

% AEU: eliminate loop
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

% find the next fast size for the fft will be faster!
% http://www.univie.ac.at/nuhag-php/mmodule/m-files/nextfastfft.m
l2 = nextfastfft(l);

% fftn is faster than looping
A = fftn(A, l2);
B = fftn(B, l2);

% multiply in frequency domain
A = A.*B;
clear B

% back to time domain
A = ifftn(A);

% truncate the results
A = A(subs{:});

end % convnfft
