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
    clf;  subplot(511); plot(dat.time,dat.pupil);
    axis tight; box off; ylabel('Interp');
end

% filter the pupil timecourse twice
% first, get rid of slow drift
[b,a] = butter(2, 0.02 / data.fsample, 'high');
dat.hpfilt = filtfilt(b,a, dat.pupil);
% get residuals for later
dat.lowfreqresid = dat.pupil - dat.hpfilt;

% also get rid of fast instrument noise
[b,a] = butter(2, 4 / data.fsample, 'low');
dat.bpfilt = filtfilt(b,a, dat.hpfilt);

if plotme,
    subplot(512); plot(dat.time,dat.bpfilt);
    axis tight; box off; ylabel('Bandpass');
end

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
% STEP 5: FIT CANONICAL IRF GAMMA FUNCS
% ====================================================== %

% double Erlang gamma function from Hoeks and Levelt, Wierda

doublegamma = fittype('s1 * (x.^n1) * exp((-n1.*x) ./ tmax1) + s2 * (x.^n2) * exp((-n2.*x) ./ tmax2)');
x = linspace(0, range(impulse), numel(deconvolvedPupil(:, 1)));

% demean curves before fitting
deconvolvedPupil(:, 1) = deconvolvedPupil(:, 1) - mean(deconvolvedPupil(:, 1));
deconvolvedPupil(:, 2) = deconvolvedPupil(:, 2) - mean(deconvolvedPupil(:, 2));

% constrained fit to the deconvolved kernels
fitIRFblink = fit(x', deconvolvedPupil(:, 1), doublegamma, ...
    'startpoint', [10, 10, -1, 1, 0.9, 2.5], ...
    'lower', [9, 8, -Inf, 1e-25, 0.1, 1.5], ...
    'upper', [11, 12, -1e-25, Inf, 1.5, 4]);
blinkIRF = feval(fitIRFblink, x');

% also for saccade response
fitIRFsacc = fit(x', deconvolvedPupil(:, 2), doublegamma, ...
    'startpoint', [10, 10, -1, 1, 0.9, 2.5], ...
    'lower', [9, 8, -Inf, 1e-25, 0.5, 1.5], ...
    'upper', [11, 12, -1e-25, Inf, 1.5, 4]);
saccIRF = feval(fitIRFsacc, x');

% check if the fits look good
if plotme,
    subplot(5,3,7);
    % first, blink stuff
    h = plot(fitIRFblink, x', deconvolvedPupil(:, 1));
    legend off; box off; axis tight; ylabel('Blink');
    
    subplot(5,3,8);
    % first, blink stuff
    plot(fitIRFsacc, x', deconvolvedPupil(:, 2));
    legend off;
    box off; axis tight; ylabel('Saccade');
end

% ====================================================== %
% UPSAMPLE AND MAKE REGRESSORS
% ====================================================== %

% upsample to the sample rate of the data
blinkIRFup = resample(blinkIRF, data.fsample, newFs);

% convolve with timepoints of events in original data
samplelogical = zeros(length(dat.pupil), 1);
offset = blinksmp(:, 2) + impulse(1)*data.fsample;
offset(offset<0) = []; % remove those that we cant catch so early
samplelogical(offset)   = 1; % put 1s at these events
% convolve
reg1 = cconv(samplelogical, blinkIRFup);
reg1 = reg1(1:length(samplelogical))';

% SAME FOR SACCADES
% upsample to the sample rate of the data
saccIRFup = resample(saccIRF, data.fsample, newFs);

% convolve with timepoints of events in original data
samplelogical = zeros(length(dat.pupil), 1);
offset = saccsmp(:, 2) + impulse(1)*data.fsample;
offset(offset<0) = []; % remove those that we cant catch so early
samplelogical(offset)   = 1; % put 1s at these events
% convolve
reg2 = cconv(samplelogical, saccIRFup);
reg2 = reg2(1:length(samplelogical))';

% ====================================================== %
% REGRESS OUT THOSE RESPONSES FROM DATA
% ====================================================== %

% make design matrix
designM = [ones(size(reg1))' reg1' reg2'];

% estimate glm weights
b = regress(dat.pupil', designM);

% generate prediction just based on these regressors
prediction = designM * b;

% subtract prediction
dat.residualpupil = dat.pupil - prediction';

if plotme,
    subplot(514); plot(dat.time,prediction);
    axis tight; box off; ylabel('Prediction');
end

% ====================================================== %
% ADD BACK THE SLOW DRIFT
% ====================================================== %

newpupil = dat.lowfreqresid + dat.residualpupil;

if plotme,
    subplot(515);
    plot(dat.time, dat.pupil', 'color', [0.3 0.3 0.3]); hold on;
    plot(dat.time,newpupil);
    axis tight; box off; ylabel('Cleaned');
end

data.trial{1}(find(strcmp(data.label, 'EyePupil')==1),:) = newpupil;

end


