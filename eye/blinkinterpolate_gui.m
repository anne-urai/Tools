function [newblinksmp, newdata] = blinkinterpolate_gui(data, fsample)

if ~exist('data', 'var'), error('no data found'); end
if ~exist('fsample', 'var'), error('no fsample found'); end

% Create a figure and axes
f = figure('Visible','off');
f.Units = 'normalized';
f.Position = [0 0 1 1];

% start with some sensible defaults
threshold = 300; padding = 0.15;
[newblinksmp, newdata] = blinkinterpolate(data, fsample, threshold, padding);

% Create slider
sld = uicontrol('Style', 'slider',...
    'Min',0,'Max',1,'SliderStep', [0.01 0.1], 'Value', 0.15,...
    'Units','normalized', 'Position',  [0.3 0.01 0.3 0.05],...
    'BackgroundColor', 'w', 'Callback', @changethreshold);

% Add a text uicontrol to label the slider.
txt = uicontrol('Style','text',...
    'Units','normalized','Position',[0.3 0.07 0.3 0.05],...
    'BackgroundColor', 'w', 'String','Adjust threshold');

% Create slider
sld = uicontrol('Style', 'slider',...
    'Min',0,'Max',1,'SliderStep', [0.01 0.1], 'Value',0.15,...
    'Units','normalized', 'Position',  [0.65 0.01 0.3 0.05],...
    'BackgroundColor', 'w', 'Callback', @changepadding);

% Add a text uicontrol to label the slider.
txt = uicontrol('Style','text',...
    'Units','normalized','Position',[0.65 0.07 0.3 0.05],...
    'BackgroundColor', 'w', 'String','Adjust padding');

% button to exit
pbt = uicontrol('Style', 'pushbutton', ...
    'Units','normalized','Position',[0.05 0.01 0.15 0.05],...
    'BackgroundColor', 'w','String','Finish', 'Callback', @finish);

% Make figure visble after adding all components
f.Visible = 'on';
uiwait;

    function finish(source, callbackdata)
        close(f);
    end

    function changethreshold(source, callbackdata)
        threshold = source.Value * 3000;
        subplot(551); cla;
        [newblinksmp, newdata] = blinkinterpolate(data, fsample, threshold, padding);
    end

    function changepadding(source, callbackdata)
        padding = source.Value;
        subplot(551); cla;
        [newblinksmp, newdata] = blinkinterpolate(data, fsample, threshold, padding);
    end

% function that does the actual blinkinterpolation
    function [newblinksmp, newdata] = blinkinterpolate(pupildat, fsample, threshold, padding)
        
        timeaxis     = (1:length(pupildat)) * fsample;
        
        % smooth the signal a bits
        win             = hanning(11);
        pupildatsmooth  = filter2(win.', pupildat,'same');
        pupildattest    = pupildatsmooth;
        
        s1 = subplot(411); cla;
        % check visually
        plot(timeaxis,pupildatsmooth, 'b');
        axis tight; box off;  set(gca, 'TickDir', 'out', 'box', 'off', 'XTick', []);
        ylabel('raw');
        
        % compute the velocity
        velocity    = diff(pupildatsmooth);
        cutoff      = threshold; % arbitrary, might differ per file/subject
        
        % find blinks
        blinkstart  = find(velocity<-cutoff);
        blinkend    = find(velocity> cutoff);
        
        % assert that these points make sense
        blinksmp = nan(length(blinkstart), 2);
        cutoff2   = max([median(pupildatsmooth)- 1*std(pupildatsmooth) 0]);
        for b = 1:length(blinkstart),
            
            % for each blinkstart, find the first blinkend
            if b > 1 && blinkstart(b) - blinkstart(b-1) < 0.001 * fsample,
                continue
            end
            thisblinkstart = blinkstart(b);
            thisblinkend = blinkend(find(blinkend > blinkstart(b), 1, 'first'));
            
            % check if there is missing data in between
            blinkdat = pupildatsmooth(thisblinkstart:thisblinkend);
            if (length(find(blinkdat <= cutoff2)) / length(blinkdat)) > 0.1,
                % if the data consists mainly of 0s,
                blinksmp(b, :) = [thisblinkstart thisblinkend ];
            end
        end
        % remove nans
        blinksmp(isnan(nanmean(blinksmp, 2)), :) = [];
        
        % add some padding around the blinks as they have been detected
        if ~isempty(blinksmp),
            blinksmp(:,1) = round(blinksmp(:,1) - padding * fsample);
            blinksmp(:,2) = round(blinksmp(:,2) + 2 * padding * fsample); % need more padding after blink
            
            % if any points went outside the domain of the signal, put back
            blinksmp((blinksmp < 1)) = 1;
            blinksmp((blinksmp > length(pupildatsmooth))) = length(pupildatsmooth);
            
            % make the pupil NaN at those points
            for b = 1:size(blinksmp,1),
                pupildatsmooth(blinksmp(b,1):blinksmp(b,2)) = NaN;
            end
        end
        
        % set anything that's still zero to NaN
        pupildatsmooth(pupildatsmooth==0) = NaN;
        pupildatsmooth((pupildatsmooth< nanmedian(pupildatsmooth) - 5*nanstd(pupildatsmooth))) = NaN;
        
        % linear interpolation
        pupildatsmooth(isnan(pupildatsmooth)) = interp1(find(~isnan(pupildatsmooth)), ...
            pupildatsmooth(~isnan(pupildatsmooth)), find(isnan(pupildatsmooth)), 'linear');
        
        s2 = subplot(412); cla;
        plot(timeaxis, pupildattest, 'Color', [0.8 0.8 0.8]); hold on;
        plot(timeaxis, pupildatsmooth, 'r');
        axis tight; box off;
        ylim([nanmin(pupildatsmooth) - nanstd(pupildatsmooth) ...
            nanmax(pupildatsmooth) + nanstd(pupildatsmooth)]);
        set(gca, 'TickDir', 'out', 'box', 'off', 'XTick', []);
        ylabel('interpolated');
        
        % SECOND PASS FOR HALF-BLINKS
        % compute the velocity
        velocity    = diff(pupildatsmooth);
        newblinksmp = blinksmp; clear blinksmp;
        
        % find blinks again, higher cutoff
        blinkstart  = find(velocity<- 2 * cutoff);
        blinkend    = find(velocity> 2 * cutoff);
        
        if exist('blinkstart', 'var'),
            % assert that these points make sense
            blinksmp = nan(length(blinkstart), 2);
            cutoff2   = max([median(pupildatsmooth)- 3*std(pupildatsmooth) 0]);
            for b = 1:length(blinkstart),
                
                % for each blinkstart, find the first blinkend
                if b > 1 && blinkstart(b) - blinkstart(b-1) < 0.01 * fsample,
                    continue
                end
                thisblinkstart = blinkstart(b);
                thisblinkend = blinkend(find(blinkend > blinkstart(b), 1, 'first'));
                
                % check if there is missing data in between
                blinkdat = pupildatsmooth(thisblinkstart:thisblinkend);
                if (length(find(blinkdat <= cutoff2)) / length(blinkdat)) > 0.3,
                    % if the data consists mainly of 0s,
                    blinksmp(b, :) = [thisblinkstart thisblinkend ];
                end
            end
            % remove nans
          if ~isempty(blinksmp),  blinksmp(isnan(nanmean(blinksmp, 2)), :) = []; end
        end
        
        % add some padding around the blinks as they have been detected
        if ~isempty(blinksmp),
            blinksmp(:,1) = round(blinksmp(:,1) - padding * fsample);
            blinksmp(:,2) = round(blinksmp(:,2) + 2 * padding * fsample); % need more padding after blink
            
            % if any points went outside the domain of the signal, put back
            blinksmp((blinksmp < 1)) = 1;
            blinksmp((blinksmp > length(pupildatsmooth))) = length(pupildatsmooth);
            
            % make the pupil NaN at those points
            for b = 1:size(blinksmp,1),
                pupildatsmooth(blinksmp(b,1):blinksmp(b,2)) = NaN;
            end
        end
        
        % set anything that's still zero to NaN
        pupildatsmooth(pupildatsmooth==0) = NaN;
        pupildatsmooth((pupildatsmooth< nanmedian(pupildatsmooth) - 6*nanstd(pupildatsmooth))) = NaN;
        
        % linear interpolation
        pupildatsmooth(isnan(pupildatsmooth)) = interp1(find(~isnan(pupildatsmooth)), ...
            pupildatsmooth(~isnan(pupildatsmooth)), find(isnan(pupildatsmooth)), 'linear');
        
        pupildatclean = pupildatsmooth;
        
        % to avoid edge artefacts (can be huge when zscoring), pad ends
        edgepad = 1; % s
        pupildatclean(1:edgepad*fsample)           = NaN;
        pupildatclean(end-edgepad*fsample : end)   = NaN;
        
        % also extrapolate ends
        pupildatclean(isnan(pupildatclean)) = interp1(find(~isnan(pupildatclean)), ...
            pupildatclean(~isnan(pupildatclean)), find(isnan(pupildatclean)), 'nearest', 'extrap');
        
        s3 = subplot(413); cla;
        plot(timeaxis, pupildattest, 'Color', [0.8 0.8 0.8]); hold on;
        plot(timeaxis, pupildatclean, 'b');
        axis tight; box off;
        ylim([nanmin(pupildatclean) - nanstd(pupildatclean) ...
            nanmax(pupildatclean) + nanstd(pupildatclean)]);
        set(gca, 'TickDir', 'out', 'box', 'off', 'XTick', []);
        ylabel('final');
        
        try  linkaxes([s1 s2 s3], 'x'); end
        curxlim = get(gca, 'XLim');
        xlim([-5000000 curxlim(2)]); %  make the beginning of the signal visible
        xlabel(sprintf('Velocity threshold %.2f, padding %.3f ms', threshold, padding));
        
        % output the cleaned data
        newdata = pupildatclean;
        drawnow;
        
    end

end