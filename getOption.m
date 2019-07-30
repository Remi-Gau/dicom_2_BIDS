function opt = getOption


%% Set directories
% fullpath of the spm 12 folder:
% opt.spm_path = '/home/remi-gau/Documents/SPM/spm12';
opt.spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';
% if already in the path put uncomment the following line
% opt.spm_path = spm('dir')

% fullpaths
opt.src_dir = 'D:\Dropbox\BIDS\olf_blind\source\DICOM'; % source folder
opt.tgt_dir = 'D:\Dropbox\BIDS\olf_blind\source\raw'; % target folder
opt.onset_files_dir = 'D:\Dropbox\BIDS\olf_blind\source\Results';


%% Parameters definitions
% select what to convert and transfer
opt.do_anat = 1;
opt.do_func = 0;
opt.do_dwi = 0;


opt.zip_output = 0; % 1 to zip the output into .nii.gz (not ideal for
% SPM users)
opt.delete_json = 1; % in case you have already created the json files in
% another way (or you have already put some in the root folder)
opt.do = 1; % actually convert DICOMS, can be usefull to set to false
% if only events files or something similar must be created


% DICOM folder patterns to look for: one pattern per group
opt.subject_dir_pattern = {...
    'Olf_Blind_C*'; ...
    'Olf_Blind_B*'};

opt.subject_tgt_pattern = {... : the pattern that this will have in BIDS
    'ctrl'; ...
    'blnd'};
% opt.subject_to_run = {[1 2] [5 15]}; % Subjects to run for each group

% opt.subject_dir_pattern = {'Olf_Blind_B*'};
% opt.subject_tgt_pattern = {'blnd'};



% opt.subj_ls = { { [] } };



%% Details for ANAT
opt.src_anat_dir_patterns = {... %: one pattern per image
    'acq-mprage_T1w', ...
    'acq-tse_t2-tse-cor-'};

% corresponding names for the output file in BIDS data set
opt.tgt_anat_dir_patterns = {
    '_T1w', ...
    '_acq-tse_T2w'};


%% Details for FUNC
opt.src_func_dir_patterns = {... Same logic as above
    'bold_run-[1-2]';... % regular expressions are OK
    'bold_run-[3-4]';...
    'bold_RS'};
opt.task_name = {...
    'olfid'; ...
    'olfloc'; ...
    'rest'};

opt.nb_dummies = 8; %9 MAX!!!!

opt.nb_folder = [;...
    2;...
    2;...
    1];

opt.get_physio = [
    1;...
    1;...
    0];
opt.physio_patterns = {...
    '^Breathing.*[Ii]den[_]?[0]?[1-2].*.txt$'; ... % More regular expressions
    '^Breathing.*[Ll]oc[_]?[0]?[1-2].*.txt$' ;...
    ''};

opt.get_onset = [
    1;...
    1;...
    0];
opt.events_patterns = {...
    '^Breathing.*[Ii]den[_]?[0]?[1-2].*.txt$'; ...
    '^Breathing.*[Ll]oc[_]?[0]?[1-2].*.txt$' ;...
    ''};

opt.get_stim = [];
opt.stim_patterns = {};


%% Details for DWI
% target folders to convert
opt.src_dwi_dir_patterns = {...
    'pa_dwi', ...
    'ap_b0'};
% corresponding names for the output file in BIDS data set
opt.tgt_dwi_dir_patterns = {
    '_dwi', ...
    '_sbref'};


%% data description content 
opt.dd_json.License = '';
opt.dd_json.Authors = {'','',''};
opt.dd_json.Acknowledgements = '';
opt.dd_json.HowToAcknowledge = ''; 
opt.dd_json.Funding = {'','',''}; 
opt.dd_json.ReferencesAndLinks = {'','',''};
opt.dd_json.DatasetDOI = '';
opt.dd_json.Name = 'olfiddis'; 
opt.dd_json.BIDSVersion = '1.1.0'; 


%% events json content
opt.events_json_content.onset = struct(...
    'LongName', 'event onset', ...
    'Description', ' ', ...
    'Levels', struct(), ...
    'Units', 'seconds',...
    'TermURL', ' ');
opt.events_json_content.duration = struct(...
    'LongName', 'event duration', ...
    'Description', ' ', ...
    'Levels', struct(), ...
    'Units', 'seconds',...
    'TermURL', ' ');
opt.events_json_content.trial_type = struct(...
    'LongName', 'odorant', ...
    'Description', ' ', ...
    'Levels', struct(...
        'ch1', 'channel 1', ...        
        'ch3', 'channel 3', ...
        'ch5', 'channel 5', ...
        'ch7', 'channel 7', ...
        'resp_03', 'response 3', ...
        'resp_12', 'response 12'), ...
    'Units', ' ',...
    'TermURL', ' ');


%% option for json writing
opt.indent = '    ';


end
