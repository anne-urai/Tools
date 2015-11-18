function [ data ] = shiftoffset_timelock( data, trials, offset, prestim, poststim, fsample, baseline)
% [ data ] = shiftoffset_timelock( data, trials, offset, prestim, poststim, fsample, baseline)% Anne Urai

warning off;
ft_defaults;
pupilchan           = find(strcmp(data.label, 'EyePupil')==1);

if baseline == 2, % take globalmean
    pupildat    = cell2mat(data.trial);
    globalmean  = nanmean(pupildat(pupilchan, :));
end

if isempty(trials),
    trials = find(~isnan(offset));
end

% select a subset of trials
if ~isempty(trials),
    offset = offset(trials);
    
    % remove trials for which no offset is defined;
    trials(find(isnan(offset))) = [];
    offset(find(isnan(offset))) = [];
    
    cfg = [];
    cfg.trials = false(1, length(data.trial));
    cfg.trials(trials) = true;
    data = ft_selectdata(cfg, data);
end

% timelock
%warning off;
cfg = [];
cfg.begsample       = round(offset - prestim*fsample); % take offset into account
cfg.endsample       = round(offset + poststim*fsample);
data                = ft_redefinetrial(cfg, data);

% then shift the time axis
cfg             = [];
cfg.offset      = -offset;
data            = ft_redefinetrial(cfg, data);

cfg                 = [];
cfg.keeptrials      = 'yes';
cfg.vartrllength    = 2;
data                = ft_timelockanalysis(cfg, data);
% assert(length(find(isnan(data.trial)))==0, 'nans in data');

pupilchan       = find(strcmp(data.label, 'EyePupil')==1);
bl = nan(1, size(data.trial, 1));

if baseline < 2, % local
    
    blsmp = find(data.time < 0);
    for t = 1:size(data.trial, 1),
        bl(t) = mean(squeeze(data.trial(t, pupilchan, blsmp)));
        
        % actually do the baseline correction
        if baseline == 1,
            if t == 1,     disp('local baseline correction...'); end
            data.trial(t, pupilchan,:) = data.trial(t, pupilchan, :) - bl(t);
        end
    end
    
elseif baseline == 2, % global
    disp('global baseline correction...');
    blsmp = find(data.time < 0);
    for t = 1:size(data.trial, 1),
        % see Kloosterman EJN
        bl(t) = nanmean(squeeze(data.trial(t, pupilchan, blsmp)));
        data.trial(t,pupilchan,:) = (data.trial(t, pupilchan,:) - bl(t))/globalmean;
    end
end

pupilchan           = find(strcmp(data.label, 'EyePupil')==1);

% average over the trial dim
data.avg = squeeze(nanmean(data.trial(:,pupilchan,:), 1));
data.var = squeeze(nanstd(data.trial(:,pupilchan,:), [], 1)) / sqrt(size(data.trialinfo,1));
data.trialnum = size(data.trialinfo,1);
data.bl       = bl;

warning on;
end

