
%
% Dishonesty
% adapted from Bang et al (2021) Neurocomputational mechanisms of confidence in self and
% other
% time courses of betas
% Xinyi Julia Xu, 2022.11.11
% xinyi_x@outlook.com

%% -----------------------------------------------------------------------
%% PREPARATION

% Fresh memory
clear; close all;
load('upsampled_frmi.mat');
% Paths [change 'repoBase' according to local setup]
fs= filesep;
repoBase='/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_fMRI';
dirEv= [repoBase,fs,'1.GLM/event_files'];

dirFigures= [repoBase,fs,'3.time_courses/figs'];

% Add paths
addpath('Functions');

% ROIs
roi_v={'BA24','dacc','ANG','dlPFC','BA6','BA32','BA23','BA21','mPFC','vmPFC','BA13'};
%roi_v= {'OFC','rewant_z10'};
cWindow= 'dec'; % time window (dec: decision; gam: gamble)

% Subjects
sbj_v= [104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140]; % subject numbers


%% -----------------------------------------------------------------------
%% TIME COURSE

% loop through ROIs
for i_roi = 1:length(roi_v)
%for i_roi = 1
% initialise subject index
k = 1;

% loop through subjects
for i_sbj = 1:length(sbj_v)
%for i_sbj = 1:3
    for i_run=3

        
        % update subject index
        k=k+1;
        %%
        % load behavioural data
        data = importdata([dirEv,fs,'sub-',num2str(sbj_v(i_sbj)),'/sub-',num2str(sbj_v(i_sbj)),'_ses-',num2str(i_run),'_task-dishonesty',num2str(i_run),'_bold.tsv']);
        trialOnsets = data.textdata(2:end,10); % specify trial onsets (e.g. 1 second before stimulus onset)
        lie = data.data(:,12);
        mon=data.data(:,11);
        con=data.data(:,10);
        valid=length(lie);
        
        %%        



        % load neural data
        
        roi_ts = roi{1,i_roi}.time_series{1,i_sbj};
        valid_roi_ts=roi_ts(i_run*60-59:valid+i_run*60-60,1:end-1);
        % select non-NaN trials
        nonans = ~isnan(valid_roi_ts(:,end));
        %%
        % UP-SAMPLED GLM
        % Full
        idx = find(nonans==1);
        roi_Zts = zscore(valid_roi_ts(idx,:));
        roi_Zts = valid_roi_ts(idx,:);
        
        lie_val= (lie(idx)==1);
        %coh= zscore(data.theta(idx));
        t= 0;
%         %%
%         for j= 1:size(valid_roi_ts,2)
%             t= t+1;
%             x= [lie_val]';
%             y= roi_Zts(:,j);
%             beta= glmfit(x,y,'normal');
%             if i_run==1;
%                 beta_ts1{i_roi}.lie_val(i_sbj,t) = beta(end-0);
%             end
%             if i_run==2;
%                 beta_ts2{i_roi}.lie_val(i_sbj,t) = beta(end-0);
%             end
%             if i_run==3;
%                 beta_ts3{i_roi}.lie_val(i_sbj,t) = beta(end-0);
%             end            
%         end
%         %%
        % money and consis
   
        %con_val= zscore(con(idx));
        %mon_val= zscore(mon(idx));
        con_val= con(idx);
        mon_val= mon(idx);
        t= 0;
        %%
        for j= 1:size(valid_roi_ts,2)
            t= t+1;
            x= [(con_val)'; (mon_val)'; (con_val.*mon_val)']';
            %x_con= [lie_val'; con_val'; (con_val.*lie_val)']';
            %x_mon= [lie_val'; mon_val'; (mon_val.*lie_val)']';
            y= roi_Zts(:,j);
            beta= glmfit(x,y,'normal');
            
            if i_run==1;
                beta_ts1{i_roi}.lie_val(i_sbj,t) = beta(end-3);
            end
            if i_run==2;
                beta_ts2{i_roi}.lie_val(i_sbj,t) = beta(end-3);
            end
            if i_run==3;
                %beta_ts3{i_roi}.lie_val(i_sbj,t) = beta(end-2);
                beta_ts{i_roi}.int_val(i_sbj,t) = beta(end-0);
                beta_ts{i_roi}.mon_val(i_sbj,t) = beta(end-1);
                beta_ts{i_roi}.con_val(i_sbj,t) = beta(end-2);
                
            end            
            


            %beta_con=glmfit(x_con,y,'normal');
            %beta_mon=glmfit(x_mon,y,'normal');
            %beta_ts{i_roi}.con_val(i_sbj,t) = beta_con(end-0);
            %beta_ts{i_roi}.mon_val(i_sbj,t) = beta_mon(end-0);
        end
        
        
    end
end
end

%% -----------------------------------------------------------------------
%% VISUALISATION

%% General specifications
ccol= [98 142 72]./255;%green
mcol= [122 51 176]./255;
col_1= [0 1 1];
col_2= [0 1 0];
col_3= [1 0 1];
axisFS= 28;
labelFS= 40;
lw= 4;
max_t = 99; % index for max time
srate = .144; % sampling rate in seconds

%% FIGURE
% loop through ROIs
for i_roi= 1:length(roi_v);  
    % data
    %%
    %liebeta= beta_ts{i_roi}.lie_val;
    conbeta= beta_ts{i_roi}.con_val;
    monbeta= beta_ts{i_roi}.mon_val;
    intbeta= beta_ts{i_roi}.int_val;
    %liebeta1= beta_ts1{i_roi}.lie_val;
    %liebeta2= beta_ts2{i_roi}.lie_val;
    %liebeta3= beta_ts3{i_roi}.lie_val;
    %%
    % create figure
    figz=figure('color',[1 1 1]);
    % add reference lines
    %plot([1/srate 1/srate],[-.25 +.25],'k-','LineWidth',lw/2); hold on
    %plot([2.5/srate 2.5/srate],[-1 +1],'k-','LineWidth',lw/2); hold on
    plot([0 max_t],[0 0],'k-','LineWidth',lw); hold on
    % plot beta time series
    %%
    fillsteplotcol(conbeta,lw,'-',ccol); hold on
    fillsteplotcol(monbeta,lw,'-',mcol); hold on
    fillsteplotcol(intbeta,lw,'-',' black'); hold on
%     fillsteplotcol(liebeta1,lw,'-',col_1); hold on
%     fillsteplotcol(liebeta2,lw,'-',col_2); hold on
%     fillsteplotcol(liebeta3,lw,'-',col_3); hold on
    
    
    %%
    % tidy up
    %ylim([-.3 .3]);
    %set(gca,'YTick',-.25:.05:.25);
    xlim([1 56]);
    set(gca,'XTick',[1 14 28 42 56])
    set(gca,'XTickLabel',{'0','2','4','6','8'})
    box('off')
    set(gca,'FontSize',axisFS,'LineWidth',lw);
    %set(gcf,'position',[0,0,800,600]);
    xlabel('time [seconds]','FontSize',labelFS,'FontWeight','normal');
    ylabel('beta [arb. units]','FontSize',labelFS,'FontWeight','normal');
    %%
    print('-djpeg','-r300',['figs(2attributes)',fs,'attributes_',roi_v{i_roi}]);    
end

% %% FIGURE
% % loop through ROIs
% for i_roi= 1:length(roi_v);  
%     % data
%     %%
%     liebeta1= beta_ts1{i_roi}.lie_val;
%     liebeta2= beta_ts2{i_roi}.lie_val;
%     liebeta3= beta_ts3{i_roi}.lie_val;
%     
%     %%
%     % create figure
%     figz=figure('color',[1 1 1]);
%     % add reference lines
%     %plot([1/srate 1/srate],[-1 +1],'k-','LineWidth',lw/2); hold on
%     %plot([2.5/srate 2.5/srate],[-1 +1],'k-','LineWidth',lw/2); hold on
%     plot([0 max_t],[0 0],'k-','LineWidth',lw); hold on
%     % plot beta time series
%     %%
%     fillsteplotcol(liebeta1,lw,'-',col_1); hold on
%     fillsteplotcol(liebeta2,lw,'-',col_2); hold on
%     fillsteplotcol(liebeta3,lw,'-',col_3); hold on
%   
%     %%
%     % tidy up
%     %ylim([-.54 .54]);
%     %set(gca,'YTick',-.4:.2:.4);
%     xlim([1 84]);
%     set(gca,'XTick',[1 14 28 42 56 70 84])
%     set(gca,'XTickLabel',{'0','2','4','6','8','10','12'})
%     box('off')
%     set(gca,'FontSize',axisFS,'LineWidth',lw);
%     xlabel('time [seconds]','FontSize',labelFS,'FontWeight','normal');
%     ylabel('beta [arb. units]','FontSize',labelFS,'FontWeight','normal');
%     %%
%     print('-djpeg','-r300',['figs',fs,'session_',roi_v{i_roi}]);    
% end
