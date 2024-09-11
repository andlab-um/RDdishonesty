
%%
subjList = [104,105,106,108,109,110,111,112,113,114,115,117,118,119,120,121,122,123,124,125,126,127,128,130,131,132,133,134,135,136,137,138,139,140];


topdir='/home/haiyanwu/nas_data/experiment_data/RDonly240615/';

fprep_dir=[topdir 'prep/fmriprep/'];
cfdir=[topdir '1.GLM/confound_files/'];
glmdir=[topdir '1.GLM/results/GLM1_spm/'];

alldata=readtable([topdir '2.RDhddm/filtered_summary240104.csv']);
alldata=alldata(:,{'sub_nr','trial_begin','ses','run','RT','AUC'});

exdata=readtable([topdir '2.RDhddm/behav_summary240104.csv']);
exdata=exdata(:,{'sub_nr','trial_begin','ses','run','RT'});
exdata=exdata((exdata.RT==-1),:);


%%
for subj=subjList

subject = num2str(subj-100, '%03d');
fprintf('processing subj %s',subject)
% 
% 
subdata = alldata((alldata.sub_nr==subj),:);
exsubdata = exdata((exdata.sub_nr==subj),:);
d{1} = subdata((subdata.run==1),:);
d{2} = subdata((subdata.run==2),:);
d{3} = subdata((subdata.run==3),:);
d{4} = subdata((subdata.run==4),:);
d{5} = subdata((subdata.run==5),:);
d{6} = subdata((subdata.run==6),:);
d{7} = subdata((subdata.run==7),:);
if subj==104
    d{7}=d{7}(2:20,:);%for 104
end
d{8} = subdata((subdata.run==8),:);
d{9} = subdata((subdata.run==9),:);
%%
 

%%
cd(fprep_dir);

func1_nii=['sub-' subject '/ses-1/func/sub-' subject '_ses-1_preproc_smoothed4_masked.nii'];
func2_nii=['sub-' subject '/ses-2/func/sub-' subject '_ses-2_preproc_smoothed4_masked.nii'];
func3_nii=['sub-' subject '/ses-3/func/sub-' subject '_ses-3_preproc_smoothed4_masked.nii'];

run1_scans = spm_select('Expand',func1_nii);
run2_scans = spm_select('Expand',func2_nii);
run3_scans = spm_select('Expand',func3_nii);

%%
scans{1}=run1_scans;
scans{2}=run2_scans;
scans{3}=run3_scans;


mkdir([glmdir 'sub-' subject]);
%-----------------------------------------------------------------------
% Job saved on 27-Jun-2022 09:54:42 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear matlabbatch;
matlabbatch{1}.spm.stats.fmri_spec.dir = {[glmdir 'sub-' subject]};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
%%
for sesno=1:3

matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).scans = cellstr(scans{sesno});
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).name = 'one';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).onset = d{3*sesno-2}.trial_begin(:)-min(d{3*sesno-2}{:,'trial_begin'});;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).duration = d{3*sesno-2}.RT(:);
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).pmod(1).name = 'AUC1';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).pmod(1).param = d{3*sesno-2}.AUC(:);
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).pmod(1).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(1).orth = 1;


matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).name = 'two';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).onset = d{3*sesno-1}.trial_begin(:)-min(d{3*sesno-2}{:,'trial_begin'});;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).duration = d{3*sesno-1}.RT(:);
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).pmod(1).name = 'AUC2';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).pmod(1).param=d{3*sesno-1}.AUC(:);
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).pmod(1).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(2).orth = 1;


matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).name = 'three';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).onset = d{3*sesno}.trial_begin(:)-min(d{3*sesno-2}{:,'trial_begin'});;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).duration = d{3*sesno}.RT(:);
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).pmod(1).name = 'AUC3';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).pmod(1).param=d{3*sesno}.AUC(:);
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).pmod(1).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(3).orth = 1;


if size(exsubdata(exsubdata.ses==sesno,:),1)~=0
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(4).name = 'ex';
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(4).onset = exsubdata(exsubdata.ses==sesno,:).trial_begin(:)-min(d{3*sesno-2}{:,'trial_begin'});;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(4).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(4).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(4).pmod = struct('name', {},'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).cond(4).orth = 1;
end


matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).multi_reg = {[cfdir 'sub-' subject '/ses-' num2str(sesno) '/sub-' subject '_ses-' num2str(sesno) '_confound.txt']};
matlabbatch{1}.spm.stats.fmri_spec.sess(sesno).hpf = 128;


end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;

matlabbatch{1}.spm.stats.fmri_est.spmmat = {[glmdir 'sub-' subject '/SPM.mat']};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;

matlabbatch{1}.spm.stats.con.spmmat = {[glmdir 'sub-' subject '/SPM.mat']};
SPMmat=load([glmdir 'sub-' subject '/SPM.mat']);


matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'one';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'both';


matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'two';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'both';


matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'three';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'both';


matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = ['AUC1'];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 1];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'both';

matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = ['AUC2'];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'both';


matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = ['AUC3'];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'both';  

matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = ['AUC'];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = double(~cellfun('isempty',strfind(SPMmat.SPM.xX.name(:),'AUC'))).';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';  



matlabbatch{1}.spm.stats.con.delete = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;



end
