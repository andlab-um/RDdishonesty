
%subjects = [104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140];
%subjects =[105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140];
subjects=[121,122];
evpath='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/1.GLM/event_files/';
fprep_dir='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/prep/fmriprep/';
cfdir='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/1.GLM/confound_files/';
glmdir='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/1.GLM/SPM-GLM/GLM-1b/';
%%
for subject=subjects
subj=num2str(subject-100, '%03d');
subject = num2str(subject, '%03d');

fprintf('processing subj %s',subject)
cd([evpath 'sub-' subject]);   
 
data_lie_run1 = load(['lie_run1.txt']);
data_lie_run2 = load(['lie_run2.txt']);
data_lie_run3 = load(['lie_run3.txt']);


data_hon_run1 = load(['hon_run1.txt']);
data_hon_run2 = load(['hon_run2.txt']);
data_hon_run3 = load(['hon_run3.txt']);

cd(fprep_dir);

func1_nii=['sub-' subj '/ses-1/func/sub-' subj '_ses-1_preproc_smoothed4_masked.nii'];
func2_nii=['sub-' subj '/ses-2/func/sub-' subj '_ses-2_preproc_smoothed4_masked.nii'];
func3_nii=['sub-' subj '/ses-3/func/sub-' subj '_ses-3_preproc_smoothed4_masked.nii'];

run1_scans = spm_select('Expand',func1_nii);
run2_scans = spm_select('Expand',func2_nii);
run3_scans = spm_select('Expand',func3_nii);

mkdir([glmdir 'sub-' subject]);


%-----------------------------------------------------------------------
% Job saved on 06-Oct-2022 15:51:42 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear matlabbatch;
matlabbatch{1}.spm.stats.fmri_spec.dir = {[glmdir 'sub-' subject]};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(run1_scans);


matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'lie';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = data_lie_run1(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = data_lie_run1(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod.name = 'RT';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod.param = data_lie_run1(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;


matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'hon';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = data_hon_run1(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = data_hon_run1(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod.name = 'RT';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod.param = data_hon_run1(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;

matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {[cfdir 'sub-' subj '/ses-1/sub-' subj '_ses-1_confound.txt']};
matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;



matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(run2_scans);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).name = 'lie';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).onset = data_lie_run2(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).duration = data_lie_run2(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod.name = 'RT';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod.param = data_lie_run2(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).orth = 1;

matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).name = 'hon';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).onset = data_hon_run2(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).duration = data_hon_run2(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).pmod.name = 'RT';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).pmod.param = data_hon_run2(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).orth = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {[cfdir 'sub-' subj '/ses-2/sub-' subj '_ses-2_confound.txt']};
matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;



matlabbatch{1}.spm.stats.fmri_spec.sess(3).scans = cellstr(run3_scans);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).name = 'lie';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).onset = data_lie_run3(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).duration = data_lie_run3(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).pmod.name = 'RT';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).pmod.param = data_lie_run3(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).orth = 1;

matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).name = 'hon';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).onset = data_hon_run3(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).duration = data_hon_run3(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).pmod.name = 'RT';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).pmod.param = data_hon_run3(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).orth = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi_reg = {[cfdir 'sub-' subj '/ses-3/sub-' subj '_ses-3_confound.txt']};
matlabbatch{1}.spm.stats.fmri_spec.sess(3).hpf = 128;



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



matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'lie1';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'hon1';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'lie-hon1';







for i=1:2
matlabbatch{1}.spm.stats.con.consess{i}.tcon.weights = [zeros(1,i-1) 1];
matlabbatch{1}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
end
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [1 0 -1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'lie2';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [zeros(1,22) 1];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'hon2';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [zeros(1,24) 1];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'lie-hon2';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [zeros(1,22) 1 0 -1];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';




matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'lie3';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [zeros(1,44) 1];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'hon3';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [zeros(1,46) 1];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';


matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'lie-hon3';
matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [zeros(1,44) 1 0 -1];
matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';



matlabbatch{1}.spm.stats.con.delete = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;


end

