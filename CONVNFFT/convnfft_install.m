function convnfft_install
% function convnfft_install
% Installation by building the C-mex file needed for convnfft
%
% Author: Bruno Luong <brunoluong@yahoo.com>
% History
% Original: 16/Sept/2009

arch=computer('arch');
%mexopts = {'-O'  ['-' arch]};
% 64-bit platform
mexopts = {};
if ~isempty(strfind(computer(),'64'))
    mexopts(end+1) = {'-largeArrayDims'};
end

% invoke MEX compilation tool
mex(mexopts{:},'inplaceprod.c');