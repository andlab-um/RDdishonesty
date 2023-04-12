%-----------------------------------------------------------------------
% Job saved on 27-Jun-2022 21:36:06 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

subjects = [104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140];
%subjects=[104];
topdir='/media/haiyanwu/HDD2/xinyi_RanDishonesty/dishonesty_fMRI/1.GLM/SPM-GLM/GLM-2/';
%1b 9; 1c 15
for num=1:3
num=num2str(num, '%04d');
sesdir=[topdir 'secondLevel/con_' num '/'];
mkdir(sesdir);
matlabbatch{1}.spm.stats.factorial_design.dir = {[sesdir]};
scans=[];
for subject=subjects
    subject = num2str(subject, '%03d');
    cd([topdir 'sub-' subject]); 
    scan1=[topdir 'sub-' subject '/con_' num '.nii'];
    %scan2=[topdir 'sub-' subject '/beta_0037.nii'];
    %scan3=[topdir 'sub-' subject '/beta_0065.nii'];
    %scan4=[topdir 'sub-' subject '/beta_0093.nii'];
    %scans=[scans; scan1; scan2; scan3; scan4];
    scans=[scans; scan1];
    cd(topdir)
end
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(scans);
%%
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;

matlabbatch{1}.spm.stats.fmri_est.spmmat = {[sesdir '/SPM.mat']};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;

matlabbatch{1}.spm.stats.con.spmmat = {[sesdir '/SPM.mat']};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = '1';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch;

end

