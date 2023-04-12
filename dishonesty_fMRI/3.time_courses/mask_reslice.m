function mask_reslice(filename, mask)
% function mask_reslice(filename, mask)
% Reslice mask into same space as image file e.g. structural
%
% SF 2015
clear matlabbatch;
f = filename;
matlabbatch{1}.spm.spatial.coreg.write.ref = {[f,',1']};
matlabbatch{1}.spm.spatial.coreg.write.source = {mask};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
disp(['Reslicing masks'])
spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);
clear matlabbatch;


% To reslice the masks you can use the attached function. 
% The first argument is a target image to get the dimensions, 
% for this you can use the first beta file in your singleTrial stats directory 
% (for any subject, as they're all normalised to the same space). 
% The second argument is your mask file. 
% It will then write out a new image with the r* prefix 
% (i.e. rdACC.nii) which is a new mask with same dimensions as your target file.