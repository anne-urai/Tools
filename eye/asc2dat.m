function [data, event, blinksmp, saccsmp] = asc2dat(asc)
% takes asc data from EyeLink file and converts this into events and
% fieldtrip data structure

% create event structure for messages
evcell = cell(length(asc.msg),1);
event = struct('type', evcell, 'sample', evcell, 'value', evcell, 'offset', evcell, 'duration', evcell );

for i=1:length(asc.msg),
    
    strtok = tokenize(asc.msg{i});
    event(i).type = strtok{3};
    str2double(strtok{2});
    
    % match the message to its sample
    smpstamp = dsearchn(asc.dat(1,:)', str2double(strtok{2}));
    % find closest sample index of trigger in ascii dat
    
    if ~isempty(smpstamp)
        event(i).sample = smpstamp(1);
    else % if no exact sample was found
        warning('no sample found');
    end
    event(i).value = asc.msg{i};
end

% make data struct
% important: match the right data chans to their corresponding labels...
data                = [];
data.label          = {'EyeH'; 'EyeV'; 'EyePupil'};
data.trial          = {asc.dat(2:4, :)};  %% !!!!!!!!! %% only take gaze and pupil
data.fsample        = asc.fsample;
data.time           = {0:1/data.fsample:length(asc.dat(1,:))/data.fsample-1/data.fsample};
data.sampleinfo     = [1 length(asc.dat(1,:))];

if data.fsample ~= 1000,
    warning('pupil not sampled with 1000Hz');
end

% parse blinks
arg1 = repmat({'%*s%*s%d%d'}, length(asc.eblink), 1);
blinktimes = cellfun(@sscanf, asc.eblink, arg1, 'UniformOutput', false); % parse blinktimes from ascdat
blinktimes = cell2mat(cellfun(@transpose, blinktimes, 'UniformOutput', false)); %transpose and turn into matrix
timestamps = asc.dat(1,:); % get the time info
try
    blinksmp = arrayfun(@(x) find(timestamps == x, 1,'first'), blinktimes, 'UniformOutput', true ); %find sample indices of blinktimes in timestamps
catch
    blinksmp = arrayfun(@(x) dsearchn(timestamps', x), blinktimes, 'UniformOutput', true ); %find sample indices of blinktimes in timestamps
end

% parse saccades
arg1 = repmat({'%*s%*s%d%d%d'}, length(asc.esacc), 1);
sacctimes = cellfun(@sscanf, asc.esacc, arg1, 'UniformOutput', false); % parse blinktimes from ascdat
sacctimes = cell2mat(cellfun(@transpose, sacctimes, 'UniformOutput', false)); %transpose and turn into matrix
sacctimes = sacctimes(:, [1 2]); % remove last column
timestamps = asc.dat(1,:); % get the time info

try
    saccsmp = arrayfun(@(x) find(timestamps == x, 1,'first'), sacctimes, 'UniformOutput', true ); %find sample indices
catch
    saccsmp = arrayfun(@(x) dsearchn(timestamps', x), sacctimes, 'UniformOutput', true );
end

end