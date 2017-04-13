function hdrols = deconvTseries(scm,dat,err)

% hdrols = deconvTseries(scm,dat,err)
% 
% computes a ordinary least squares estimate 
% of hemodynamic response function from
% from ER-fMRI time series (dat) and stimulus convolution
% matrix (scm)
% 
% dat = scm *  hdr + noise
% hdr_ols = inv(scm'  * scm) * scm'  * dat
% 
% assumes temporally uncorrelated noise,
% i.e.: COV(noise) = var(noise) * I 
% hdr_ols is unbiased estimate, that is,
% does not assume particular shape of response
% (Dale A, HBM, 1999)
% 
% dat is column vector of length Ndatsmp,   
% scm is horizontal concatenation of Ncond individual stimulus 
% convolution matrices, i.e., Ndatsmp x  Nestsmp arrays, 
% where Nestsmp is the length (in samples) of HDR estimate,
% and Ndatsmp is the length (in samples) of measured 
% time series
% if error == 1, and error estimate for each parameter is computed

dat       =  dat(:);

% estimate HDR 
% these alternatives should be equivalent
%hdrpar = inv(scm'*scm)*scm'*dat;
%hdrpar = scm\dat;    
hdrpar = pinv(scm)*dat;    
predic = scm*hdrpar;

if err % estimate error
    %double-check error estimate - standard error?
    [n,k]               = size(scm);
    ssq                 = (norm(dat - predic))^2;
    noisevar            = ssq/(n-k);
    cov                 = inv(scm'*scm);
    %cov                = (scm'*scm).^-1;
    hdrerr              = diag(cov)*noisevar;
else
    hdrerr = [];
end

% collect the results
hdrols.par             = hdrpar;    % vertical concetenation of HDR estimates for each stim type in scn
hdrols.err             = hdrerr;        % vertical concetenation of corresponding errors
hdrols.predic          = predic;