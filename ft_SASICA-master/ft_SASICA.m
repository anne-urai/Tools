% [EEG, cfg] = eeg_SASICA(EEG,cfg)
%
% Suggest components to reject from an EEG dataset with ICA decomposition.
%
% Inputs: EEG: EEGlab structure with ICA fields.
%         cfg: structure describing which methods are to use for suggesting
%              bad components (see structure called def, in the code below)
%              Available methods are:
%              Autocorrelation: detects noisy components with weak
%                               autocorrelation (muscle artifacts usually)
%              Focal components: detects components that are too focal and
%                               thus unlikely to correspond to neural
%                               activity (bad channel or muscle usually).
%              Focal trial activity: detects components with focal trial
%                               activity, with same algorhithm as focal
%                               components above. Results similar to trial
%                               variability.
%              Signal to noise ratio: detects components with weak signal
%                               to noise ratio between arbitrary baseline
%                               and interest time windows.
%              Dipole fit residual variance: detects components with high
%                               residual variance after subtraction of the
%                               forward dipole model. Note that the inverse
%                               dipole modeling using DIPFIT2 in EEGLAB
%                               must have been computed to use this
%                               measure.
%              EOG correlation: detects components whose time course
%                               correlates with EOG channels.
%              Bad channel correlation: detects components whose time course
%                               correlates with any channel(s).
%              ADJUST selection: use ADJUST routines to select components
%                               (see Mognon, A., Jovicich, J., Bruzzone,
%                               L., & Buiatti, M. (2011). ADJUST: An
%                               automatic EEG artifact detector based on
%                               the joint use of spatial and temporal
%                               features. Psychophysiology, 48(2), 229-240.
%                               doi:10.1111/j.1469-8986.2010.01061.x)
%              FASTER selection: use FASTER routines to select components
%                               (see Nolan, H., Whelan, R., & Reilly, R. B.
%                               (2010). FASTER: Fully Automated Statistical
%                               Thresholding for EEG artifact Rejection.
%                               Journal of Neuroscience Methods, 192(1),
%                               152-162. doi:16/j.jneumeth.2010.07.015)
%              MARA selection:  use MARA classification engine to select components
%                               (see Winkler I, Haufe S, Tangermann M.
%                               2011. Automatic Classification of
%                               Artifactual ICA-Components for Artifact
%                               Removal in EEG Signals. Behavioral and
%                               Brain Functions. 7:30.)
%
%              Options: noplot: just compute and store result in EEG. Do
%                           not make any plots.
%
% If you use this program in your research, please cite the following
% article:
%   Chaumon M, Bishop DV, Busch NA. A Practical Guide to the Selection of
%   Independent Components of the Electroencephalogram for Artifact
%   Correction. Journal of neuroscience methods. 2015
%
%   SASICA is a software that helps select independent components of
%   the electroencephalogram based on various signal measures.
%     Copyright (C) 2014  Maximilien Chaumon
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.


function [comp, cfg] = ft_SASICA(comp,cfg)

% takes as input a comp structure from runica (should be full rank)

if nargin < 1
    error('Need at least one input argument')
end
if ~exist('cfg','var')
    cfg = struct;
end
% deal with calling pop_prop_ADJ or pop_prop_FST here
if ischar(cfg) && strncmp(cfg,'pop_',4)
    eval(cfg);
    return
end
%
PLOTPERFIG = 35;
def = SASICA('getdefs');

cfg = setdef(cfg,def);
v = regexp(version,'^\d+\.\d+','match');
if num2str(v{1}) >= 8.4
    mkersize = 25;
else
    mkersize = 20;
end

if isempty(comp.unmixing)
    errordlg('No ica weights in the current EEG dataset! Compute ICA on your data first.')
    error('No ica weights! Compute ICA on your data first.')
end
struct2ws(cfg.opts);

rejfields = {'icarejautocorr' 'Autocorrelation' [         0         0    1.0000]
    'icarejfocalcomp' 'Focal components' [         0    0.5000         0]
    'icarejtrialfoc' 'Focal trial activity' [    0.7500         0    0.7500]
    'icarejSNR' 'Signal to noise ' [    0.8000         0         0]
    'icarejresvar' 'Residual variance' [    0     0.7500    0.7500]
    'icarejchancorr' 'Correlation with channels' [    0.7500    0.7500         0]
    'icarejADJUST' 'ADJUST selections' [    .3 .3 .3]
    'icarejFASTER' 'FASTER selections' [    0 .7 0]
    'icarejMARA' 'MARA selections' [    .5 .5 0]
    };

ncomp= size(comp.unmixing,2); % ncomp is number of components
rejects = zeros(size(rejfields,1),1);

if numel(noplot) == 1
    noplot = noplot * ones(1,size(rejfields,1));
end

if any(~noplot)
    figure(321541);clf;% just a random number so we always work in the same figure
    BACKCOLOR           = [.93 .96 1];
    set(gcf,'numbertitle', 'off','name','Automatic component rejection measures','color',BACKCOLOR)
    isubplot = 1;
end


if ~nocompute
    icaacts = comp.trial;
    if iscell(icaacts) % concatenate
        Nchans = size(icaacts{1},1);
        Ntrials = length(icaacts);
        Nsamples = zeros(1,Ntrials);
        for trial=1:Ntrials
            Nsamples(trial) = size(icaacts{trial},2);
        end
        dat = zeros(Nchans, sum(Nsamples));
        for trial=1:Ntrials
            fprintf('.');
            begsample = sum(Nsamples(1:(trial-1))) + 1;
            endsample = sum(Nsamples(1:trial));
            dat(:,begsample:endsample) = icaacts{trial};
        end
        comp.icaacts = dat; clear dat;
    end
    
    if iscell(comp.trial)
        comp.trial = cat(2,comp.trial{:});
    end
    
    comp.reject.SASICA = [];
    for ifield = 1:size(rejfields,1)
        %     EEG.reject.SASICA.(rejfields{ifield}) = false(1,ncomp);
        comp.reject.SASICA.([rejfields{ifield} 'col']) = rejfields{ifield,3};
    end
    fprintf('Computing selection methods...\n')
end
if cfg.autocorr.enable
    rejects(1) = 1;
    disp('Autocorrelation.')
    %% Autocorrelation
    % Identifying noisy components
    %----------------------------------------------------------------
    struct2ws(cfg.autocorr);
    
    if ~nocompute
        Ncorrint=round(autocorrint/(1000/comp.fsample)); % number of samples for lag
        rej = false(1,ncomp);
        for k=1:ncomp
            y=comp.icaacts(k,:,:);
            yy=xcorr(mean(y,3),Ncorrint,'coeff');
            autocorr(k) = yy(1);
        end
        dropautocorr = readauto(dropautocorr,autocorr,'-');
        for k = 1:ncomp
            if autocorr(k) < dropautocorr
                rej(k)=true;
            end
        end
        comp.reject.SASICA.(strrep(rejfields{1,1},'rej','')) = autocorr;
        comp.reject.SASICA.(strrep(rejfields{1,1},'rej','thresh')) = dropautocorr;
        comp.reject.SASICA.(rejfields{1,1}) = logical(rej);
    else
        autocorr = comp.reject.SASICA.(strrep(rejfields{1,1},'rej',''));
        dropautocorr = comp.reject.SASICA.(strrep(rejfields{1,1},'rej','thresh'));
        rej = comp.reject.SASICA.(rejfields{1,1});
    end
    %----------------------------------------------------------------
    if ~noplot(1)
        subplot(2,3,isubplot);cla;isubplot = isubplot+1;
        set(gca,'fontsize',FontSize)
        plot(autocorr,'k','linestyle','none');
        
        hold on
        xlim([0 ncomp+1]);
        s = std(autocorr);
        m = mean(autocorr);
        yl = ylim;xl = xlim;
        [x,y] = meshgrid(xl(1):.1:xl(2),yl(1):.1:yl(2));
        galpha = 1./(s*(2*pi)^.5).*exp(-(y-m).^2./(2.*s^2));
        %     h = surf(x,y,-ones(size(y)));shading flat
        %     color = [ 0 0 0]';
        %     C = repmat(color,[1,size(y)]);
        %     C = permute(C,[2 3 1]);
        %     set(h,'alphadata',1-galpha,'alphadatamapping','scaled','facealpha','interp',...
        %         'CData',C,'CDataMapping','direct')
        hline(dropautocorr,'r');
        
        plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{1,3},'markersize',40)
        xlabel('Components')
        ylabel('Autocorrelation')
        title(['Autocorrelation at ' num2str(autocorrint) ' ms.'])
        toplot = autocorr;
        toplot(toplot > dropautocorr) = NaN;
        plot(toplot,'o','color',rejfields{1,3})
        for i = 1:numel(autocorr)
            h = scatter(i,autocorr(i),mkersize,'k','filled');
            cb = sprintf('eeg_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
            set(h,'buttondownfcn',cb);
        end
    end
    
end
if cfg.focalcomp.enable
    rejects(2) = 1;
    disp('Focal components.')
    %% Focal activity
    %----------------------------------------------------------------
    struct2ws(cfg.focalcomp);
    if ~nocompute
        rej = false(1,ncomp);
        clear mywt
        for k=1:ncomp
            mywt(:,k) = sort(abs(zscore(comp.unmixing(:,k))),'descend'); %sorts standardized weights in descending order
        end
        focalICAout = readauto(focalICAout,mywt(1,:),'+');
        for k = 1:ncomp
            if mywt(1,k) > focalICAout
                rej(k)=true;
            end
        end
        comp.reject.SASICA.(strrep(rejfields{2,1},'rej','')) = mywt(1,:);
        comp.reject.SASICA.(strrep(rejfields{2,1},'rej','thresh')) = focalICAout;
        comp.reject.SASICA.(rejfields{2,1}) = logical(rej);
    else
        mywt(1,:) = comp.reject.SASICA.(strrep(rejfields{2,1},'rej',''));
        focalICAout = comp.reject.SASICA.(strrep(rejfields{2,1},'rej','thresh'));
        rej = comp.reject.SASICA.(rejfields{2,1});
    end
    %----------------------------------------------------------------
    if ~noplot(2)
        subplot(2,3,isubplot);cla;isubplot = isubplot+1;
        set(gca,'fontsize',FontSize)
        toplot = mywt(1,:);
        plot(toplot,'k','linestyle','none');
        toplot(toplot < focalICAout) = NaN;
        hold on
        hline(focalICAout,'r');
        plot(toplot,'o','color',rejfields{2,3});
        xlim([0 ncomp+1]);
        xl = xlim;yl = ylim;
        plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{2,3},'markersize',40)
        xlabel('Components')
        ylabel('Standardized weights')
        title('Components with focal activity')
        for i = 1:numel(mywt(1,:))
            h = scatter(i,mywt(1,i),mkersize,'k','filled');
            cb = sprintf('eeg_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
            set(h,'buttondownfcn',cb);
        end
    end
    
end

if cfg.trialfoc.enable
    rejects(3) = 1;
    disp('Focal trial activity.');
    %% Focal trial activity
    struct2ws(cfg.trialfoc);
    if ~nocompute
        % Find components with focal trial activity (those that have activity
        % on just a few trials and are almost zero on others)
        %----------------------------------------------------------------
        if ndims(comp.icaacts) < 3
            error('This method cannot be used on continuous data (no ''trials''!)');
        end
        myact =sort(abs(zscore(range(comp.icaacts,2),[],3)),3,'descend'); % sorts standardized range of trial activity
        focaltrialout = readauto(focaltrialout,myact(:,:,1)','+');
        % in descending order
        rej = myact(:,:,1) > focaltrialout;
        comp.reject.SASICA.(strrep(rejfields{3,1},'rej','')) = myact(:,:,1)';
        comp.reject.SASICA.(strrep(rejfields{3,1},'rej','thresh')) = focaltrialout;
        comp.reject.SASICA.(rejfields{3,1}) = rej';
    else
        myact = comp.reject.SASICA.(strrep(rejfields{3,1},'rej',''))';
        focaltrialout = comp.reject.SASICA.(strrep(rejfields{3,1},'rej','thresh'));
        rej = comp.reject.SASICA.(rejfields{3,1})';
    end
    %----------------------------------------------------------------
    if ~noplot(3)
        subplot(2,3,isubplot);cla;isubplot = isubplot+1;
        if EEG.trials > 1
            set(gca,'fontsize',FontSize)
            toplot = myact(:,:,1);
            plot(toplot,'k','linestyle','none')
            hold on
            toplot(toplot < focaltrialout) = NaN;
            plot(1:ncomp,toplot,'o','color',rejfields{3,3});
            xlim([0 ncomp+1])
            hline(focaltrialout,'r');
            xl = xlim;yl =ylim;
            xlabel('Components')
            ylabel('Standardized peak trial activity')
            plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{3,3},'markersize',40)
            for i = 1:numel(myact(:,:,1))
                h = scatter(i,myact(i),mkersize,'k','filled');
                cb = sprintf('eeg_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
                set(h,'buttondownfcn',cb);
            end
            
            title(['Focal trial activity'])
        else
            xl = xlim;yl = ylim;
            text(xl(1)+diff(xl)/2,yl(1)+diff(yl)/2,{'Only one trial.' 'Focal trial' 'activity method'  'is inadequate.'},'horizontalalignment','center');
            axis off
        end
    end
    %----------------------------------------------------------------
end

if cfg.SNR.enable
    rejects(4) = 1;
    disp('Signal to noise ratio.')
    %% Low Signal to noise components
    struct2ws(cfg.SNR);
    if ~nocompute
        rejfields{4,2} = ['Signal to noise Time of interest ' num2str(snrPOI,'%g ') ' and Baseline ' num2str(snrBL,'%g ') ' ms.'];
        
        if iscell(comp.time),
            time = cat(2,comp.time{:});
        else
            time = comp.time;
        end
        POIpts = timepts(snrPOI, time);
        BLpts = timepts(snrBL,time);
        
        zz = zscore(comp.icaacts,[],2);% zscore along time
        av1 = mean(zz(:,POIpts,:),3); % average activity in POI across trials
        av2 = mean(zz(:,BLpts,:),3); % activity in baseline acros trials
        SNR = std(av1,[],2)./std(av2,[],2); % ratio of the standard deviations of activity and baseline
        snrcut = readauto(snrcut,SNR,'-');
        rej = SNR < snrcut;
        comp.reject.SASICA.(strrep(rejfields{4,1},'rej','')) = SNR';
        comp.reject.SASICA.(strrep(rejfields{4,1},'rej','thresh')) = snrcut;
        comp.reject.SASICA.(rejfields{4,1}) = rej';
    else
        SNR = comp.reject.SASICA.(strrep(rejfields{4,1},'rej',''))';
        snrcut = comp.reject.SASICA.(strrep(rejfields{4,1},'rej','thresh'));
        rej = comp.reject.SASICA.(rejfields{4,1})';
    end
    %----------------------------------------------------------------
    if ~noplot(4)
        subplot(2,3,isubplot);cla;isubplot = isubplot+1;
        set(gca,'fontsize',FontSize)
        plot(SNR,'k','linestyle','none');
        hold on
        xlim([0 ncomp+1]);
        xl = xlim; yl = ylim;
        hline(snrcut,'r');
        toplot = SNR;
        toplot(toplot > snrcut) = NaN;
        plot(toplot,'o','color',rejfields{4,3})
        plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{4,3},'markersize',40)
        for i = 1:numel(SNR)
            h = scatter(i,SNR(i),mkersize,'k','filled');
            cb = sprintf('ft_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
            set(h,'buttondownfcn',cb);
        end
        title({'Signal to noise ratio between' ['Time of interest ' num2str(snrPOI,'%g ') ' and Baseline ' num2str(snrBL,'%g ') ' ms.']})
        xlabel('Components')
        ylabel('SNR')
    end
    
    %----------------------------------------------------------------
end

if cfg.resvar.enable
    rejects(5) = 1;
    disp('Residual variance thresholding.')
    %% High residual variance
    struct2ws(cfg.resvar);
    if ~nocompute
        resvar = 100*[EEG.dipfit.model.rv];
        rej = resvar > thresh;
        
        EEG.reject.SASICA.(strrep(rejfields{5,1},'rej','')) = resvar;
        EEG.reject.SASICA.(strrep(rejfields{5,1},'rej','thresh')) = thresh;
        EEG.reject.SASICA.(rejfields{5,1}) = rej;
    else
        resvar = EEG.reject.SASICA.(strrep(rejfields{5,1},'rej',''));
        thresh = EEG.reject.SASICA.(strrep(rejfields{5,1},'rej','thresh'));
        rej = EEG.reject.SASICA.(rejfields{5,1});
    end
    %----------------------------------------------------------------
    if ~noplot(5)
        subplot(2,3,isubplot);cla;isubplot = isubplot+1;
        set(gca,'fontsize',FontSize)
        plot(resvar,'k','linestyle','none');
        hold on
        xlim([0 ncomp+1]);
        ylim([0 100]);
        xl = xlim; yl = ylim;
        hline(thresh,'r');
        toplot = resvar;
        toplot(toplot < thresh) = NaN;
        plot(toplot,'o','color',rejfields{5,3})
        plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{5,3},'markersize',40)
        for i = 1:numel(resvar)
            h = scatter(i,resvar(i),mkersize,'k','filled');
            cb = sprintf('eeg_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
            set(h,'buttondownfcn',cb);
        end
        title({'Residual variance of dipole fit'})
        xlabel('Components')
        ylabel('RV (%)')
    end
    
    %----------------------------------------------------------------
end

if cfg.EOGcorr.enable
    rejects(6) = 1;
    disp('Correlation with EOGs.');
    %% Correlation with EOG
    struct2ws(cfg.EOGcorr);
    if ~nocompute
        noV = 1;noH = 1;
        if exist('VEOG','var'), noV = 0;  end
        if exist('HEOG','var'), noH = 0;  end
        %         try
        %             Veogchan = chnb(Veogchannames);
        %         catch
        %             Veogchan = [];
        %         end
        %         try
        %             Heogchan = chnb(Heogchannames);
        %         catch
        %             Heogchan = [];
        %         end
        %         if numel(Veogchan) == 1
        %             VEOG = EEG.data(Veogchan,:,:);
        %         elseif numel(Veogchan) == 2
        %             VEOG = EEG.data(Veogchan(1),:,:) - EEG.data(Veogchan(2),:,:);
        %         else
        %             disp('no Vertical EOG channels...');
        %             noV = 1;
        %         end
        %         if numel(Heogchan) == 1
        %             HEOG = EEG.data(Heogchan,:,:);
        %         elseif numel(Heogchan) == 2
        %             HEOG = EEG.data(Heogchan(1),:,:) - EEG.data(Heogchan(2),:,:);
        %         else
        %             disp('no Horizontal EOG channels...');
        %             noH = 1;
        %         end
        ICs = comp.icaacts(:,:)';
        if ~noV
            VEOG = VEOG(:);
            cV  = abs(corr(ICs,VEOG))';
            corthreshV = readauto(corthreshV,cV,'+');
            rejV = cV > corthreshV ;
        else
            cV = NaN(1,size(ICs,2));
            corthreshV = 0;
            rejV = false(size(cV));
        end
        if ~noH
            HEOG = HEOG(:);
            cH  = abs(corr(ICs,HEOG))';
            corthreshH = readauto(corthreshH,cH,'+');
            rejH = cH > corthreshH;
        else
            cH = NaN(1,size(ICs,2));
            corthreshH = 0;
            rejH = false(size(cH));
        end
        
        comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'VEOG']) = cV;
        comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'VEOG']) = corthreshV;
        comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'HEOG']) = cH;
        comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'HEOG']) = corthreshH;
        comp.reject.SASICA.(rejfields{6,1}) = [rejV|rejH];
    else
        if existnotempty(comp.reject.SASICA,[strrep(rejfields{6,1},'rej','') 'VEOG'])
            cV = comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'VEOG']);
            corthreshV = comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'VEOG']);
        end
        if existnotempty(comp.reject.SASICA,[strrep(rejfields{6,1},'rej','') 'HEOG'])
            cH = comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'HEOG']);
            corthreshH = comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'HEOG']);
        end
    end
    %----------------------------------------------------------------
    if ~noplot(6)
        subplot(2,3,isubplot);cla;isubplot = isubplot+1;
        set(gca,'fontsize',FontSize)
        cols = get(gca,'colororder');
        [hplotcorr] = plot([cV;cH]','.','linestyle','none');
        icol = 2;
        hold all
        xlim([0 ncomp+1]);
        xl = xlim;yl = ylim;
        hline(corthreshV,'color',cols(1,:));
        hline(corthreshH,'color',cols(2,:));
        
        title(['Correlation with EOG'])
        legstr = {'VEOG' 'HEOG'};
        ylabel('Correlation coef (r)');
        xlabel('Components');
        toplot = cV;
        toplot(toplot < corthreshV) = NaN;
        plot(1:ncomp,toplot,'o','color',rejfields{6,3})
        toplot = cH;
        toplot(toplot < corthreshH) = NaN;
        plot(1:ncomp,toplot,'o','color',rejfields{6,3})
        plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{6,3},'markersize',40)
        legend(legstr,'fontsize',10, 'location', 'best');
        for i = 1:numel(cH)
            h(1) = scatter(i,cH(i),mkersize,cols(1,:),'filled');
            h(2) = scatter(i,cV(i),mkersize,cols(2,:),'filled');
            cb = sprintf('ft_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
            set(h,'buttondownfcn',cb);
        end
    end
    %----------------------------------------------------------------
end

if cfg.chancorr.enable
    rejects(6) = 1;
    disp('Correlation with other channels.')
    %% Correlation with other channels
    struct2ws(cfg.chancorr);
    if ~nocompute
        if ~cfg.EOGcorr.enable
            rejH = false(1,ncomp);
            rejV = false(1,ncomp);
        end
        if exist('chanData','var')
            
            chanData = chanData';
            ICs = comp.icaacts(:,:)';
            c  = abs(corr(ICs,chanData))';
            corthresh = mean(readauto(corthresh,c,'+'));
            rej = c > corthresh ;
            if size(rej,1) > 1
                rej = sum(rej)>=1;
            end
            comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'chans']) = c;
            comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'chans']) = corthresh;
            comp.reject.SASICA.(rejfields{6,1}) = [rej|rejH|rejV];
        else
            noplot(6) = 1;
            disp('Could not find the channels to compute correlation.');
            c = NaN(1,ncomp);
            comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'chans']) = c;
            comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'chans']) = corthresh;
            rej = false(1,ncomp);
            comp.reject.SASICA.(rejfields{6,1}) = [rej|rejV|rejH];
        end
    else
        c = comp.reject.SASICA.([strrep(rejfields{6,1},'rej','') 'chans']);
        corthresh = comp.reject.SASICA.([strrep(rejfields{6,1},'rej','thresh') 'chans']);
    end
    %----------------------------------------------------------------
    if ~noplot(6);
        if exist('hplotcorr','var')
            isubplot = isubplot-1;
        end
        subplot(2,3,isubplot);
        if ~cfg.EOGcorr.enable
            cla;
            set(gca,'fontsize',FontSize);
            cols = get(gca,'colororder');
        end
        hold all
        if not(exist('hplotcorr','var'))
            hplotcorr = [];
        end
        icol = numel(hplotcorr);
        for ichan = 1:size(chanData,2)
            [hplotcorr(end+1)] = plot([c(ichan,:)]','.','linestyle','none','color',cols(rem(icol+ichan-1,size(cols,1))+1,:));
        end
        xlim([0 ncomp+1]);
        xl = xlim;yl = ylim;
        hline(corthresh,'r');
        title(['Correlation with channels'])
        if cfg.EOGcorr.enable
            legstr = {'VEOG' 'HEOG' cellchannames{:}};
        else
            legstr = {cellchannames{:}};
        end
        ylabel('Correlation coef (r)');
        xlabel('Components');
        toplot = c;
        for i = 1:size(toplot,1)
            toplot(i,toplot(i,:) < corthresh) = NaN;
        end
        plot(1:ncomp,toplot,'o','color',rejfields{6,3})
        plot(xl(2)-diff(xl)/20,yl(2)-diff(yl)/20,'marker','.','color',rejfields{6,3},'markersize',40)
        legend(hplotcorr,legstr,'fontsize',10, 'location', 'best');
        for ichan = 1:size(c,1)
            for i = 1:size(c,2)
                h = scatter(i,c(ichan,i),mkersize,cols(rem(icol+ichan-1,size(cols,1))+1,:),'filled');
                cb = sprintf('ft_SASICA(EEG, ''pop_prop( %s, 0, %d, findobj(''''tag'''',''''comp%d''''), { ''''freqrange'''', [1 50] })'');', inputname(1), i, i);
                set(h,'buttondownfcn',cb);
            end
        end
        
    end
    %----------------------------------------------------------------
end
if cfg.ADJUST.enable
    rejects(7) = 1;
    disp('ADJUST methods selection')
    %% ADJUST
    struct2ws(cfg.ADJUST);
    if ~nocompute
        [art, horiz, vert, blink, disc,...
            soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
            soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin] = ADJUST (comp);
        
        ADJ.art = art;ADJ.horiz = horiz;ADJ.vert = vert;ADJ.blink = blink;ADJ.disc = disc;
        
        ADJ.soglia_DV = soglia_DV; ADJ.diff_var = diff_var;
        ADJ.soglia_K = soglia_K;ADJ.med2_K = med2_K; ADJ.meanK = meanK;
        ADJ.soglia_SED = soglia_SED; ADJ.med2_SED = med2_SED;ADJ.SED = SED;
        ADJ.med2_SAD = med2_SAD;ADJ.soglia_SAD = soglia_SAD;ADJ.SAD = SAD;
        ADJ.soglia_GDSF = soglia_GDSF; ADJ.med2_GDSF = med2_GDSF;ADJ.GDSF = GDSF;
        ADJ.soglia_V = soglia_V;ADJ.med2_V = med2_V;ADJ.nuovaV = nuovaV;
        ADJ.soglia_D = soglia_D; ADJ.maxdin = maxdin;
        
        rej = false(1,size(comp.icaacts,1));
        rej([ADJ.art ADJ.horiz ADJ.vert ADJ.blink ADJ.disc]) = true;
        
        comp.reject.SASICA.(strrep(rejfields{7,1},'rej','')) = ADJ;
        comp.reject.SASICA.(rejfields{7,1}) = rej;
    else
        ADJ = comp.reject.SASICA.(strrep(rejfields{7,1},'rej',''));
    end
    %----------------------------------------------------------------
end
if cfg.FASTER.enable
    rejects(8) = 1;
    disp('FASTER methods selection')
    %% FASTER
    struct2ws(cfg.FASTER);
    if ~nocompute
        blinkchans = chnb(blinkchans);
        listprops = component_properties(comp,blinkchans);
        FST.rej = min_z(listprops)' ~= 0;
        FST.listprops = listprops;
        
        comp.reject.SASICA.(strrep(rejfields{8,1},'rej','')) = FST;
        comp.reject.SASICA.(rejfields{8,1}) = FST.rej;
    else
        FST = comp.reject.SASICA.(strrep(rejfields{8,1},'rej',''));
    end
    %----------------------------------------------------------------
end
if cfg.MARA.enable
    rejects(9) = 1;
    disp('MARA methods selection')
    %% MARA
    struct2ws(cfg.MARA);
    if ~nocompute
        [rej info] = MARA(comp);
        MR.rej = false(1,size(comp.icaact,1));
        MR.rej(rej) = true;
        MR.info = info;
        
        comp.reject.SASICA.(strrep(rejfields{9,1},'rej','')) = MR;
        comp.reject.SASICA.(rejfields{9,1}) = MR.rej;
    else
        MR = comp.reject.SASICA.(strrep(rejfields{9,1},'rej',''));
    end
    %----------------------------------------------------------------
end

comp.reject.SASICA.var = var(comp.icaacts(:,:),[],2);% variance of each component

if (cfg.ADJUST.enable||cfg.FASTER.enable) && any(~noplot)
    h = uicontrol('style','text','string','for ADJUST or FASTER results, click on component buttons in the other window(s)','units','normalized','position',[0 0 1 .05],'backgroundcolor',get(gcf,'color'));
    uistack(h,'bottom')
end
fprintf('... Done.\n')

drawnow

%% Final computations
% combine in gcompreject field and pass to pop_selectcomps
comp.reject.gcompreject = false(1,ncomp);
for ifield = 1:size(rejfields,1)
    if rejects(ifield)
        comp.reject.gcompreject = [comp.reject.gcompreject ; comp.reject.SASICA.(rejfields{ifield})];
    end
end
comp.reject.gcompreject = sum(comp.reject.gcompreject) >= 1;

%% plotting
try
    delete(findobj('-regexp','name','pop_selectcomps'))
    drawnow
end
if any(~noplot)
    if ~isempty([comp.chanlocs.radius])% assume we have sensor locations...
        clear hfig
        delete(findobj('tag','waitcomp'))
        textprogressbar('Drawing topos...');
        if ~plotallcomp %plot only rejected comps?
            nplotcomp = sum(comp.reject.gcompreject);
            plotcomp = find(comp.reject.gcompreject);
        else
            nplotcomp = ncomp;
            plotcomp = 1:ncomp;
        end
        for ifig = 1:ceil((nplotcomp)/PLOTPERFIG)
            cmps = plotcomp([1+(ifig-1)*PLOTPERFIG:min([nplotcomp,ifig*PLOTPERFIG])]);
            ft_SASICA(comp,['pop_selectcomps(comp, [' num2str(cmps) '],' num2str(cmps(end)) ');']);
            hfig(ifig) = gcf;
            set(hfig(ifig),'name',[get(hfig(ifig),'name') ' -- SASICA ' num2str(ifig)]);
            % find the ok button and change its callback fcn
            okbutt = findobj(hfig(ifig),'string','OK');
            set(okbutt,'callback',...
                ['delete(findobj(''-regexp'',''name'',''pop_selectcomps.* -- SASICA''));delete(findobj(''-regexp'',''name'',''Automatic component rejection measures''));'...
                ]);%'warndlg({''Remember you need to now subtract the marked components.''});']);
            % find the cancel button and change its callback fcn
            cancelbutt = findobj(hfig(ifig),'string','Cancel');
            closecallback = ['try; delete(findobj(''-regexp'',''name'',''pop_selectcomps''));delete(findobj(''-regexp'',''name'',''Automatic component rejection measures''));end;'];
            set(cancelbutt,'callback',[closecallback 'comp = rmfield(comp,''reject'');disp(''Operation cancelled. No component is selected for rejection.'');']);
            set(hfig(ifig),'closerequestfcn',closecallback)
            % crazy thing to find and order the axes for the topos.
            ax{ifig} = findobj(hfig(ifig),'type','Axes');
            ax{ifig} = ax{ifig}(end-1:-1:1);% erase pointer to the big axis behind all others and reorder the axes handles.
        end;
        ax = vertcat(ax{:});
        
        if not(numel(ax) == nplotcomp) || isempty(okbutt) || ~ishandle(okbutt)
            errordlg('Please do not click while I''m drawing these topos, it''s disturbing. Start over again...')
            error('Please do not click while I''m drawing these topos, it''s disturbing. Start over again...')
        end
        
        % create markers next to each topoplot showing which threshold has been
        % passed.
        for i_comp = 1:nplotcomp
            if comp.reject.gcompreject(i_comp)
                %                 axes(ax(i_comp))
                f = get(ax(i_comp),'parent');
                set(0,'currentFigure',f);
                set(f,'CurrentAxes',ax(i_comp));
                drawnow;
                hold on
                for irej = 1:size(rejfields,1)
                    if isfield(comp.reject.SASICA,rejfields{irej,1}) && ...
                            comp.reject.SASICA.(rejfields{irej,1})(i_comp)
                        x = -.5 + (irej > 6);
                        y = .5 - .1*irej-.3*(rem(irej-1,6)+1>3);
                        h = plot(x,y,'markerfacecolor',comp.reject.SASICA.([rejfields{irej} 'col']),'markeredgecolor',comp.reject.SASICA.([rejfields{irej} 'col']),'marker','o');
                    end
                end
            end
        end
        set(hfig,'visible','on');
        try
            ft_SASICA(comp,['pop_selectcomps(comp, [' num2str(ncomp+1) ']);']);
        end
        textprogressbar;
        hlastfig = gcf;
        set(hlastfig,'name',[get(hlastfig,'name') ' -- SASICA']);
        lastax = findobj(hlastfig,'type','Axes');
        set(lastax,'visible','off');
        axes(lastax);
        hold on
        for irej = 1:numel(rejects)
            set(gca,'xlimmode','manual');
            if rejects(irej)
                x = 0;
                y = .5 - .2*irej;
                
                scatter(x,y,'markerfacecolor',comp.reject.SASICA.([rejfields{irej} 'col']),'markeredgecolor',comp.reject.SASICA.([rejfields{irej} 'col']));
                text(x+.1,y,[rejfields{irej,2} ' (' num2str(sum(comp.reject.SASICA.(rejfields{irej,1}))) ')']);
            end
        end
        for i = numel(hfig):-1:1
            figure(hfig(i));
            setctxt(hfig(i),comp,cfg);
        end
        figure(hlastfig);
    else
        disp('No channel locations. I''m not plotting.');
    end
end
if nargout == 0
    assignin('caller','comp',comp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = existnotempty(s,f)
res = isfield(s,f) && not(isempty(s.(f)));

function yticklabel(labels)

set(gca,'yticklabel',labels)

function alpha = msk2alpha(msk,m,M)

% replace in msk all 0 by m and all 1 by M
if not(islogical(msk)) || isequal(unique(msk),[0,1])
    error('Cannot deal with non binary msk')
end
alpha = msk;
alpha(alpha==0) = m;
alpha(alpha==1) = M;

function setctxt(hfig,comp,cfg)
COLREJ = '[1 0.6 0.6]';
COLACC = '[0.75 1 0.75]';
buttons = findobj(hfig,'-regexp','tag','^comp\d{1,3}$');
buttonnums = regexp(get(buttons,'tag'),'comp(\d{1,3})','tokens');
if numel(buttonnums)>1
    buttonnums = cellfun(@(x)(str2num(x{1}{1})),buttonnums);
else
    buttonnums = str2num(buttonnums{1}{1});
end
for i = 1:numel(buttonnums)
    hcmenu = uicontextmenu;
    
    if ~isempty(comp.reject.gcompreject)
        status = comp.reject.gcompreject(buttonnums(i));
    else
        status = 0;
    end;
    
    hcb1 = ['comp.reject.gcompreject(' num2str(buttonnums(i)) ') = ~comp.reject.gcompreject(' num2str(buttonnums(i)) ');'...
        'set(gco,''backgroundcolor'',fastif(comp.reject.gcompreject(' num2str(buttonnums(i)) '), ' COLREJ ',' COLACC '));'...
        'set(findobj(''tag'',''ctxt' num2str(buttonnums(i)) '''), ''Label'',fastif(comp.reject.gcompreject(' num2str(buttonnums(i)) '),''ACCEPT'',''REJECT''));' ];
    uimenu(hcmenu, 'Label', fastif(status,'ACCEPT','REJECT'), 'Callback', hcb1,'tag',['ctxt' num2str(buttonnums(i))]);
    
    mycb = strrep(get(buttons(i),'Callback'),'''','''''');
    mycb = regexprep(mycb,'pop_prop','ft_SASICA(comp,''pop_prop');
    mycb = [mycb ''');'];
    set(buttons(i),'CallBack',mycb)
    set(buttons(i),'uicontextmenu',hcmenu)
end

% pop_prop() - plot the properties of a channel or of an independent
%              component.
% Usage:
%   >> pop_prop( EEG);           % pops up a query window
%   >> pop_prop( EEG, typecomp); % pops up a query window
%   >> pop_prop( EEG, typecomp, chanorcomp, winhandle,spectopo_options);
%
% Inputs:
%   EEG        - EEGLAB dataset structure (see EEGGLOBAL)
%
% Optional inputs:
%   typecomp   - [0|1] 1 -> display channel properties
%                0 -> component properties {default: 1 = channel}
%   chanorcomp - channel or component number[s] to display {default: 1}
%
%   winhandle  - if this parameter is present or non-NaN, buttons
%                allowing the rejection of the component are drawn.
%                If non-zero, this parameter is used to back-propagate
%                the color of the rejection button.
%   spectopo_options - [cell array] optional cell arry of options for
%                the spectopo() function.
%                For example { 'freqrange' [2 50] }
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: pop_runica(), eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% hidden parameter winhandle

% 01-25-02 reformated help & license -ad
% 02-17-02 removed event index option -ad
% 03-17-02 debugging -ad & sm
% 03-18-02 text settings -ad & sm
% 03-18-02 added title -ad & sm

function pop_prop(EEG, typecomp, chanorcomp, winhandle, spec_opt)


% assumed input is chanorcomp
% -------------------------
try, icadefs;
catch,
    BACKCOLOR = [0.8 0.8 0.8];
    GUIBUTTONCOLOR   = [0.8 0.8 0.8];
end;
basename = ['Component ' int2str(chanorcomp) ];

fh = figure('name', ['pop_prop() - ' basename ' properties'], 'color', BACKCOLOR, 'numbertitle', 'off', 'visible', 'on');
pos = get(gcf,'position');
set(gcf,'Position', [pos(1) pos(2)-700+pos(4) 500 700], 'visible', 'on');
pos = get(gca,'position'); % plot relative to current axes
hh = gca;
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;
delete(gca);
p = panel();
p.margin = [10 10 10 10];
p.pack('v',{.35 []});
p(1).margin = [0 0 0 0];
p(1).pack('h',{.4 [] .01});


% plotting topoplot
p(1,1).select()
%topoplot( comp.unmixing(:,chanorcomp), comp.chanlocs, 'chaninfo', EEG.chaninfo, ...
%    'shading', 'interp', 'numcontour', 3);
cfg_topo = []; cfg_topo.layout = EEG.layout; cfg_topo.component = chanorcomp; cfg_topo.marker = 'off';
cmd = 'ft_topoplotIC(cfg_topo, EEG);';
evalc(cmd);
axis square;
title(basename, 'fontsize', 14);

% plotting erpimage
p(1,2).margin = [15 15 5 15];
p(1,2).select();
%eeglab_options;
%only continuous supported right now
if 0%EEG.trials > 1
    % put title at top of erpimage
    axis off
    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
    if EEG.trials < 6
        ei_smooth = 1;
    else
        ei_smooth = 3;
    end
    icaacttmp = eeg_getdatact(EEG, 'component', chanorcomp);
    offset = nan_mean(icaacttmp(:));
    era    = nan_mean(squeeze(icaacttmp)')-offset;
    era_limits=get_era_limits(era);
    erpimage( icaacttmp-offset, ones(1,EEG.trials)*10000, EEG.times*1000, ...
        '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp', 'yerplabel', '','erp_vltg_ticks',era_limits);
    title(sprintf('%s activity \\fontsize{10}(global offset %3.3f)', basename, offset));
else
    % put title at top of erpimage
    EI_TITLE = 'Continous data';
    ERPIMAGELINES = 200; % show 200-line erpimage
    %don't yet pass voltage data in, maybe include later
    if ~isfield(EEG,'data'),    EEG.data = cat(2,EEG.trial{:});         end
    while size(EEG.data,2) < ERPIMAGELINES*EEG.fsample
        ERPIMAGELINES = 0.9 * ERPIMAGELINES;
    end
    ERPIMAGELINES = round(ERPIMAGELINES);
    if ERPIMAGELINES > 2   % give up if data too small
        if ERPIMAGELINES < 10
            ei_smooth = 1;
        else
            ei_smooth = 3;
        end
        erpimageframes = floor(size(EEG.data,2)/ERPIMAGELINES);
        erpimageframestot = erpimageframes*ERPIMAGELINES;
        eegtimes = linspace(0, (erpimageframes)/EEG.fsample, erpimageframes-1);
        if typecomp == 1 % plot channel
            offset = nan_mean(EEG.data(chanorcomp,:));
            % Note: we don't need to worry about ERP limits, since ERPs
            % aren't visualized for continuous data
            erpimage( reshape(EEG.data(chanorcomp,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset, ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar');
        else % plot component
            icaacttmp = EEG.data(chanorcomp,:);
            offset = nanmean(icaacttmp(:));
            %erpimage(reshape(icaacttmp(:,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset,ones(1,ERPIMAGELINES)*10000, eegtimes , ...
            %    EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar','yerplabel', '');
            tmp = reshape(icaacttmp(:,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset;
            imagesc(eegtimes,1:ERPIMAGELINES,tmp);
            ylim([0 ERPIMAGELINES]);
            xlim([0 max(eegtimes)]);
            title(EI_TITLE); ylabel('Frames'); xlabel('time');
            %axis off;
        end
    else
        axis off;
        text(0.1, 0.3, [ 'No erpimage plotted' 10 'for small continuous data']);
    end;
end;

% plotting spectrum
% -----------------
if ~exist('winhandle') || isempty(winhandle) || ~ishandle(winhandle)
    winhandle = NaN;
    p(2).pack('v',{.3 [] })
else
    p(2).pack('v',{.3 [] .1})
end;
p(2,1).pack('h',{.01,[],.01});
p(2,1).margin = [15 15 0 55];
p(2,1,1).margin = 0;
p(2,1,3).margin = 0;
p(2,1,2).pack('v',{.01 []});
p(2,1,2,1).margin = 0;
p(2,1,2,2).margintop = 5;
p(2,1,2,2).select();
try
    %    spectopo( EEG.icaact(chanorcomp,:), EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,chanorcomp), spec_opt{:} );
    %periodogram(EEG.data(chanorcomp,:), [],[], EEG.fsample);
    [compspec,w] = pwelch(EEG.data(chanorcomp,:), [], [], [], EEG.fsample);
    %rescale by RMS of component map (taken from eeglab's spectopo)
    compspec = sqrt(mean(EEG.unmixing(chanorcomp,:).^4))*compspec;
    % put on db scale
    compspec = 10*log10(compspec);
    
    plot(w(w<50), smooth(compspec(w<50),length(w(w<1.2 & w>1))),'r.');
    set( get(gca, 'ylabel'), 'string', 'Power 10*log_{10}(\muV^{2}/Hz)', 'fontsize', 12);
    set( get(gca, 'xlabel'), 'string', 'Frequency (Hz)', 'fontsize', 12);
    ylim([min(compspec(w<50)), max(compspec(w<50))]);
    axis on
    xlabel('Frequency (Hz)')
    h = title('Activity power spectrum', 'fontsize', 10);
    set(h,'position',get(h,'position')+[-15 -7 0]);
    set(gca,'fontSize',10)
catch
    axis off;
    lasterror
    text(0.1, 0.3, [ 'Error: no spectrum plotted' 10 ' make sure you have the ' 10 'signal processing toolbox']);
end;

%%%% Add SASICA measures.
%               eye      muscle/noise    channel     ~ok
colors = { [0 .75 .75]      [0 0 1]      [0 .5 0] [.2 .2 .2]};
% C={[1 0 0],[.6 0 .2],[1 1 0],[0 1 0], [0 1 1]};% colors used in ADJ
computed = fieldnames(EEG.reject.SASICA);
computed = computed(regexpcell(computed,'rej|thresh|^var$','inv'));
computedthresh = regexprep(computed,'ica','icathresh');
computedrej = regexprep(computed,'ica','icarej');
toPlot = {};
toPlot_axprops = {};
toPlot_title = {}; SXticks = {};co = [];
for i = 1:numel(computed)
    if strcmp(computed{i},'icaADJUST')
        struct2ws(EEG.reject.SASICA.icaADJUST)
        toPlot{end+1}{1} = (SAD(chanorcomp)-med2_SAD)/(soglia_SAD-med2_SAD);
        toPlot{end}{2} = (SED(chanorcomp)-med2_SED)/(soglia_SED-med2_SED);
        toPlot{end}{3} = (GDSF(chanorcomp)-med2_GDSF)/(soglia_GDSF-med2_GDSF);
        toPlot{end}{4} = (nuovaV(chanorcomp)-med2_V)/(soglia_V-med2_V);
        toPlot{end}{5} = (meanK(chanorcomp)-med2_K)/(soglia_K-med2_K);
        ADJis = '';
        aco = repmat(colors{4},numel(toPlot{end}),1);
        if ismember(chanorcomp,horiz)
            ADJis = [ADJis 'HEM/'];
            aco([2 4],:) = repmat(colors{1},2,1);
        end
        if ismember(chanorcomp,vert)
            ADJis = [ADJis 'VEM/'];
            aco([1 4],:) = repmat(colors{1},2,1);
        end
        if ismember(chanorcomp,blink)
            ADJis = [ADJis 'Blink/'];
            aco([1 4 5],:) = repmat(colors{1},3,1);
        end
        if ismember(chanorcomp,disc)
            ADJis = [ADJis 'Disc/'];
            aco([3 4],:) = repmat(colors{3},2,1);
        end
        if isempty(ADJis)
            ADJis = 'OK';
        else
            ADJis(end) = [];
        end
        toPlot_title{end+1} = ['ADJUST: ' ADJis];
        toPlot_axprops{end+1} = {'ColorOrder' aco,...
            'ylim' [0 2],...
            'ytick' [1 2],...
            'yticklabel' {'Th' '2*Th'},...
            'xtick' 1:numel(toPlot{end}),...
            'xticklabel' {'SAD' 'SED' 'GDSF' 'MEV' 'TK'}};
    elseif strcmp(computed{i},'icaFASTER')
        listprops = EEG.reject.SASICA.icaFASTER.listprops;
        str='FASTER: ';
        FASTER_reasons = {'HighFreq ' 'FlatSpectrum ' 'SpatialKurtosis ' 'HurstExponent ' 'EOGCorrel '};
        %                     1 Median gradient value, for high frequency stuff
        %                     2 Mean slope around the LPF band (spectral)
        %                     3 Kurtosis of spatial map
        %                     4 Hurst exponent
        %                     5 Eyeblink correlations
        zlist = zscore(listprops);
        for i = 1:size(listprops,2)
            fst(:,i) = min_z(listprops(:,i));
        end
        reasons = FASTER_reasons(fst(chanorcomp,:));
        if isempty(reasons)
            str = [str 'OK'];
        else
            str = [str reasons{:}];
        end
        FSTis = str;
        toPlot{end+1} = {};
        for ip = 1:numel(zlist(chanorcomp,:))
            toPlot{end}{ip} = abs(zlist(chanorcomp,ip))/3;% normalized by threshold
        end
        toPlot_title{end+1} = FSTis;
        toPlot_axprops{end+1} = {'ColorOrder' [colors{2};colors{2};colors{3};colors{2};colors{1}],...
            'ylim' [0 2],...
            'ytick' [1 2],...
            'yticklabel' {'Th' '2*Th'},...
            'xtick',1:numel(toPlot{end}),...
            'xticklabel',{'MedGrad' 'SpecSl' 'SK' 'HE' 'EOGCorr'}};
    elseif strcmp(computed{i},'icaMARA')
        info = EEG.reject.SASICA.icaMARA.info;
        str='MARA: ';
        MARA_meas = {'CurrDensNorm ' 'SpatRange ' 'AvgLocSkew ' '\lambda ' '8-13 Pow' '1/F Fit '};
        %                     1 Current Density Norm
        %                     2 Spatial Range
        %                     3 Average Local Skewness
        %                     4 lambda
        %                     5 Band Power (8-13 Hz)
        %                     6 Fit Error
        if ~ EEG.reject.SASICA.icarejMARA(chanorcomp)
            str = [str 'OK       '];
        else
            str = [str 'Reject    '];
        end
        MARAis = [str '(' num2str(round(100*info.posterior_artefactprob(chanorcomp)),'%g') '%)'];
        toPlot{end+1} = {};
        for ip = 1:numel(info.normfeats(:,chanorcomp))
            toPlot{end}{ip} = info.normfeats(ip,chanorcomp) ;
        end
        toPlot_title{end+1} = MARAis;
        toPlot_axprops{end+1} = {'ColorOrder' repmat(colors{4},numel(MARA_meas),1),...
            'ylimmode' 'auto',...
            'xtick',1:numel(toPlot{end}),...
            'xticklabel',{'CDN' 'SpRg' 'AvLocSkw' 'lambda' '8-13 Hz' '1/F Fit'}
            };
    else
        rejfields = {
            'icaautocorr'       'LoAC'   colors{2}
            'icafocalcomp'      'FocCh'       colors{3}
            'icatrialfoc'       'FocTr'        colors{3}
            'icaSNR'            'LoSNR'        colors{2}
            'icaresvar'         'ResV'          colors{2}
            'icachancorrVEOG'   'CorrV'         colors{1}
            'icachancorrHEOG'   'CorrH'         colors{1}
            'icachancorrchans'  'CorrC'         colors{3}
            };
        if isempty(toPlot)
            toPlot{1} = {};
            toPlot_axprops{1} = {};
            toPlot_title{1} = 'SASICA';
        end
        switch computed{i}
            case 'icaautocorr'
                toPlot{1}{end+1} = 2 - (EEG.reject.SASICA.(computed{i})(chanorcomp) +1)/(EEG.reject.SASICA.(computedthresh{i}) +1);
            case 'icaSNR'
                toPlot{1}{end+1} = EEG.reject.SASICA.(computedthresh{i})/EEG.reject.SASICA.(computed{i})(chanorcomp);
            otherwise
                toPlot{1}{end+1} = EEG.reject.SASICA.(computed{i})(:,chanorcomp)/EEG.reject.SASICA.(computedthresh{i});
        end
        SXticks{end+1} = rejfields{strcmp(computed{i},rejfields(:,1)),2};
        co(end+1,:) = rejfields{strcmp(computed{i},rejfields(:,1)),3};
    end
end
if not(isempty(SXticks))
    toPlot_axprops{1} = {toPlot_axprops{1}{:} 'ylim' [0 2]...
        'ytick' [1 2] ...
        'yticklabel' {'Th' '2*Th'} ...
        'xtick' 1:numel(SXticks) ...
        'Xticklabel' SXticks...
        'xlim',[.5 numel(SXticks)+.5],...
        'colororder',co};
end

p(2,2).pack('v',numel(toPlot));
p(2,2).de.margintop = 0;
for i = 1:numel(toPlot)
    p(2,2,i).pack('h',{.2 []});
    p(2,2,i,1).select();
    text(1.1,0.5,strjust(strwrap(toPlot_title{i},15),'right'),'horizontalalignment','right');
    axis off
    p(2,2,i,2).select()
    hold on
    set(gca,toPlot_axprops{i}{:});
    cs = get(gca,'colorOrder');
    for j = 1:numel(toPlot{i})
        xj = linspace(j-(numel(toPlot{i}{j})>1)*.3,j+(numel(toPlot{i}{j})>1)*.3,numel(toPlot{i}{j}));
        bar(xj,toPlot{i}{j},'facecolor',cs(rem(j-1,size(cs,1))+1,:));
    end
    hline(1,':k')
end


% display buttons
% ---------------
if ishandle(winhandle)
    COLREJ = '[1 0.6 0.6]';
    COLACC = '[0.75 1 0.75]';
    % CANCEL button
    % -------------
    h  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Cancel', 'Units','Normalized','Position',[-10 -10 15 6].*s+q, 'callback', 'close(gcf);');
    
    %     % VALUE button
    %     % -------------
    %     hval  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Values', 'Units','Normalized', 'Position', [15 -10 15 6].*s+q);
    
    % REJECT button
    % -------------
    if ~isempty(EEG.reject.gcompreject)
        status = EEG.reject.gcompreject(chanorcomp);
    else
        status = 0;
    end;
    hr = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', eval(fastif(status,COLREJ,COLACC)), ...
        'string', fastif(status, 'REJECT', 'ACCEPT'), 'Units','Normalized', 'Position', [40 -10 15 6].*s+q, 'userdata', status, 'tag', 'rejstatus');
    command = [ 'set(gcbo, ''userdata'', ~get(gcbo, ''userdata''));' ...
        'if get(gcbo, ''userdata''),' ...
        '     set( gcbo, ''backgroundcolor'',' COLREJ ', ''string'', ''REJECT'');' ...
        'else ' ...
        '     set( gcbo, ''backgroundcolor'',' COLACC ', ''string'', ''ACCEPT'');' ...
        'end;' ];
    set( hr, 'callback', command);
    
    %     % HELP button
    %     % -------------
    %     h  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'HELP', 'Units','Normalized', 'Position', [65 -10 15 6].*s+q, 'callback', 'pophelp(''pop_prop'');');
    
    % OK button
    % ---------
    command = [ 'global EEG;' ...
        'tmpstatus = get( findobj(''parent'', gcbf, ''tag'', ''rejstatus''), ''userdata'');' ...
        'EEG.reject.gcompreject(' num2str(chanorcomp) ') = tmpstatus;' ];
    if winhandle ~= 0
        command = [ command ...
            sprintf('if tmpstatus set(gcbo, ''backgroundcolor'', %s); else set(gcbo, ''backgroundcolor'', %s); end;', ...
            COLREJ, COLACC) ...
            ['obj = findobj(''-regexp'',''name'',''pop_selectcomps.* -- SASICA''); obj = fastif(isempty(obj),[],findobj(obj,''tag'',''comp' num2str(chanorcomp) '''));'] ...
            sprintf('if ~isempty(obj) && tmpstatus set(obj, ''backgroundcolor'', %s); else set(obj, ''backgroundcolor'', %s); end;', ...
            COLREJ, COLACC)];
    end;
    command = [ command 'close(gcf); clear tmpstatus' ];
    h  = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'backgroundcolor', GUIBUTTONCOLOR, 'Units','Normalized', 'Position',[90 -10 15 6].*s+q, 'callback', command);
    
    %     % draw the figure for statistical values
    %     % --------------------------------------
    %     index = num2str( chanorcomp );
    %     command = [ ...
    %         'figure(''MenuBar'', ''none'', ''name'', ''Statistics of the component'', ''numbertitle'', ''off'');' ...
    %         '' ...
    %         'pos = get(gcf,''Position'');' ...
    %         'set(gcf,''Position'', [pos(1) pos(2) 340 340]);' ...
    %         'pos = get(gca,''position'');' ...
    %         'q = [pos(1) pos(2) 0 0];' ...
    %         's = [pos(3) pos(4) pos(3) pos(4)]./100;' ...
    %         'axis off;' ...
    %         ''  ...
    %         'txt1 = sprintf(''(\n' ...
    %         'Entropy of component activity\t\t%2.2f\n' ...
    %         '> Rejection threshold \t\t%2.2f\n\n' ...
    %         ' AND                 \t\t\t----\n\n' ...
    %         'Kurtosis of component activity\t\t%2.2f\n' ...
    %         '> Rejection threshold \t\t%2.2f\n\n' ...
    %         ') OR                  \t\t\t----\n\n' ...
    %         'Kurtosis distibution \t\t\t%2.2f\n' ...
    %         '> Rejection threhold\t\t\t%2.2f\n\n' ...
    %         '\n' ...
    %         'Current thesholds sujest to %s the component\n\n' ...
    %         '(after manually accepting/rejecting the component, you may recalibrate thresholds for future automatic rejection on other datasets)'',' ...
    %         'EEG.stats.compenta(' index '), EEG.reject.threshentropy, EEG.stats.compkurta(' index '), ' ...
    %         'EEG.reject.threshkurtact, EEG.stats.compkurtdist(' index '), EEG.reject.threshkurtdist, fastif(EEG.reject.gcompreject(' index '), ''REJECT'', ''ACCEPT''));' ...
    %         '' ...
    %         'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-11 4 117 100].*s+q, ''Style'', ''frame'' );' ...
    %         'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-5 5 100 95].*s+q, ''String'', txt1, ''Style'',''text'', ''HorizontalAlignment'', ''left'' );' ...
    %         'h = uicontrol(gcf, ''Style'', ''pushbutton'', ''string'', ''Close'', ''Units'',''Normalized'', ''Position'', [35 -10 25 10].*s+q, ''callback'', ''close(gcf);'');' ...
    %         'clear txt1 q s h pos;' ];
    %     set( hval, 'callback', command);
    %     if isempty( EEG.stats.compenta )
    %         set(hval, 'enable', 'off');
    %     end;
    
    com = sprintf('pop_prop( %s, %d, %d, 0, %s);', inputname(1), typecomp, chanorcomp, vararg2str( { spec_opt } ) );
else
    com = sprintf('pop_prop( %s, %d, %d, NaN, %s);', inputname(1), typecomp, chanorcomp, vararg2str( { spec_opt } ) );
end;

return;

% pop_selectcomps() - Display components with button to vizualize their
%                  properties and label them for rejection.
% Usage:
%       >> OUTEEG = pop_selectcomps( INEEG, compnum );
%
% Inputs:
%   INEEG    - Input dataset
%   compnum  - vector of component numbers
%
% Output:
%   OUTEEG - Output dataset with updated rejected components
%
% Note:
%   if the function POP_REJCOMP is ran prior to this function, some
%   fields of the EEG datasets will be present and the current function
%   will have some more button active to tune up the automatic rejection.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: pop_prop(), eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% 01-25-02 reformated help & license -ad

function [EEG, com] = pop_selectcomps( EEG, compnum, comptot );
if not(exist('comptot','var'))
    comptot = max(compnum);
end
COLREJ = '[1 0.6 0.6]';
COLACC = '[0.75 1 0.75]';
PLOTPERFIG = 35;

com = '';
if nargin < 1
    help pop_selectcomps;
    return;
end;

if nargin < 2
    promptstr = { 'Components to plot:' };
    initstr   = { [ '1:' int2str(size(EEG.icaweights,1)) ] };
    
    result = inputdlg2(promptstr, 'Reject comp. by map -- pop_selectcomps',1, initstr);
    if isempty(result), return; end;
    compnum = eval( [ '[' result{1} ']' ]);
    
    if length(compnum) > PLOTPERFIG
        ButtonName=questdlg2(strvcat(['More than ' int2str(PLOTPERFIG) ' components so'],'this function will pop-up several windows'), ...
            'Confirmation', 'Cancel', 'OK','OK');
        if ~isempty( strmatch(lower(ButtonName), 'cancel')), return; end;
    end;
    
end;
% fprintf('Drawing figure...\n');
currentfigtag = ['selcomp' num2str(rand)]; % generate a random figure tag

if length(compnum) > PLOTPERFIG
    for index = 1:PLOTPERFIG:length(compnum)
        pop_selectcomps(EEG, compnum([index:min(length(compnum),index+PLOTPERFIG-1)]));
    end;
    
    com = [ 'pop_selectcomps(' inputname(1) ', ' vararg2str(compnum) ');' ];
    return;
end;

if isempty(EEG.reject.gcompreject)
    EEG.reject.gcompreject = zeros( size(EEG.icawinv,2));
end;
try, icadefs;
catch,
    BACKCOLOR = [0.8 0.8 0.8];
    GUIBUTTONCOLOR   = [0.8 0.8 0.8];
end;

% set up the figure
% -----------------
column =ceil(sqrt( length(compnum) ))+1;
rows = ceil(length(compnum)/column);
if ~exist('fig')
    figure('name', [ 'Reject components by map - pop_selectcomps()'], 'tag', currentfigtag, ...
        'numbertitle', 'off', 'color', BACKCOLOR,'visible','off');
    set(gcf,'MenuBar', 'none');
    pos = get(gcf,'Position');
    set(gcf,'Position', [pos(1) 20 800/7*column 600/5*rows]);
    incx = 120;
    incy = 110;
    sizewx = 100/column;
    if rows > 2
        sizewy = 90/rows;
    else
        sizewy = 80/rows;
    end;
    pos = get(gca,'position'); % plot relative to current axes
    hh = gca;
    q = [pos(1) pos(2) 0 0];
    s = [pos(3) pos(4) pos(3) pos(4)]./100;
    axis off;
end;

% figure rows and columns
% -----------------------
if length(EEG.chanlocs) > 64
    %     disp('More than 64 electrodes: electrode locations not shown');
    plotelec = 0;
else
    plotelec = 1;
end;
count = 1;
for ri = compnum
    if ri > size(EEG.label,1)
        error('don''t panic')
    end
    textprogressbar(ri/comptot*100);
    if exist('fig')
        button = findobj('parent', fig, 'tag', ['comp' num2str(ri)]);
        if isempty(button)
            error( 'pop_selectcomps(): figure does not contain the component button');
        end;
    else
        button = [];
    end;
    
    if isempty( button )
        % compute coordinates
        % -------------------
        X = mod(count-1, column)/column * incx-10;
        Y = (rows-floor((count-1)/column))/rows * incy - sizewy*1.3;
        
        % plot the head
        % -------------
        if ~strcmp(get(gcf, 'tag'), currentfigtag);
            disp('Aborting plot');
            return;
        end;
        ha = axes('Units','Normalized', 'Position',[X Y sizewx sizewy].*s+q);
        cfg_topo = []; cfg_topo.layout = EEG.layout;
        cfg_topo.component = ri;
        if plotelec
            cfg_topo.marker = 'on';
        else
            cfg_topo.marker = 'off';
        end;
        cmd = 'ft_topoplotIC(cfg_topo, EEG);';
        evalc(cmd);
        
        axis square;
        
        % plot the button
        % ---------------
        button = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
            [X Y+sizewy sizewx sizewy*0.25].*s+q, 'tag', ['comp' num2str(ri)]);
        command = sprintf('pop_prop( %s, 0, %d, gcbo, { ''freqrange'', [1 50] });', inputname(1), ri); %RMC command = sprintf('pop_prop( %s, 0, %d, %3.15f, { ''freqrange'', [1 50] });', inputname(1), ri, button);
        set( button, 'callback', command );
    end;
    set( button, 'backgroundcolor', eval(fastif(EEG.reject.gcompreject(ri), COLREJ,COLACC)), 'string', int2str(ri));
    drawnow;
    count = count +1;
end;

% draw the bottom button
% ----------------------
if ~exist('fig')
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Cancel', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[-10 -10  15 sizewy*0.25].*s+q, 'callback', 'close(gcf); fprintf(''Operation cancelled\n'')' );
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Set threhsolds', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[10 -10  15 sizewy*0.25].*s+q, 'callback', 'pop_icathresh(EEG); pop_selectcomps( EEG, gcbf);' );
    %if isempty( EEG.stats.compenta	),
    set(hh, 'enable', 'off'); %end;
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'See comp. stats', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[30 -10  15 sizewy*0.25].*s+q, 'callback',  ' ' );
    %if isempty( EEG.stats.compenta	),
    set(hh, 'enable', 'off'); %end;
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'See projection', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[50 -10  15 sizewy*0.25].*s+q, 'callback', ' ', 'enable', 'off'  );
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Help', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[70 -10  15 sizewy*0.25].*s+q, 'callback', 'pophelp(''pop_selectcomps'');' );
    command = '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); eegh(''[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);''); close(gcf)';
    hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
        'Position',[90 -10  15 sizewy*0.25].*s+q, 'callback',  command);
    % sprintf(['eeg_global; if %d pop_rejepoch(%d, %d, find(EEG.reject.sigreject > 0), EEG.reject.elecreject, 0, 1);' ...
    %		' end; pop_compproj(%d,%d,1); close(gcf); eeg_retrieve(%d); eeg_updatemenu; '], rejtrials, set_in, set_out, fastif(rejtrials, set_out, set_in), set_out, set_in));
end;

com = [ 'pop_selectcomps(' inputname(1) ', ' vararg2str(compnum) ');' ];
return;

function out = nan_mean(in)

nans = find(isnan(in));
in(nans) = 0;
sums = sum(in);
nonnans = ones(size(in));
nonnans(nans) = 0;
nonnans = sum(nonnans);
nononnans = find(nonnans==0);
nonnans(nononnans) = 1;
out = sum(in)./nonnans;
out(nononnans) = NaN;


function era_limits=get_era_limits(era)
%function era_limits=get_era_limits(era)
%
% Returns the minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)
%
% Inputs:
% era - [vector] Event related activation or potential
%
% Output:
% era_limits - [min max] minimum and maximum value of an event-related
% activation/potential waveform (after rounding according to the order of
% magnitude of the ERA/ERP)

mn=min(era);
mx=max(era);
mn=orderofmag(mn)*round(mn/orderofmag(mn));
mx=orderofmag(mx)*round(mx/orderofmag(mx));
era_limits=[mn mx];


function ord=orderofmag(val)
%function ord=orderofmag(val)
%
% Returns the order of magnitude of the value of 'val' in multiples of 10
% (e.g., 10^-1, 10^0, 10^1, 10^2, etc ...)
% used for computing erpimage trial axis tick labels as an alternative for
% plotting sorting variable

val=abs(val);
if val>=1
    ord=1;
    val=floor(val/10);
    while val>=1,
        ord=ord*10;
        val=floor(val/10);
    end
    return;
else
    ord=1/10;
    val=val*10;
    while val<1,
        ord=ord/10;
        val=val*10;
    end
    return;
end

function thresh = readauto(thresh,dat,comp)
% if thresh starts with 'auto'
% compute auto threshold as mean(dat) +/- N std(dat)
% with N read in the string thresh = 'auto N'
% if not, use thresh as a value
if isstr(thresh) && strncmp(thresh,'auto',4)
    if numel(thresh) > 4
        threshsigma = str2num(thresh(5:end));
    else
        threshsigma = 2;
    end
    thresh = eval(['mean(dat,2)' comp 'threshsigma * std(dat,[],2)']);
end



function [nb,channame,strnames] = chnb(channame, varargin)

% chnb() - return channel number corresponding to channel names in an EEG
%           structure
%
% Usage:
%   >> [nb]                 = chnb(channameornb);
%   >> [nb,names]           = chnb(channameornb,...);
%   >> [nb,names,strnames]  = chnb(channameornb,...);
%   >> [nb]                 = chnb(channameornb, labels);
%
% Input:
%   channameornb  - If a string or cell array of strings, it is assumed to
%                   be (part of) the name of channels to search. Either a
%                   string with space separated channel names, or a cell
%                   array of strings.
%                   Note that regular expressions can be used to match
%                   several channels. See regexp.
%                   If only one channame pattern is given and the string
%                   'inv' is attached to it, the channels NOT matching the
%                   pattern are returned.
%   labels        - Channel names as found in {EEG.chanlocs.labels}.
%
% Output:
%   nb            - Channel numbers in labels, or in the EEG structure
%                   found in the caller workspace (i.e. where the function
%                   is called from) or in the base workspace, if no EEG
%                   structure exists in the caller workspace.
%   names         - Channel names, cell array of strings.
%   strnames      - Channel names, one line character array.
error(nargchk(1,2,nargin));
if nargin == 2
    labels = varargin{1};
else
    
    try
        comp = evalin('caller','comp');
    catch
        try
            comp = evalin('base','comp');
        catch
            error('Could not find comp structure');
        end
    end
    if not(isfield(comp,'chanlocs'))
        error('No channel list found');
    end
    comp = comp(1);
    labels = {comp.chanlocs.labels};
end
if iscell(channame) || ischar(channame)
    
    if ischar(channame) || iscellstr(channame)
        if iscellstr(channame) && numel(channame) == 1 && isempty(channame{1})
            channame = '';
        end
        tmp = regexp(channame,'(\S*) ?','tokens');
        channame = {};
        for i = 1:numel(tmp)
            if iscellstr(tmp{i}{1})
                channame{i} = tmp{i}{1}{1};
            else
                channame{i} = tmp{i}{1};
            end
        end
        if isempty(channame)
            nb = [];
            return
        end
    end
    if numel(channame) == 1 && not(isempty(strmatch('inv',channame{1})))
        cmd = 'exactinv';
        channame{1} = strrep(channame{1},'inv','');
    else
        channame{1} = channame{1};
        cmd = 'exact';
    end
    nb = regexpcell(labels,channame,[cmd 'ignorecase']);
    
elseif isnumeric(channame)
    nb = channame;
    if nb > numel(labels)
        nb = [];
    end
end
channame = labels(nb);
strnames = sprintf('%s ',channame{:});
if not(isempty(strnames))
    strnames(end) = [];
end

function idx = regexpcell(c,pat, cmds)

% idx = regexpcell(c,pat, cmds)
%
% Return indices idx of cells in c that match pattern(s) pat (regular expression).
% Pattern pat can be char or cellstr. In the later case regexpcell returns
% indexes of cells that match any pattern in pat.
%
% cmds is a string that can contain one or several of these commands:
% 'inv' return indexes that do not match the pattern.
% 'ignorecase' will use regexpi instead of regexp
% 'exact' performs an exact match (regular expression should match the whole strings in c).
% 'all' (default) returns all indices, including repeats (if several pat match a single cell in c).
% 'unique' will return unique sorted indices.
% 'intersect' will return only indices in c that match ALL the patterns in pat.
%
% v1 Maximilien Chaumon 01/05/09
% v1.1 Maximilien Chaumon 24/05/09 - added ignorecase
% v2 Maximilien Chaumon 02/03/2010 changed input method.
%       inv,ignorecase,exact,combine are replaced by cmds

error(nargchk(2,3,nargin))
if not(iscellstr(c))
    error('input c must be a cell array of strings');
end
if nargin == 2
    cmds = '';
end
if not(isempty(regexpi(cmds,'inv', 'once' )))
    inv = true;
else
    inv = false;
end
if not(isempty(regexpi(cmds,'ignorecase', 'once' )))
    ignorecase = true;
else
    ignorecase = false;
end
if not(isempty(regexpi(cmds,'exact', 'once' )))
    exact = true;
else
    exact = false;
end
if not(isempty(regexpi(cmds,'unique', 'once' )))
    combine = 2;
elseif not(isempty(regexpi(cmds,'intersect', 'once' )))
    combine = 3;
else
    combine = 1;
end

if ischar(pat)
    pat = cellstr(pat);
end

if exact
    for i_pat = 1:numel(pat)
        pat{i_pat} = ['^' pat{i_pat} '$'];
    end
end

for i_pat = 1:length(pat)
    if ignorecase
        trouv = regexpi(c,pat{i_pat}); % apply regexp on each pattern
    else
        trouv = regexp(c,pat{i_pat}); % apply regexp on each pattern
    end
    idx{i_pat} = [];
    for i = 1:numel(trouv)
        if not(isempty(trouv{i}))% if there is a match, store index
            idx{i_pat}(end+1) = i;
        end
    end
end
switch combine
    case 1
        idx = [idx{:}];
    case 2
        idx = unique([idx{:}]);
    case 3
        for i_pat = 2:length(pat)
            idx{1} = intersect(idx{1},idx{i_pat});
        end
        idx = idx{1};
end
if inv % if we want to invert result, then do so.
    others = 1:numel(trouv);
    others(idx) = [];
    idx = others;
end

function s = setdef(s,d)
% s = setdef(s,d)
% Merges the two structures s and d recursively.
% Adding the default field values from d into s when not present or empty.

if isstruct(s) && not(isempty(s))
    fields = fieldnames(d);
    for i_f = 1:numel(fields)
        if isfield(s,fields{i_f})
            s.(fields{i_f}) = setdef(s.(fields{i_f}),d.(fields{i_f}));
        else
            s.(fields{i_f}) = d.(fields{i_f});
        end
    end
elseif not(isempty(s))
    s = s;
elseif isempty(s);
    s = d;
end

function struct2ws(s,varargin)

% struct2ws(s,varargin)
%
% Description : This function returns fields of scalar structure s in the
% current workspace
% __________________________________
% Inputs :
%   s (scalar structure array) :    a structure that you want to throw in
%                                   your current workspace.
%   re (string optional) :          a regular expression. Only fields
%                                   matching re will be returned
% Outputs :
%   No output : variables are thrown directly in the caller workspace.
%
%
% _____________________________________
% See also : ws2struct ; regexp
%
% Maximilien Chaumon v1.0 02/2007


if nargin == 0
    cd('d:\Bureau\work')
    s = dir('pathdef.m');
end
if length(s) > 1
    error('Structure should be scalar.');
end
if not(isempty(varargin))
    re = varargin{1};
else
    re = '.*';
end

vars = fieldnames(s);
vmatch = regexp(vars,re);
varsmatch = [];
for i = 1:length(vmatch)
    if isempty(vmatch{i})
        continue
    end
    varsmatch(end+1) = i;
end
for i = varsmatch
    assignin('caller',vars{i},s.(vars{i}));
end

function [sortie] = ws2struct(varargin)

% [s] = ws2struct(varargin)
%
% Description : This function returns a structure containing variables
% of the current workspace.
% __________________________________
% Inputs :
%   re (string optional) :  a regular expression matching the variables to
%                           be returned.
% Outputs :
%   s (structure array) :   a structure containing all variables of the
%                           calling workspace. If re input is specified,
%                           only variables matching re are returned.
% _____________________________________
% See also : struct2ws ; regexp
%
% Maximilien Chaumon v1.0 02/2007


if not(isempty(varargin))
    re = varargin{1};
else
    re = '.*';
end

vars = evalin('caller','who');
vmatch = regexp(vars,re);
varsmatch = [];
for i = 1:length(vmatch)
    if isempty(vmatch{i}) || not(vmatch{i} == 1)
        continue
    end
    varsmatch{end+1} = vars{i};
end

for i = 1:length(varsmatch)
    dat{i} = evalin('caller',varsmatch{i});
end

sortie = cell2struct(dat,varsmatch,2);

function [tpts tvals] = timepts(timein, varargin)

% timepts() - return time points corresponding to a certain latency range
%             in an comp structure.
%
% Usage:
%   >> [tpts] = timepts(timein);
%   >> [tpts tvals] = timepts(timein, times);
%               Note: this last method also works with any type of numeric
%               data entered under times (ex. frequencies, trials...)
%
% Input:
%   timein        - latency range [start stop] (boundaries included). If
%                   second argument 'times' is not provided, comp.times will
%                   be evaluated from the comp structure found in the caller
%                   workspace (or base if not in caller).
%   times         - time vector as found in comp.times
%
% Output:
%   tpts          - index numbers corresponding to the time range.
%   tvals         - values of comp.times at points tpts
%

error(nargchk(1,2,nargin));
if nargin == 2
    times = varargin{1};
else
    
    try
        comp = evalin('caller','comp');
    catch
        try
            comp = evalin('base','comp');
        catch
            error('Could not find comp structure');
        end
    end
    if not(isfield(comp,'time'))
        error('No time list found');
    end
    times = comp.time;
    if isempty(times)
        times = comp.xmin:1/comp.fsample:comp.xmax;
    end
end
if isempty(times)
    error('could not find times');
end
if numel(timein) == 1
    [dum tpts] = min(abs(times - timein));% find the closest one
    if tpts == numel(times)
        warning('Strange time is last index of times')
    end
elseif numel(timein) == 2
    tpts = find(times >= timein(1) & times <= timein(2));% find times within bounds
else
    error('timein should be a scalar or a 2 elements vector');
end
tvals = times(tpts);


function tw = strwrap(t,n)

% tw = strwrap(t,n)
%
% wrap text array t at n characters taking non alphanumeric characters as
% breaking characters (i.e. not cutting words strangely).

t = deblank(t(:)');
seps = '[\s-]';
tw = '';
while not(isempty(t))
    breaks = regexp(t,seps);
    breaks(end+1) = numel(t);
    idx = 1:min(n,breaks(find(breaks < n, 1,'last')));
    if isempty(idx)
        idx = 1:min(n,numel(t));
    end
    tw(end+1,:) = char(padarray(double(t(idx)),[0 n-numel(idx)],32,'post'));
    t(idx)= [];
    t = strtrim(t);
end


function [z,mu,sigma] = zscore(x,flag,dim)
%ZSCORE Standardized z score.
%   Z = ZSCORE(X) returns a centered, scaled version of X, the same size as X.
%   For vector input X, Z is the vector of z-scores (X-MEAN(X)) ./ STD(X). For
%   matrix X, z-scores are computed using the mean and standard deviation
%   along each column of X.  For higher-dimensional arrays, z-scores are
%   computed using the mean and standard deviation along the first
%   non-singleton dimension.
%
%   The columns of Z have sample mean zero and sample standard deviation one
%   (unless a column of X is constant, in which case that column of Z is
%   constant at 0).
%
%   [Z,MU,SIGMA] = ZSCORE(X) also returns MEAN(X) in MU and STD(X) in SIGMA.
%
%   [...] = ZSCORE(X,1) normalizes X using STD(X,1), i.e., by computing the
%   standard deviation(s) using N rather than N-1, where N is the length of
%   the dimension along which ZSCORE works.  ZSCORE(X,0) is the same as
%   ZSCORE(X).
%
%   [...] = ZSCORE(X,FLAG,DIM) standardizes X by working along the dimension
%   DIM of X. Pass in FLAG==0 to use the default normalization by N-1, or 1
%   to use N.
%
%   See also MEAN, STD.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:18:33 $

% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
mu = mean(x,dim);
sigma = std(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);

function narginchk(min,max)

n = evalin('caller','nargin');
if  n < min || n > max
    error('number of arguments')
end
function h = vline(x,varargin)

% h = vline(x,varargin)
% add vertical line(s) on the current axes at x
% all varargin arguments are passed to plot...

x = x(:);
ho = ishold;
hold on
h = plot([x x]',repmat(ylim,numel(x),1)',varargin{:});
if not(ho)
    hold off
end
if nargout == 0
    clear h
end
function h = hline(y,varargin)

% h = hline(y,varargin)
% add horizontal line(s) on the current axes at y
% all varargin arguments are passed to plot...

y = y(:);
ho = ishold;
hold on
h = plot(repmat(xlim,numel(y),1)',[y y]',varargin{:});
if not(ho)
    hold off
end
if nargout == 0
    clear h
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% BELOW IS ADJUST CODE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ADJUST() - Automatic EEG artifact Detector
% with Joint Use of Spatial and Temporal features
%
% Usage:
%   >> [art, horiz, vert, blink, disc,...
%         soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
%         soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin]=ADJUST (EEG,out)
%
% Inputs:
%   EEG        - current dataset structure or structure array (has to be epoched)
%   out        - (string) report file name
%
% Outputs:
%   art        - List of artifacted ICs
%   horiz      - List of HEM ICs
%   vert       - List of VEM ICs
%   blink      - List of EB ICs
%   disc       - List of GD ICs
%   soglia_DV  - SVD threshold
%   diff_var   - SVD feature values
%   soglia_K   - TK threshold
%   meanK      - TK feature values
%   soglia_SED - SED threshold
%   SED        - SED feature values
%   soglia_SAD - SAD threshold
%   SAD        - SAD feature values
%   soglia_GDSF- GDSF threshold
%   GDSF       - GDSF feature values
%   soglia_V   - MEV threshold
%   nuovaV     - MEV feature values
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ADJUST
% Automatic EEG artifact Detector based on the Joint Use of Spatial and Temporal features
%
% Developed 2007-2014
% Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% Last update: 02/05/2014 by Marco Buiatti
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reference paper:
% Mognon A, Bruzzone L, Jovicich J, Buiatti M,
% ADJUST: An Automatic EEG artifact Detector based on the Joint Use of Spatial and Temporal features.
% Psychophysiology 48 (2), 229-240 (2011).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VERSIONS LOG
%
% 02/05/14: Modified text in Report.txt (MB).
%
% 30/03/14: Removed 'message to the user' (redundant). (MB)
%
% 22/03/14: kurtosis is replaced by kurt for compatibility if signal processing
%           toolbox is missing (MB).
%
% V2 (07 OCTOBER 2010) - by Andrea Mognon
% Added input 'nchannels' to compute_SAD and compute_SED_NOnorm;
% this is useful to differentiate the number of ICs (n) and the number of
% sensors (nchannels);
% bug reported by Guido Hesselman on October, 1 2010.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% function [art, horiz, vert, blink, disc,...
%         soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
%         soglia_GDSF, GDSF, soglia_V, nuovaV, soglia_D, maxdin]=ADJUST (EEG,out)
function [art, horiz, vert, blink, disc,...
    soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
    soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin]=ADJUST (comp)


%% Settings

% ----------------------------------------------------
% |  Change experimental settings in this section    |
% ----------------------------------------------------

% ----------------------------------------------------
% |  Initial message to user:                        |
% ----------------------------------------------------
%
% disp(' ')
% disp('Detects Horizontal and Vertical eye movements,')
% disp('Blinks and Discontinuities in dataset:')
% disp([EEG.filename])
% disp(' ')

% ----------------------------------------------------
% |  Collect useful data from EEG structure          |
% ----------------------------------------------------

%number of ICs=size(EEG.icawinv,1);

%number of time points=size(EEG.data,2);

% if length(size(EEG.data))==3
%
%     num_epoch=size(EEG.data,3);
%
% else
%
%     num_epoch=1;
%
% end
num_epoch = 1;
% get across epoch ICA activations
comp.icaact = cat(2,comp.trial{:});
topografie=comp.unmixing'; %computes IC topographies

% Topographies and time courses normalization
%
% disp(' ');
% disp('Normalizing topographies...')
% disp('Scaling time courses...')

for i=1:size(comp.unmixing,2) % number of ICs
    
    ScalingFactor=norm(topografie(i,:));
    
    topografie(i,:)=topografie(i,:)/ScalingFactor;
    
    comp.icaact(i,:)=ScalingFactor*comp.icaact(i,:);
    
    %     if length(size(EEG.data))==3
    %         comp.icaact(i,:,:)=ScalingFactor*EEG.icaact(i,:,:);
    %     else
    %         comp.icaact(i,:)=ScalingFactor*comp.icaact(i,:);
    %     end
    
end
%
% disp('Done.')
% disp(' ')

% Variables memorizing artifacted ICs indexes

blink=[];

horiz=[];

vert=[];

disc=[];

%% Check EEG channel position information
nopos_channels=[];
for el=1:length(comp.chanlocs)
    if(any(isempty(comp.chanlocs(1,el).X)&isempty(comp.chanlocs(1,el).Y)&isempty(comp.chanlocs(1,el).Z)&isempty(comp.chanlocs(1,el).theta)&isempty(comp.chanlocs(1,el).radius)))
        nopos_channels=[nopos_channels el];
    end;
end

if ~isempty(nopos_channels)
    disp(['Warning : Channels ' num2str(nopos_channels) ' have incomplete location information. They will NOT be used to compute ADJUST spatial features']);
    disp(' ');
end;

pos_channels=setdiff(1:length(comp.chanlocs),nopos_channels);

%% Feature extraction

disp(' ')
disp('Features Extraction:')

%GDSF - General Discontinuity Spatial Feature

disp('GDSF - General Discontinuity Spatial Feature...')

GDSF = compute_GD_feat(topografie,comp.chanlocs(1,pos_channels),size(comp.unmixing,2));


%SED - Spatial Eye Difference

disp('SED - Spatial Eye Difference...')

[SED,medie_left,medie_right]=computeSED_NOnorm(topografie,comp.chanlocs(1,pos_channels),size(comp.unmixing,2));


%SAD - Spatial Average Difference

disp('SAD - Spatial Average Difference...')

[SAD,var_front,var_back,mean_front,mean_back]=computeSAD(topografie,comp.chanlocs(1,pos_channels),size(comp.unmixing,2));


%SVD - Spatial Variance Difference between front zone and back zone

diff_var=var_front-var_back;

%epoch dynamic range, variance and kurtosis

K=zeros(num_epoch,size(comp.unmixing,2)); %kurtosis
Kloc=K;

Vmax=zeros(num_epoch,size(comp.unmixing,2)); %variance

% disp('Computing variance and kurtosis of all epochs...')

for i=1:size(comp.unmixing,2) % number of ICs
    
    for j=1:num_epoch
        Vmax(j,i)=var(comp.icaact(i,:,j));
        %         Kloc(j,i)=kurtosis(EEG.icaact(i,:,j));
        K(j,i)=kurt(comp.icaact(i,:,j));
    end
end

% check that kurt and kurtosis give the same values:
% [a,b]=max(abs(Kloc(:)-K(:)))

%TK - Temporal Kurtosis

disp('Temporal Kurtosis...')

meanK=zeros(1,size(comp.unmixing,2));

for i=1:size(comp.unmixing,2)
    if num_epoch>100
        meanK(1,i)=trim_and_mean(K(:,i));
    else meanK(1,i)=mean(K(:,i));
    end
    
end


%MEV - Maximum Epoch Variance

disp('Maximum epoch variance...')

maxvar=zeros(1,size(comp.unmixing,2));
meanvar=zeros(1,size(comp.unmixing,2));



for i=1:size(comp.unmixing,2)
    if num_epoch>100
        maxvar(1,i)=trim_and_max(Vmax(:,i)');
        meanvar(1,i)=trim_and_mean(Vmax(:,i)');
    else
        maxvar(1,i)=max(Vmax(:,i));
        meanvar(1,i)=mean(Vmax(:,i));
    end
end

% MEV in reviewed formulation:

nuovaV=maxvar./meanvar;



%% Thresholds computation

disp('Computing EM thresholds...')

% soglia_K=EM(meanK);
%
% soglia_SED=EM(SED);
%
% soglia_SAD=EM(SAD);
%
% soglia_GDSF=EM(GDSF);
%
% soglia_V=EM(nuovaV);
[soglia_K,med1_K,med2_K]=EM(meanK);

[soglia_SED,med1_SED,med2_SED]=EM(SED);

[soglia_SAD,med1_SAD,med2_SAD]=EM(SAD);

[soglia_GDSF,med1_GDSF,med2_GDSF]=EM(GDSF);

[soglia_V,med1_V,med2_V]=EM(nuovaV);



%% Horizontal eye movements (HEM)


horiz=intersect(intersect(find(SED>=soglia_SED),find(medie_left.*medie_right<0)),...
    (find(nuovaV>=soglia_V)));




%% Vertical eye movements (VEM)



vert=intersect(intersect(find(SAD>=soglia_SAD),find(medie_left.*medie_right>0)),...
    intersect(find(diff_var>0),find(nuovaV>=soglia_V)));



%% Eye Blink (EB)


blink=intersect ( intersect( find(SAD>=soglia_SAD),find(medie_left.*medie_right>0) ) ,...
    intersect ( find(meanK>=soglia_K),find(diff_var>0) ));



%% Generic Discontinuities (GD)



disc=intersect(find(GDSF>=soglia_GDSF),find(nuovaV>=soglia_V));


%compute output variable
art = nonzeros( union (union(blink,horiz) , union(vert,disc)) )'; %artifact ICs

% these three are old outputs which are no more necessary in latest ADJUST version.
soglia_D=0;
soglia_DV=0;
maxdin=zeros(1,size(comp.unmixing,2));

return

% compute_GD_feat() - Computes Generic Discontinuity spatial feature
%
% Usage:
%   >> res = compute_GD_feat(topografie,canali,num_componenti);
%
% Inputs:
%   topografie - topographies vector
%   canali     - EEG.chanlocs struct
%   num_componenti  - number of components
%
% Outputs:
%   res       - GDSF values

% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function res = compute_GD_feat(topografie,canali,num_componenti)

% Computes GDSF, discontinuity spatial feature
% topografie is the topography weights matrix
% canali is the structure EEG.chanlocs
% num_componenti is the number of ICs
% res is GDSF values

xpos=[canali.X];ypos=[canali.Y];zpos=[canali.Z];
pos=[xpos',ypos',zpos'];

res=zeros(1,num_componenti);

for ic=1:num_componenti
    
    % consider the vector topografie(ic,:)
    
    aux=[];
    
    for el=1:length(canali)-1
        
        P=pos(el,:); %position of current electrode
        d=pos-repmat(P,length(canali),1);
        %d=pos-repmat(P,62,1);
        dist=sqrt(sum((d.*d),2));
        
        [y,I]=sort(dist);
        repchas=I(2:11); % list of 10 nearest channels to el
        weightchas=exp(-y(2:11)); % respective weights, computed wrt distance
        
        aux=[aux abs(topografie(ic,el)-mean(weightchas.*topografie(ic,repchas)'))];
        % difference between el and the average of 10 neighbors
        % weighted according to weightchas
    end
    
    res(ic)=max(aux);
    
end


% computeSAD() - Computes Spatial Average Difference feature
%
% Usage:
%   >> [rapp,var_front,var_back,mean_front,mean_back]=computeSAD(topog,chanlocs,n);
%
% Inputs:
%   topog      - topographies vector
%   chanlocs   - EEG.chanlocs struct
%   n          - number of ICs
%   nchannels  - number of channels
%
% Outputs:
%   rapp       - SAD values
%   var_front  - Frontal Area variance values
%   var_back   - Posterior Area variance values
%   mean_front - Frontal Area average values
%   mean_back  - Posterior Area average values
%
%
% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function [rapp,var_front,var_back,mean_front,mean_back]=computeSAD(topog,chanlocs,n)

nchannels=length(chanlocs);

%% Define scalp zones

% Find electrodes in Frontal Area (FA)
dimfront=0; %number of FA electrodes
index1=zeros(1,nchannels); %indexes of FA electrodes

for k=1:nchannels
    if (abs(chanlocs(1,k).theta)<60) && (chanlocs(1,k).radius>0.40) %electrodes are in FA
        dimfront=dimfront+1; %count electrodes
        index1(1,dimfront)=k;
    end
end

% Find electrodes in Posterior Area (PA)
dimback=0;
index3=zeros(1,nchannels);
for h=1:nchannels
    if (abs(chanlocs(1,h).theta)>110)
        dimback=dimback+1;
        index3(1,dimback)=h;
    end
end

if dimfront*dimback==0
    disp('ERROR: no channels included in some scalp areas.')
    disp('Check channels distribution and/or change scalp areas definitions in computeSAD.m and computeSED_NOnorm.m')
    disp('ADJUST session aborted.')
    return
end

%% Outputs

rapp=zeros(1,n); % SAD
mean_front=zeros(1,n); % FA electrodes mean value
mean_back=zeros(1,n); % PA electrodes mean value
var_front=zeros(1,n); % FA electrodes variance value
var_back=zeros(1,n); % PA electrodes variance value

%% Output computation

for i=1:n % for each topography
    
    %create FA electrodes vector
    front=zeros(1,dimfront);
    for h=1:dimfront
        front(1,h)=topog(i,index1(1,h));
    end
    
    %create PA electrodes vector
    back=zeros(1,dimback);
    for h=1:dimback
        back(1,h)=topog(i,index3(1,h));
    end
    
    
    
    %compute features
    
    rapp(1,i)=abs(mean(front))-abs(mean(back)); % SAD
    mean_front(1,i)=mean(front);
    mean_back(1,i)=mean(back);
    var_back(1,i)=var(back);
    var_front(1,i)=var(front);
    
end


% computeSED_NOnorm() - Computes Spatial Eye Difference feature
% without normalization
%
% Usage:
%   >> [out,medie_left,medie_right]=computeSED_NOnorm(topog,chanlocs,n);
%
% Inputs:
%   topog      - topographies vector
%   chanlocs   - EEG.chanlocs struct
%   n          - number of ICs
%   nchannels  - number of channels
%
% Outputs:
%   out        - SED values
%   medie_left - Left Eye area average values
%   medie_right- Right Eye area average values
%
%
% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [out,medie_left,medie_right]=computeSED_NOnorm(topog,chanlocs,n)

nchannels=length(chanlocs);

%% Define scalp zones

% Find electrodes in Left Eye area (LE)
dimleft=0; %number of LE electrodes
index1=zeros(1,nchannels); %indexes of LE electrodes

for k=1:nchannels
    if (-61<chanlocs(1,k).theta) && (chanlocs(1,k).theta<-35) && (chanlocs(1,k).radius>0.30) %electrodes are in LE
        dimleft=dimleft+1; %count electrodes
        index1(1,dimleft)=k;
    end
end

% Find electrodes in Right Eye area (RE)
dimright=0; %number of RE electrodes
index2=zeros(1,nchannels); %indexes of RE electrodes
for g=1:nchannels
    if (34<chanlocs(1,g).theta) && (chanlocs(1,g).theta<61) && (chanlocs(1,g).radius>0.30) %electrodes are in RE
        dimright=dimright+1; %count electrodes
        index2(1,dimright)=g;
    end
end

% Find electrodes in Posterior Area (PA)
dimback=0;
index3=zeros(1,nchannels);
for h=1:nchannels
    if (abs(chanlocs(1,h).theta)>110)
        dimback=dimback+1;
        index3(1,dimback)=h;
    end
end

if dimleft*dimright*dimback==0
    disp('ERROR: no channels included in some scalp areas.')
    disp('Check channels distribution and/or change scalp areas definitions in computeSAD.m and computeSED_NOnorm.m')
    disp('ADJUST session aborted.')
    return
end

%% Outputs

out=zeros(1,n); %memorizes SED
medie_left=zeros(1,n); %memorizes LE mean value
medie_right=zeros(1,n); %memorizes RE mean value

%% Output computation

for i=1:n  % for each topography
    %create LE electrodes vector
    left=zeros(1,dimleft);
    for h=1:dimleft
        left(1,h)=topog(i,index1(1,h));
    end
    
    %create RE electrodes vector
    right=zeros(1,dimright);
    for h=1:dimright
        right(1,h)=topog(i,index2(1,h));
    end
    
    %create PA electrodes vector
    back=zeros(1,dimback);
    for h=1:dimback
        back(1,h)=topog(i,index3(1,h));
    end
    
    
    
    %compute features
    out1=abs(mean(left)-mean(right));
    out2=var(back);
    out(1,i)=out1; % SED not notmalized
    medie_left(1,i)=mean(left);
    medie_right(1,i)=mean(right);
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EM - ADJUST package
%
% Performs automatic threshold on the digital numbers
% of the input vector 'vec'; based on Expectation - Maximization algorithm

% Reference paper:
% Bruzzone, L., Prieto, D.F., 2000. Automatic analysis of the difference image
% for unsupervised change detection.
% IEEE Trans. Geosci. Remote Sensing 38, 1171:1182

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Usage:
%   >> [last,med1,med2,var1,var2,prior1,prior2]=EM(vec);
%
% Input: vec (row vector, to be thresholded)
%
% Outputs: last (threshold value)
%          med1,med2 (mean values of the Gaussian-distributed classes 1,2)
%          var1,var2 (variance of the Gaussian-distributed classes 1,2)
%          prior1,prior2 (prior probabilities of the Gaussian-distributed classes 1,2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function [last,med1,med2,var1,var2,prior1,prior2]=EM(vec)

if size(vec,2)>1
    len=size(vec,2); %number of elements
else
    vec=vec';
    len=size(vec,2);
end

c_FA=1; % False Alarm cost
c_MA=1; % Missed Alarm cost

med=mean(vec);
standard=std(vec);
mediana=(max(vec)+min(vec))/2;

alpha1=0.01*(max(vec)-mediana); % initialization parameter/ righthand side
alpha2=0.01*(mediana-min(vec)); % initialization parameter/ lefthand side

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPECTATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

train1=[]; % Expectation of class 1
train2=[];
train=[]; % Expectation of 'unlabeled' samples

for i=1:(len)
    if (vec(i)<(mediana-alpha2))
        train2=[train2 vec(i)];
    elseif (vec(i)>(mediana+alpha1))
        train1=[train1 vec(i)];
    else
        train=[train vec(i)];
    end
end

n1=length(train1);
n2=length(train2);

med1=mean(train1);
med2=mean(train2);
prior1=n1/(n1+n2);
prior2=n2/(n1+n2);
var1=var(train1);
var2=var(train2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAXIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count=0;
dif_med_1=1; % difference between current and previous mean
dif_med_2=1;
dif_var_1=1; % difference between current and previous variance
dif_var_2=1;
dif_prior_1=1; % difference between current and previous prior
dif_prior_2=1;
stop=0.0001;

while((dif_med_1>stop)&&(dif_med_2>stop)&&(dif_var_1>stop)&&(dif_var_2>stop)&&(dif_prior_1>stop)&&(dif_prior_2>stop))
    
    count=count+1;
    
    med1_old=med1;
    med2_old=med2;
    var1_old=var1;
    var2_old=var2;
    prior1_old=prior1;
    prior2_old=prior2;
    prior1_i=[];
    prior2_i=[];
    
    % FOLLOWING FORMULATION IS ACCORDING TO REFERENCE PAPER:
    
    for i=1:len
        prior1_i=[prior1_i prior1_old*Bayes(med1_old,var1_old,vec(i))/...
            (prior1_old*Bayes(med1_old,var1_old,vec(i))+prior2_old*Bayes(med2_old,var2_old,vec(i)))];
        prior2_i=[prior2_i prior2_old*Bayes(med2_old,var2_old,vec(i))/...
            (prior1_old*Bayes(med1_old,var1_old,vec(i))+prior2_old*Bayes(med2_old,var2_old,vec(i)))];
    end
    
    
    prior1=sum(prior1_i)/len;
    prior2=sum(prior2_i)/len;
    med1=sum(prior1_i.*vec)/(prior1*len);
    med2=sum(prior2_i.*vec)/(prior2*len);
    var1=sum(prior1_i.*((vec-med1_old).^2))/(prior1*len);
    var2=sum(prior2_i.*((vec-med2_old).^2))/(prior2*len);
    
    dif_med_1=abs(med1-med1_old);
    dif_med_2=abs(med2-med2_old);
    dif_var_1=abs(var1-var1_old);
    dif_var_2=abs(var2-var2_old);
    dif_prior_1=abs(prior1-prior1_old);
    dif_prior_2=abs(prior2-prior2_old);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THRESHOLDING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k=c_MA/c_FA;
a=(var1-var2)/2;
b= ((var2*med1)-(var1*med2));
c=(log((k*prior1*sqrt(var2))/(prior2*sqrt(var1)))*(var2*var1))+(((((med2)^2)*var1)-(((med1)^2)*var2))/2);
rad=(b^2)-(4*a*c);
if rad<0
    disp('Negative Discriminant!');
    return;
end

soglia1=(-b+sqrt(rad))/(2*a);
soglia2=(-b-sqrt(rad))/(2*a);

if ((soglia1<med2)||(soglia1>med1))
    last=soglia2;
else
    last=soglia1;
end

if isnan(last) % TO PREVENT CRASHES
    last=mediana;
end

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prob=Bayes(med,var,point)
if var==0
    prob=1;
else
    prob=((1/(sqrt(2*pi*var)))*exp((-1)*((point-med)^2)/(2*var)));
end





% trim_and_max() - Computes maximum value from vector 'vettore'
% after removing the top 1% of the values
% (to be outlier resistant)
%
% Usage:
%   >> valore=trim_and_max(vettore);
%
% Inputs:
%   vettore    - row vector
%
% Outputs:
%   valore     - result
%
%
% Author: Andrea Mognon, Center for Mind/Brain Sciences, University of
% Trento, 2009

% Motivation taken from the following comment to our paper:
% "On page 11 the authors motivate the use of the max5 function when computing
% Maximum Epoch Variance because the simple maximum would be too sensitive
% to spurious outliers. This is a good concern, however the max5 function would
% still be sensitive to spurious outliers for very large data sets. In other words, if
% the data set is large enough, one will be very likely to record more than five
% outliers. The authors should use a trimmed max function that computes the
% simple maximum after the top say .1% of the values have been removed from
% consideration. This rejection criteria scales appropriately with the size of the data
% set."

% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function valore=trim_and_max(vettore)


dim=floor(.01*size(vettore,2)); % = 1% of vector length

tmp=sort(vettore);
valore= tmp(length(vettore)-dim);



% trim_and_mean() - Computes average value from vector 'vettore'
% after removing the top .1% of the values
% (to be outlier resistant)
%
% Usage:
%   >> valore=trim_and_mean(vettore);
%
% Inputs:
%   vettore    - row vector
%
% Outputs:
%   valore     - result
%
% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function valore=trim_and_mean(vettore)


dim=floor(.01*size(vettore,2)); % = 1% of vector length

tmp=sort(vettore);
valore= mean (tmp(1:(length(vettore)-dim)));





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% END  ADJUST   CODE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   BELOW IS FASTER CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function list_properties = component_properties(EEG,blink_chans,lpf_band)

% Copyright (C) 2010 Hugh Nolan, Robert Whelan and Richard Reilly, Trinity College Dublin,
% Ireland
% nolanhu@tcd.ie, robert.whelan@tcd.ie
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


list_properties = [];
%
if isempty(EEG.topo)
    fprintf('No ICA data.\n');
    return;
end

if ~exist('lpf_band','var') || length(lpf_band)~=2 || ~any(lpf_band)
    ignore_lpf=1;
else
    ignore_lpf=0;
end

delete_activations_after=0;
if ~isfield(EEG,'icaact') || isempty(EEG.icaact)
    delete_activations_after=1;
    EEG.icaact = cat(2,EEG.trial{:});
end
try
    checkfunctionmatlab('pwelch', 'signal_toolbox')
end
for u = 1:size(EEG.icaact,1)
    [spectra(u,:) freqs] = pwelch(EEG.icaact(u,:),[],[],(EEG.fsample),EEG.fsample);
end

list_properties = zeros(size(EEG.icaact,1),5); %This 5 corresponds to number of measurements made.

for u=1:size(EEG.icaact,1)
    measure = 1;
    % TEMPORAL PROPERTIES
    
    % 1 Median gradient value, for high frequency stuff
    list_properties(u,measure) = median(diff(EEG.icaact(u,:)));
    measure = measure + 1;
    
    % 2 Mean slope around the LPF band (spectral)
    if ignore_lpf
        list_properties(u,measure) = 0;
    else
        list_properties(u,measure) = mean(diff(10*log10(spectra(u,find(freqs>=lpf_band(1),1):find(freqs<=lpf_band(2),1,'last')))));
    end
    measure = measure + 1;
    
    % SPATIAL PROPERTIES
    
    % 3 Kurtosis of spatial map (if v peaky, i.e. one or two points high
    % and everywhere else low, then it's probably noise on a single
    % channel)
    list_properties(u,measure) = kurt(EEG.unmixing(:,u));
    measure = measure + 1;
    
    % OTHER PROPERTIES
    
    % 4 Hurst exponent
    list_properties(u,measure) = hurst_exponent(EEG.icaact(u,:));
    measure = measure + 1;
    
    % 10 Eyeblink correlations
    if (exist('blink_chans','var') && ~isempty(blink_chans))
        for v = 1:length(blink_chans)
            if ~(max(EEG.data(blink_chans(v),:))==0 && min(EEG.data(blink_chans(v),:))==0);
                f = corrcoef(EEG.icaact(u,:),EEG.data(blink_chans(v),:));
                x(v) = abs(f(1,2));
            else
                x(v) = v;
            end
        end
        list_properties(u,measure) = max(x);
        measure = measure + 1;
    end
end

for u = 1:size(list_properties,2)
    list_properties(isnan(list_properties(:,u)),u)=nanmean(list_properties(:,u));
    list_properties(:,u) = list_properties(:,u) - median(list_properties(:,u));
end

if delete_activations_after
    EEG.icaact=[];
end


% The Hurst exponent
%--------------------------------------------------------------------------
% This function does dispersional analysis on a data series, then does a
% Matlab polyfit to a log-log plot to estimate the Hurst exponent of the
% series.
%
% This algorithm is far faster than a full-blown implementation of Hurst's
% algorithm.  I got the idea from a 2000 PhD dissertation by Hendrik J
% Blok, and I make no guarantees whatsoever about the rigor of this approach
% or the accuracy of results.  Use it at your own risk.
%
% Bill Davidson
% 21 Oct 2003

function [hurst] = hurst_exponent(data0)   % data set

data=data0;         % make a local copy

[M,npoints]=size(data0);

yvals=zeros(1,npoints);
xvals=zeros(1,npoints);
data2=zeros(1,npoints);

index=0;
binsize=1;

while npoints>4
    
    y=std(data);
    index=index+1;
    xvals(index)=binsize;
    yvals(index)=binsize*y;
    
    npoints=fix(npoints/2);
    binsize=binsize*2;
    for ipoints=1:npoints % average adjacent points in pairs
        data2(ipoints)=(data(2*ipoints)+data((2*ipoints)-1))*0.5;
    end
    data=data2(1:npoints);
    
end % while

xvals=xvals(1:index);
yvals=yvals(1:index);

logx=log(xvals);
logy=log(yvals);

p2=polyfit(logx,logy,1);
hurst=p2(1); % Hurst exponent is the slope of the linear fit of log-log plot

return;


function [lengths]  =  min_z(list_properties, rejection_options)
if (~exist('rejection_options', 'var'))
    rejection_options.measure = ones(1, size(list_properties, 2));
    rejection_options.z = 3*ones(1, size(list_properties, 2));
end

rejection_options.measure = logical(rejection_options.measure);
zs = list_properties - repmat(mean(list_properties, 1), size(list_properties, 1), 1);
zs = zs./repmat(std(zs, [], 1), size(list_properties, 1), 1);
zs(isnan(zs)) = 0;
all_l  =  abs(zs) > repmat(rejection_options.z, size(list_properties, 1), 1);
lengths  =  any(all_l(:, rejection_options.measure), 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   END FASTER CODE   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   BEGIN MARA CODE   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MARA() - Automatic classification of multiple artifact components
%          Classies artifactual ICs based on 6 features from the time domain,
%           the frequency domain, and the pattern
%
% Usage:
%   >> [artcomps, info] = MARA(EEG);
%
% Inputs:
%   EEG         - input EEG structure
%
% Outputs:
%   artcomps    - array containing the numbers of the artifactual
%                 components
%   info        - struct containing more information about MARA classification
%                   .posterior_artefactprob : posterior probability for each
%                            IC of being an artefact
%                   .normfeats : <6 x nIC > features computed by MARA for each IC,
%                            normalized by the training data
%                      The features are: (1) Current Density Norm, (2) Range
%                      in Pattern, (3) Local Skewness of the Time Series,
%                      (4) Lambda, (5) 8-13 Hz, (6) FitError.
%
%  For more information see:
%  I. Winkler, S. Haufe, and M. Tangermann, Automatic classification of artifactual ICA-components
%  for artifact removal in EEG signals, Behavioral and Brain Functions, 7, 2011.
%
% See also: processMARA()

% Copyright (C) 2013 Irene Winkler and Eric Waldburger
% Berlin Institute of Technology, Germany
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
function [artcomps, info] = MARA(EEG)
%%%%%%%%%%%%%%%%%%%%
%%  Calculate features from the pattern (component map)
%%%%%%%%%%%%%%%%%%%%
% extract channel labels
clab = {};
for i=1:length(EEG.chanlocs)
    clab{i} = EEG.chanlocs(i).labels;
end

% cut to channel labels common with training data
load('fv_training_MARA'); %load struct fv_tr
[clab_common i_te i_tr ] = intersect(upper(clab), upper(fv_tr.clab));
clab_common = fv_tr.clab(i_tr);
if length(clab_common) == 0
    error(['There were no matching channeldescriptions found.' , ...
        'MARA needs channel labels of the form Cz, Oz, F3, F4, Fz, etc. Aborting.'])
end
patterns = (EEG.unmixing(i_te,:));
[M100 idx] = get_M100_ADE(clab_common); %needed for Current Density Norm

disp('MARA is computing features. Please wait');
%standardize patterns
patterns = patterns./repmat(std(patterns,0,1),length(patterns(:,1)),1);

%compute current density norm
feats(1,:) = log(sqrt(sum((M100*patterns(idx,:)).^2)));
%compute spatial range
feats(2,:) = log(max(patterns) - min(patterns));

%%%%%%%%%%%%%%%%%%%%
%%  Calculate time and frequency features
%%%%%%%%%%%%%%%%%%%%
%compute time and frequency features (Current Density Norm, Range Within Pattern,
%Average Local Skewness, Band Power 8 - 13 Hz)
feats(3:6,:) = extract_time_freq_features(EEG);
disp('Features ready');


%%%%%%%%%%%%%%%%%%%%%%
%%  Adapt train features to clab
%%%%%%%%%%%%%%%%%%%%
fv_tr.pattern = fv_tr.pattern(i_tr, :);
fv_tr.pattern = fv_tr.pattern./repmat(std(fv_tr.pattern,0,1),length(fv_tr.pattern(:,1)),1);
fv_tr.x(2,:) = log(max(fv_tr.pattern) - min(fv_tr.pattern));
fv_tr.x(1,:) = log(sqrt(sum((M100 * fv_tr.pattern).^2)));

%%%%%%%%%%%%%%%%%%%%
%%  Classification
%%%%%%%%%%%%%%%%%%%%
[C, foo, posterior] = classify(feats',fv_tr.x',fv_tr.labels(1,:));
artcomps = find(C == 0)';
info.posterior_artefactprob = posterior(:, 1)';
info.normfeats = (feats - repmat(mean(fv_tr.x, 2), 1, size(feats, 2)))./ ...
    repmat(std(fv_tr.x,0, 2), 1, size(feats, 2));

function features = extract_time_freq_features(EEG)
%                             - 1st row: Average Local Skewness
%                             - 2nd row: lambda
%                             - 3rd row: Band Power 8 - 13 Hz
%                             - 4rd row: Fit Error
%
data = EEG.data(1:end-1,:,:);
fs = EEG.fsample; %sampling frequency

% transform epoched data into continous data
data = data(:,:);

%downsample (to 100-200Hz)
factor = max(floor(EEG.fsample/100),1);
data = data(:, 1:factor:end);
fs = round(fs/factor);

%compute icaactivation and standardise variance to 1
icacomps = (EEG.topo * EEG.icasphere * data)';
icacomps = icacomps./repmat(std(icacomps,0,1),length(icacomps(:,1)),1);
icacomps = icacomps';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate featues
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ic=1:size(icacomps,1)  %for each component
    fprintf('.');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Proc Spectrum for Channel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [pxx, freq] = pwelch(icacomps(ic,:), ones(1, fs), [], fs, fs);
    pxx = 10*log10(pxx * fs/2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The average log band power between 8 and 13 Hz
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = 0;
    for i = 8:13
        p = p + pxx(find(freq == i,1));
    end
    Hz8_13 = p / (13-8+1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % lambda and FitError: deviation of a component's spectrum from
    % a protoptypical 1/frequency curve
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p1.x = 2; %first point: value at 2 Hz
    p1.y = pxx(find(freq == p1.x,1));
    
    p2.x = 3; %second point: value at 3 Hz
    p2.y = pxx(find(freq == p2.x,1));
    
    %third point: local minimum in the band 5-13 Hz
    p3.y = min(pxx(find(freq == 5,1):find(freq == 13,1)));
    p3.x = freq(find(pxx == p3.y,1));
    
    %fourth point: min - 1 in band 5-13 Hz
    p4.x = p3.x - 1;
    p4.y = pxx(find(freq == p4.x,1));
    
    %fifth point: local minimum in the band 33-39 Hz
    p5.y = min(pxx(find(freq == 33,1):find(freq == 39,1)));
    p5.x = freq(find(pxx == p5.y,1));
    
    %sixth point: min + 1 in band 33-39 Hz
    p6.x = p5.x + 1;
    p6.y = pxx(find(freq == p6.x,1));
    
    pX = [p1.x; p2.x; p3.x; p4.x; p5.x; p6.x];
    pY = [p1.y; p2.y; p3.y; p4.y; p5.y; p6.y];
    
    myfun = @(x,xdata)(exp(x(1))./ xdata.^exp(x(2))) - x(3);
    xstart = [4, -2, 54];
    fittedmodel = lsqcurvefit(myfun,xstart,double(pX),double(pY), [], [], optimset('Display', 'off'));
    
    %FitError: mean squared error of the fit to the real spectrum in the band 2-40 Hz.
    ts_8to15 = freq(find(freq == 8) : find(freq == 15));
    fs_8to15 = pxx(find(freq == 8) : find(freq == 15));
    fiterror = log(norm(myfun(fittedmodel, ts_8to15)-fs_8to15)^2);
    
    %lambda: parameter of the fit
    lambda = fittedmodel(2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Averaged local skewness 15s
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    interval = 15;
    abs_local_scewness = [];
    for i=1:interval:length(icacomps(ic,:))/fs-interval
        abs_local_scewness = [abs_local_scewness, abs(skewness(icacomps(ic, i * fs:(i+interval) * fs)))];
    end
    
    if isempty(abs_local_scewness)
        error('MARA needs at least 15ms long ICs to compute its features.')
    else
        mean_abs_local_scewness_15 = log(mean(abs_local_scewness));
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Append Features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    features(:,ic)= [mean_abs_local_scewness_15, lambda, Hz8_13, fiterror];
end
disp('.');


function [M100, idx_clab_desired] = get_M100_ADE(clab_desired)
% [M100, idx_clab_desired] = get_M100_ADEC(clab_desired)
%
% IN  clab_desired - channel setup for which M100 should be calculated
% OUT M100
%     idx_clab_desired
% M100 is the matrix such that  feature = norm(M100*ica_pattern(idx_clab_desired), 'fro')
%
% (c) Stefan Haufe

lambda = 100;

load inv_matrix_icbm152; %L (forward matrix 115 x 2124 x 3), clab (channel labels)

[cl_ ia idx_clab_desired] = intersect(clab, clab_desired);
F = L(ia, :, :); %forward matrix for desired channels labels
[n_channels m foo] = size(F);  %m = 2124, number of dipole locations
F = reshape(F, n_channels, 3*m);

%H - matrix that centralizes the pattern, i.e. mean(H*pattern) = 0
H = eye(n_channels) -  ones(n_channels, n_channels)./ n_channels;
%W - inverse of the depth compensation matrix Lambda
W = sloreta_invweights(L);

L = H*F*W;

%We have inv(L'L +lambda eye(size(L'*L))* L' = L'*inv(L*L' + lambda
%eye(size(L*L')), which is easier to calculate as number of dimensions is
%much smaller

%calulate the inverse of L*L' + lambda * eye(size(L*L')
[U D] = eig(L*L');
d = diag(D);
di = d+lambda;
di = 1./di;
di(d < 1e-10) = 0;
inv1 = U*diag(di)*U';  %inv1 = inv(L*L' + lambda *eye(size(L*L'))

%get M100
M100 = L'*inv1*H;



function W = sloreta_invweights(LL)
% inverse sLORETA-based weighting
%
% Synopsis:
%   W = sloreta_invweights(LL);
%
% Arguments:
%   LL: [M N 3] leadfield tensor
%
% Returns:
%   W: [3*N 3*N] block-diagonal matrix of weights
%
% Stefan Haufe, 2007, 2008
%
% License
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see http://www.gnu.org/licenses/.

[M N NDUM]=size(LL);
L=reshape(permute(LL, [1 3 2]), M, N*NDUM);

L = L - repmat(mean(L, 1), M, 1);

T = L'*pinv(L*L');

W = spalloc(N*NDUM, N*NDUM, N*NDUM*NDUM);
for ivox = 1:N
    W(NDUM*(ivox-1)+(1:NDUM), NDUM*(ivox-1)+(1:NDUM)) = (T(NDUM*(ivox-1)+(1:NDUM), :)*L(:, NDUM*(ivox-1)+(1:NDUM)))^-.5;
end

ind = [];
for idum = 1:NDUM
    ind = [ind idum:NDUM:N*NDUM];
end
W = W(ind, ind);




function [i_te, i_tr] = findconvertedlabels(pos_3d, chanlocs)
% IN  pos_3d  - 3d-positions of training channel labels
%     chanlocs - EEG.chanlocs structure of data to be classified

%compute spherical coordinates theta and phi for the training channel
%label
[theta, phi, r] = cart2sph(pos_3d(1,:),pos_3d(2,:), pos_3d(3,:));
theta = theta - pi/2;
theta(theta < -pi) = theta(theta < -pi) + 2*pi;
theta = theta*180/pi;
phi = phi * 180/pi;
theta(find(pos_3d(1,:) == 0 & pos_3d(2,:) == 0)) = 0; %exception for Cz


clab_common = {};
i_te = [];
i_tr = [];

%For each channel in EEG.chanlocs, try to find matching channel in
%training data
for chan = 1:length(chanlocs)
    if not(isempty(chanlocs(chan).sph_phi))
        idx = find((theta <= chanlocs(chan).sph_theta + 6) ...
            & (theta >= chanlocs(chan).sph_theta - 6) ...
            & (phi <= chanlocs(chan).sph_phi + 6) ...
            & (phi >= chanlocs(chan).sph_phi - 6));
        if not(isempty(idx))
            i_tr = [i_tr, idx(1)];
            i_te = [i_te, chan];
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   END MARA CODE   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function textprogressbar(c)
% This function creates a text progress bar. It should be called with a
% STRING argument to initialize and terminate. Otherwise the number correspoding
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate
%                       Percentage number to show progress
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

%% Initialization
persistent strCR prevc strCRtitle;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

%% Main
if nargin == 0
    % Progress bar  - force termination/initialization
    fprintf('\n');
    strCR = [];
    strCRtitle = [];
    prevc = [];
elseif ischar(c)
    % Progress bar - set/reset title
    if not(isempty(strCR)) && all(strCR ~= -1)
        fprintf(strCR);
    end
    if not(isempty(strCRtitle))
        fprintf(strCRtitle);
    end
    % add trailing space if not one already
    if isempty(regexp(c,'\s$', 'once'))
        c = [c ' '];
    end
    fprintf('%s',c);
    strCR = -1;strCRtitle = repmat('\b',1,numel(c));
elseif isnumeric(c)
    % Progress bar - normal progress
    if isempty(prevc)
        prevc = 0;
    end
    c = floor(c);
    if c == prevc
        return
    else
        prevc = c;
    end
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];
    
    % Print it on the screen
    if strCR == -1,
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end
