function [opt] = setUp()


%% set options
opt = getOption();

% Give some time to zip the files before we rename them
if opt.zip_output
    opt.pauseTime = 30; %#ok<*UNRCH>
else
    opt.pauseTime = 2;
end


%% set path and directories
addpath(genpath(fullfile(pwd, 'subfun')))
addpath(genpath(fullfile(pwd, 'diy')))
addpath(fullfile(pwd, 'dicm2nii'))

mkdir(opt.tgt_dir)

%% check spm version
addpath(opt.spm_path)
try
[a, b] = spm('ver');
if any(~[strcmp(a, 'SPM12') strcmp(b, '7487')])
    str = sprintf('%s\n%s', ...
        'The current version SPM version is not SPM12 7487.', ...
        'In case of problems (e.g json file related) consider updating.');
    warning(str); %#ok<*SPWRN>
end
clear a b
catch
    error('Failed to check the SPM version: Are you sure that SPM is in the matlab path?')
end
spm('defaults','fmri')


%% We create json files and do not save the patient code name
setpref('dicm2nii_gui_para', 'save_patientName', false);
setpref('dicm2nii_gui_para', 'save_json', true);


end