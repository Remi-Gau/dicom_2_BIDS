% gets all the T1w of a BIDS data set and defaces them with SPM12
% assumes files are unzipped

clear 
clc

spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';
tgt_dir = 'D:\olf_blind\raw';

addpath(spm_path)

BIDS = spm_BIDS(tgt_dir);

anat_file_ls = spm_BIDS(BIDS,'data', 'type', 'T1w')

for i_file = 1:size(anat_file_ls, 1)
    
    % set up batch and run it
    matlabbatch{1}.spm.util.deface.images = anat_file_ls(i_file); %#ok<*SAGROW>
    spm_jobman('run', matlabbatch);
    
    % delete original file
    delete(anat_file_ls{i_file})

    % rename the defaced file
    [path, file, ext] = spm_fileparts(anat_file_ls{i_file});
    movefile(...
        fullfile(path, ['anon_' file ext]), ...
        anat_file_ls{i_file})

end
