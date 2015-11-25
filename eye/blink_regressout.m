function [data] = blink_regressout(asc, data, blinksmp, saccsmp, plotme)
% then regresses out the pupil response to blinks and saccades 
% Anne Urai, 2015

% get the stuff we need
dat.time        = data.time{1};
dat.pupil       = data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:);
dat.gazex       = data.trial{1}(find(strcmp(data.label, 'EyeH')==1),:);
dat.gazey       = data.trial{1}(find(strcmp(data.label, 'EyeV')==1),:);

% initialize settings
if ~exist('plotme', 'var'); plotme = true; end % plot all this stuff

% ====================================================== %
% STEP 1: BAND-PASS FILTER
% ====================================================== %

if plotme,
    figure;  subplot(511); plot(dat.time,dat.pupil, 'b');
    axis tight; box off; ylabel('Raw');
end

% create a bandpass filter
[b,a] = butter(2, [0.1 10]/(data.fsample/2));
dat.bpfilt = filter(b,a, dat.pupil);

% get residuals for later
dat.resid = dat.pupil - dat.bpfilt;

% ====================================================== %
% STEP 2: DOWNSAMPLING
% ====================================================== %

newFs = 10;
downsmp = resample(dat.bpfilt,newFs, data.fsample);

% also downsample the sample idx for blinks and saccades
newblinksmp = round(blinksmp * (newFs/data.fsample));
newsaccsmp  = round(saccsmp * (newFs/data.fsample));

% ====================================================== %
% STEP 3: DECONVOLUTION
% ====================================================== %

clear designM
colcnt = 1;
for r = 1:2, % two regressors
    
    % create a logical vector to speed up the analyses
    samplelogical                      = zeros(length(downsmp), 1);
    switch r
        case 1
            samplelogical(newblinksmp(:, 2))   = 1; % first sample of this regressor
        case 2
            samplelogical(newsaccsmp(:, 2))   = 1; % first sample of this regressor
    end
    
    % put samples in design matrix at the right spot
    impulse = [-1 5];
    
    % shift the starting points so the deconvolution catches -500 ms
    samplelogical = circshift(samplelogical, newFs * impulse(1));
    for c = 1 : range(impulse)*newFs,
        % for each col, put ones at the next sample values
        designM(:, colcnt)   = samplelogical;
        samplelogical   = [0; samplelogical(1:end-1)]; % shift
        colcnt = colcnt + 1;
    end
end

% deconvolve to get IRFs
clear designM
colcnt = 1;
for r = 1:2, % two regressors
    
    % put samples in design matrix at the right spot
    impulse = [-0.5 5];
    
    % create a logical vector to speed up the analyses
    samplelogical = zeros(length(downsmp), 1);
    switch r
        case 1
            offset = newblinksmp(:, 2) + impulse(1)*newFs;
        case 2
            offset = newsaccsmp(:, 2) + impulse(1)*newFs;
    end
    offset(offset<0) = []; % remove those that we cant catch so early
    samplelogical(offset)   = 1; % put 1s at these events
    
    % shift the starting points so the deconvolution catches -500 ms
    for c = 1 : range(impulse)*newFs,
        % for each col, put ones at the next sample values
        designM(:, colcnt)   = samplelogical;
        samplelogical   = [0; samplelogical(1:end-1)]; % shift
        colcnt = colcnt + 1;
    end
end

% deconvolve to get IRFs
deconvolvedPupil       = pinv(designM) * downsmp'; % pinv more robust than inv?
deconvolvedPupil       = reshape(deconvolvedPupil, range(impulse)*newFs, 2);

% ====================================================== %
% STEP 5: FIT CANONICAL RESPONSES
% ====================================================== %

% Erlang gamma function from Hoeks and Levelt, Wierda
%ft = fittype('x.^w .* exp(-x.*w ./ tmax)');
doublegamma = fittype('s1 * ((x.*n1) * exp(-n1.*x ./ tmax1)) + s2 + ((x.*n2) * exp(-n2.*x ./ tmax2))');
x = linspace(0, range(impulse), numel(deconvolvedPupil(:, 1)));

% constrained fit to the deconvolved kernels
fitIRF = fit(x', deconvolvedPupil(:, 1), doublegamma, ...
    'startpoint', [10, 10, -1, 1, 0.9, 2.5], ...
    'lower', [9, 8, -Inf, 1e-25, 0.5, 1.5], ...
    'upper', [11, 12, 1e-25, Inf, 1.5, 4])

fitCoefs = coeffvalues(fitIRF);


% check if the fits look good
if plotme,
    subplot(5,3,4);
    plot(linspace(impulse(1), impulse(2), range(impulse)*newFs), deconvolvedPupil);
    box off; axis tight;
end

% convolve them with the sample regresssamplelogical  = zeros(length(downsmp), 1);
samplelogical(blinksmp(:, 2)) = 1;
reg1 = cconv(samplelogical, deconvolvedPupil(:, 1));
reg1 = reg1(1:length(samplelogical));

% convolve them with the sample regressors
samplelogical  = zeros(length(dat.bpfilt), 1);
samplelogical(saccsmp(:, 2)) = 1;
reg2 = cconv(samplelogical, deconvolvedPupil(:, 2));
reg2 = reg2(1:length(samplelogical));



% ====================================================== %
% STEP 4: REGRESS OUT THOSE RESPONSES
% ====================================================== %




assert(1==0)

end


