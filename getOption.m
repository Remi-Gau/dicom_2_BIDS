function opt = getOption

%% Set directories
% fullpath of the spm 12 folder: 
% opt.spm_path = '/home/remi-gau/Documents/SPM/spm12';
opt.spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';
% if already in the path put uncomment the following line
% opt.spm_path = spm('dir')

% fullpaths
opt.src_dir = 'D:\BIDS\ceren\source'; % source folder
opt.tgt_dir = 'D:\BIDS\ceren\raw'; % target folder
opt.onset_files_dir = '';


%% Parameters definitions
% select what to convert and transfer
opt.do_anat = 0;
opt.do_func = 1;
opt.do_dwi = 0;


opt.zip_output = 0; % 1 to zip the output into .nii.gz (not ideal for
% SPM users)
opt.delete_json = 1; % in case you have already created the json files in
% another way (or you have already put some in the root folder)
opt.do = 1; % actually convert DICOMS, can be usefull to set to false
% if only events files or something similar must be created


% DICOM folder patterns to look for
opt.subject_dir_pattern = {...
    ''};

opt.subject_tgt_pattern = {...
    ''};

opt.subj_ls = {
    'AnBa'; ...
    'AnDe'; ...
    'AnPa'; ...
    'ArRa'};



%% Details for ANAT
% target folders to convert
opt.src_anat_dir_patterns = {
    ''};

% corresponding names for the output file in BIDS data set
opt.tgt_anat_dir_patterns = {
    '_T1w'};


%% Details for FUNC
opt.src_func_dir_patterns = {
    'lnif_epi1_333.*DiCo'};
opt.task_name = {...
    'olfid'};
opt.get_onset = [...
    0];
opt.get_stim = [...
    0];

opt.nb_folder = [...
    12];

opt.stim_patterns = {...
    ''};
opt.events_patterns = {...
    ''};
opt.events_src_file = {...
    []};

opt.nb_dummies = 8; %9 MAX!!!!


%% Details for DWI
% target folders to convert
opt.src_dwi_dir_patterns = {...
    ''};
% corresponding names for the output file in BIDS data set
opt.tgt_dwi_dir_patterns = {
    ''};
% take care of eventual bval bvec values
opt.bvecval = [...
    0];


%% option for json writing
opt.indent = '    ';


end