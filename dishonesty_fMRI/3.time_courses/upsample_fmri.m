% Bang & Fleming (2018) Distinct encoding of decision confidence in human
% medial prefrontal cortex
%
% Pseudo-script for upsamling fMRI activity for single-trial analysis
%
% We here assume that the same mask is used for all subjects 
% (e.g. anatomically defined ROI)
%
% Dan Bang danbang.db@gmail.com 2018

%
% Dishonesty
% adapted from Bang & Fleming (2018) Distinct encoding of decision confidence in human
% fmri time course upsampling
% Xinyi Julia Xu, 2022.11.11
% xinyi_x@outlook.com


%% -----------------------------------------------------------------------
%% PREPARATION

% fresh memory
clear;

% Subjects
subjects = [104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140];;

%% Current directory;
cwd = pwd;

%% Scan parameters
n_runs      = 3;    % number of functional runs
TR          = 1;
n_motion    = 18;   % motion covariates

%% Upsample information
uinfo.samp_reso     = .144;                  % sample resolution in miliseconds
uinfo.samp_rate     = uinfo.samp_reso./TR;   % sample rate
uinfo.window_length = 12;                    % time window in seconds from onset

%% Mask information
% minfo.name = {'BA24','dacc','ANG','dlPFC','BA6','BA32','BA23','BA21','mPFC','vmPFC','BA13'};
% minfo.file = {'Mask_BA24.nii','Mask_dacc.nii','Mask_ANG.nii','Mask_dlPFC.nii','Mask_BA6.nii','Mask_BA32.nii','Mask_BA23.nii','Mask_BA21.nii','Mask_mPFC.nii','Mask_vmPFC.nii','Mask_BA13.nii'};
minfo.name = {'OFC','rewant_z10'};
minfo.file = {'Mask_OFC.nii','Mask_rewant_z10.nii'};

% Paths [change 'repoBase' according to local setup]
fs = filesep;
dirEPI = '/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/prep/fmriprep';
dirMasks = '/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/2.ROIextraction/masks';
dirCf='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/1.GLM/confound_files';
dirEv='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/1.GLM/event_files';
%% -----------------------------------------------------------------------
%% UPSAMPLE

%% Loop through ROIs
for i_roi = 1:length(minfo.file);
%for i_roi = 1;
    
    %% Starting ROI
    fprintf(['===== Upsampling activity for ',minfo.name{i_roi},' ===== \n']);
        
    %% Clear variable for storage
    clear time_series;    
    
    % get and check mask (if different dimensions, use mask_reslice.m)
    %% Load masks
    mask_path = [dirMasks,fs,minfo.file{i_roi}];
    new_mask_path = [dirMasks,fs,'r',minfo.file{i_roi}];
        
    ref='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/prep/fmriprep/sub-011/ses-1/func/sub-011_ses-1_task-dishonesty1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';
    if isfile(new_mask_path)==0;
        
        mask_reslice(ref,mask_path);
    end
    Vmask   = spm_vol(deblank(new_mask_path));
    mask    = spm_read_vols(Vmask);

    %% loop through subjects
    for i_sbj = 1:length(subjects);
        
        sbj=num2str(subjects(i_sbj)-100, '%03d');
        
        
        
        %% Initialise variable for storage
        time_series = [];
        
        
        %% Loop through runs'r'
        for i_run = 1:n_runs;
%        for i_run = 1;
            
            %% Load data with time logs
            data = importdata([dirEv,fs,'sub-',num2str(subjects(i_sbj)),'/sub-',num2str(subjects(i_sbj)),'_ses-',num2str(i_run),'_task-dishonesty',num2str(i_run),'_bold.tsv']);
            trialOnsets = data.textdata(2:end,10); % specify trial onsets (e.g. 1 second before stimulus onset)
            
            %% Scans
            % clear variables
            clear ts M R
            %%
            
            % data directory
            epiDir = [dirEPI,fs,'sub-',sbj,fs,'ses-',num2str(i_run),fs,'func'];
            % select scans and concatenate
          
            temp =[epiDir '/sub-' sbj '_ses-',num2str(i_run),'_task-dishonesty',num2str(i_run),'_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'];
           
            % get scans
            V = spm_vol(temp);
            %%
            
            %%
            if sum(V(1).dim == Vmask.dim) ~= 3; error('mask and images have different dimensions'); end
            %% get time series
            for i = 1:length(V)
                img = spm_read_vols(V(i));
                dat = img(mask > 0);
                ts(i) = nanmean(dat(:));
            end
            %% remove confounds
            % scan specs for cosine basis set
            params.nscan    = length(V);
            params.nsess    = 1;
            params.tr       = TR;  
            %%
            % motion covariates + derivatives
            mCorrFile = [dirCf fs 'sub-' sbj fs 'ses-' num2str(i_run) fs 'sub-' sbj '_ses-' num2str(i_run) '_confound.txt'];
            M         = importdata(mCorrFile);
            R         = [M [zeros(1,18); diff(M)]];
            %%
            % execute removal
            ts = ts(:);  % column vector must be entered into remove_confounds
            ts = remove_confounds(ts, R, params);
            ts = ts(:)'; % row vector for the future
            %%
            % re-sample and average timeseries at specified sample rate
            t      = 0:length(ts)-1;
            t_ups  = 0:uinfo.samp_rate:length(ts)-1;
            ts_ups = spline(t,ts,t_ups);    % interpolates time series
            %%
            % create trial-by-time series matrix for each scan run
            time_series_run=zeros(60,86);
            
            for i_trial = 1:length(trialOnsets);
            
                win_min  = ceil(str2num(trialOnsets{i_trial,1})./uinfo.samp_reso)+1;       % window start in miliseconds
                win_max  = ceil(win_min+uinfo.window_length./uinfo.samp_reso); % window end in miliseconds
                if (size(ts_ups,2)-win_max)>0
                c_ts_ups = ts_ups(win_min:win_max);
                else 
                c_ts_ups = NaN(1,(win_max-win_min)+1);
                end
                time_series_run(i_trial,1:end-1) = c_ts_ups; % update
                time_series_run(i_trial,end)=i_run;
            end
            
            %%
            % concatenate run time series
            time_series = [time_series; time_series_run];
    
        end

        %% log subject data
        roi{i_roi}.time_series{i_sbj} = time_series;
          
    end
   
end

%% save output
save('upsampled_frmi_OFC_rewant_z10','roi','uinfo','minfo');
