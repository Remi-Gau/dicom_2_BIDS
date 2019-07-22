% script to import DICOM and format them into a BIDS structure
% while saving json and creating a participants.tsv file
% also creates a dataset_decription.json with empty fields

% REQUIRES
% - SPM12 7487
% - DICOM2NII (included in this repo)

% in theory a lot of the parameters can be changed in the parameters
% section at the beginning of the script

% in general make sure you have removed from your subjects source folder
% any folder that you do not want to convert (interrupted sequences for example)

% at the moment this script is not super flexible and assumes only one session
% and can only deal with anatomical functional and DWI.

% it also makes some assumption on the number of DWI, ANAT, resting state
% runs (only takes 1).

% the way the subject naming happens is hardcoded

% the script can remove up to 9 dummy scans (they are directly moved from the
% dicom source folder and put in a 'dummy' folder) so that dicm2nii does
% not "see" them

% the way event.tsv files are generated is very unflexible
% also the stimulus onset is not yet recalculated depending on the number
% of dummies removed

% there will still some cleaning up to do in the json files: for example
% most likely you will only want to have json files in the root folder and
% that apply to all inferior levels rather than one json file per nifti
% file (make use of the inheritance principle)

% json files created will be modified to remove any field with 'Patient' in
% it and the phase encoding direction will be re-encoded in a BIDS
% compliant way (i, j, k, i-, j-, k-)

% the participants.tsv file is created based on the header info of the
% anatomical (sex and age) so it might not be accurate

% TO DO
% - extract participant weight from header and put in tsv file?
% - refactor the different sections anat, func, dwi
%   - make sure that all parts that should be tweaked (or hard coded are in separate functions)
% - subject renaming should be more flexible
% - allow for removal of more than 9 dummy scans
% - move json file of each modality into the source folder
% - deal with sessions



clear
clc

%% Set directories
% fullpath of the spm 12 folder
spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';

% fullpaths
src_dir = 'D:\olf_blind\source'; % source folder
tgt_dir = 'D:\olf_blind\raw'; % target folder
onset_files_dir = 'D:\olf_blind\source\Fichiers onset';


%% Parameters definitions
% select what to convert and transfer
do_anat = 1;
do_func = 0;
do_dwi = 1;

opt.zip_output = 0; % 1 to zip the output into .nii.gz (not ideal for
% SPM users)
opt.delete_json = 0; % in case you have already created the json files in
% another way (or you have already put some in the root folder)
opt.do = 1; % actually covnert DICOMS, can be usefull to set to false
% if only events files or something similar must be created

% fullpath of the spm 12 folder
spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';

% fullpaths
src_dir = 'D:\olf_blind\source'; % source folder
tgt_dir = 'D:\olf_blind\raw'; % target folder
onset_files_dir = 'D:\olf_blind\source\Fichiers onset';

% DICOM folder patterns to look for
subject_dir_pattern = 'Olf_BLind*';

% Details for ANAT
% target folders to convert
opt.src_anat_dir_patterns = {
    'acq-mprage_T1w', ...
    'acq-tse_t2-tse-cor-448-2mm-FOV140_run'};
% corresponding names for the output file in BIDS data set
opt.tgt_anat_dir_patterns = {
    '_T1w', ...
    '_acq-tse_T2w'};

% Details for FUNC
src_func_dir_pattern = 'bold_run';
src_rs_dir_pattern = 'bold_RS';
task_name_1 = 'olfid';
task_name_2 = 'olfloc';
run_nb = [1 2 1 2]; % to give a number to each run depending on which task they belong to
nb_dummies = 8; %9 MAX!!!!

% Details for DWI
opt.src_dwi_dir_patterns = {...
    'pa_dwi', ...
    'ap_b0'};
opt.tgt_dwi_dir_patterns = {
    '_dwi', ...
    '_sbref'};
opt.bvecval = [1 0];
% opt.src_bref_dir_pattern = 'ap_b0';


%% set path and directories
addpath(spm_path)
spm('defaults','fmri')
% check spm version
[a, b] = spm('ver');
if any(~[strcmp(a, 'SPM12') strcmp(b, '7487')])
    str = sprintf('%s\n%s', ...
        'The current version SPM version is not SPM12 7487.', ...
        'In case of problems (e.g json file related) consider updating.');
    warning(str)
end
clear a b

addpath(fullfile(pwd,'dicm2nii'))

mkdir(tgt_dir)

% We create json files and do not save the patient code name
setpref('dicm2nii_gui_para', 'save_patientName', false);
setpref('dicm2nii_gui_para', 'save_json', true);

% Give some time to zip the files before we rename them
if opt.zip_output
    opt.pauseTime = 30; %#ok<*UNRCH>
else
    opt.pauseTime = 1;
end


%% let's do this

% create general json and data dictionary files
create_dataset_description_json(tgt_dir, opt)

% get list of subjsects
subj_ls = dir(fullfile(src_dir, subject_dir_pattern));
nb_sub = numel(subj_ls);

for iSub = 1:nb_sub % for each subject
    
    
    % creating name of the subject ID (folder and filename)
    if strcmp(subj_ls(iSub).name(11), 'B')
        sub_id = 'sub-blnd';
    elseif strcmp(subj_ls(iSub).name(11), 'C')
        sub_id = 'sub-ctrl';
    end
    sub_id = [sub_id subj_ls(iSub).name(12:end)]; %#ok<*AGROW>
    
    % keep track of the subjects ID to create participants.tsv
    ls_sub_id{iSub} = sub_id; %#ok<*SAGROW>
    
    fprintf('Processing %s\n', sub_id)
    
    % creating directories in BIDS structure
    sub_src_dir = fullfile(src_dir, subj_ls(iSub).name);
    sub_tgt_dir = fullfile(tgt_dir, sub_id);
    spm_mkdir(sub_tgt_dir, {'anat', 'func', 'dwi'});
    
    
    %% Anatomy folders
    if do_anat
        
        %% do T1w
        % we set the patterns in DICOM folder names too look for in the
        % source folder
        pattern.input = opt.src_anat_dir_patterns{1};
        % we set the pattern to in the target file in the BIDS data set
        pattern.output = opt.tgt_anat_dir_patterns{1};
        % we ask to return opt because that is where the age and gender of
        % the participants is stored
        [opt, anat_tgt_dir] = convert_anat(sub_id, iSub, sub_src_dir, sub_tgt_dir, pattern, opt);
        
        
        %% do T2 olfactory bulb high-res image
        pattern.input = opt.src_anat_dir_patterns{2};
        pattern.output = opt.tgt_anat_dir_patterns{2};
        convert_anat(sub_id, iSub, sub_src_dir, sub_tgt_dir, pattern, opt);
        
        % clean up
        delete(fullfile(anat_tgt_dir, '*.mat'))
        if opt.delete_json
            delete(fullfile(anat_tgt_dir, '*.json'))
        end
        
    end
    
    
    %% BOLD series
    if do_func
        
        if nb_dummies > 0
            filename = fullfile(tgt_dir, 'discarded_dummy.json');
            content.NumberOfVolumesDiscardedByUser = nb_dummies;
            spm_jsonwrite(filename, content, opts)
        end
        
        create_events_json(tgt_dir, task_name_1)
        create_events_json(tgt_dir, task_name_2)
        create_stim_json(tgt_dir, task_name_1, nb_dummies)
        create_stim_json(tgt_dir, task_name_2, nb_dummies)
        
        % define source and target folder for func
        bold_dirs = spm_select('FPList', sub_src_dir, 'dir', [src_func_dir_pattern '-[0-9]$']);
        func_tgt_dir = fullfile(sub_tgt_dir, 'func');
        
        % Remove any Nifti files and json present
        delete(fullfile(func_tgt_dir, '*.nii*'))
        delete(fullfile(func_tgt_dir, '*.json'))
        delete(fullfile(func_tgt_dir, '*.tsv'))
        
        % list onset files for that subject
        onset_files = spm_select('FPList', ...
            fullfile(onset_files_dir, subj_ls(iSub).name(11:end)), ...
            '^Results.*.txt$');
        
        for iBold = 1:size(bold_dirs,1)
            
            func_src_dir = bold_dirs(iBold,:);
            
            switch iBold
                case 1
                    func_tgt_name = fullfile(func_tgt_dir, ...
                        [sub_id '_task-' task_name_1 '_run-' num2str(run_nb(iBold)) '_bold']);
                    breath_pattern = '[Ii]den1';
                case 2
                    func_tgt_name = fullfile(func_tgt_dir, ...
                        [sub_id '_task-' task_name_1 '_run-' num2str(run_nb(iBold)) '_bold']);
                    breath_pattern = '[Ii]den2';
                case 3
                    func_tgt_name = fullfile(func_tgt_dir, ...
                        [sub_id '_task-' task_name_2 '_run-' num2str(run_nb(iBold)) '_bold']);
                    breath_pattern = '[Ll]oc1';
                case 4
                    func_tgt_name = fullfile(func_tgt_dir, ...
                        [sub_id '_task-' task_name_2 '_run-' num2str(run_nb(iBold)) '_bold']);
                    breath_pattern = '[Ll]oc2';
            end
            
            breathing_file = spm_select('FPList', ...
                fullfile(onset_files_dir, subj_ls(iSub).name(11:end)), ...
                ['^Breathing.*' breath_pattern '.*.txt$']);
            
            % set dummies aside
            discard_dummies(func_src_dir, nb_dummies, subj_ls, iSub)
            
            % convert files
            dicm2nii(func_src_dir, func_tgt_dir, opt.zip_output)
            % give some time to zip the files before we rename them
            pause(pauseTime)
            
            % changes names of output image file
            rename_tgt_file(func_tgt_dir, src_func_dir_pattern, func_tgt_name, 'nii');
            rename_tgt_file(func_tgt_dir, src_func_dir_pattern, func_tgt_name, 'json');
            
            % fix json content
            fix_json_content([func_tgt_name '.json'])
            
            
            %% onset file
            % get event onsets
            fid = fopen (onset_files(iBold,:), 'r');
            onsets = textscan(fid,'%s%s%s%s%s', 'Delimiter', ',');
            fclose (fid);
            
            % rewrite them as tsv
            event_tsv = [func_tgt_name(1:end-4) 'events.tsv'];
            fid = fopen (event_tsv, 'w');
            
            fprintf(fid, '%s\t%s\t%s\n', ...
                'onset', 'duration', 'odorant');
            
            for i_line =  2:size(onsets{1},1)
                fprintf(fid, '%f\t%f\t%s\n', ...
                    str2double(onsets{4}{i_line}), ...
                    str2double(onsets{5}{i_line}) - str2double(onsets{4}{i_line}), ...
                    onsets{3}{i_line});
            end
            fclose (fid);
            
            %% stim file
            
            % read content of breathing file
            fid = fopen (breathing_file, 'r');
            stim = textscan(fid,'%f%f%f%f%f', 'Delimiter', ',');
            fclose (fid);
            
            % rewrite them as tsv
            stim_tsv = [func_tgt_name(1:end-4) 'stim.tsv'];
            fid = fopen (stim_tsv, 'w');
            
            for i_line =  1:size(stim{1},1)
                fprintf(fid, '%f\t%f\t%f\t%f\t%f\n', ...
                    stim{1}(i_line), stim{2}(i_line), ...
                    stim{3}(i_line), stim{4}(i_line), stim{5}(i_line));
            end
            fclose (fid);
            gzip(stim_tsv)
            delete(stim_tsv)
        end
        
        
        %% take care of the resting state
        rs_dirs = spm_select('FPList', sub_src_dir, 'dir', [src_rs_dir_pattern '$']);
        if size(rs_dirs,1)>1
            error('more than one source RS folder')
        elseif size(rs_dirs,1)==1
            % define target file names for func
            rs_tgt_name = fullfile(func_tgt_dir, ...
                [sub_id '_task-rest_run-1_bold']);
            
            % set dummies aside
            discard_dummies(rs_dirs, nb_dummies, subj_ls, iSub)
            
            % convert
            dicm2nii(rs_dirs, func_tgt_dir, opt.zip_output)
            % give some time to zip the files before we rename them
            pause(pauseTime)
            
            % changes names of output image file
            rename_tgt_file(func_tgt_dir, src_rs_dir_pattern, rs_tgt_name, 'nii');
            rename_tgt_file(func_tgt_dir, src_rs_dir_pattern, rs_tgt_name, 'json');
            
            % fix json content
            fix_json_content([rs_tgt_name '.json'])
        end
        
        % clean up
        delete(fullfile(func_tgt_dir, '*.mat'))
        if opt.delete_json
            delete(fullfile(func_tgt_dir, '*.json'))
        end
        clear tgt_file func_tgt_name func_src_dir func_tgt_dir bold_dirs
        
    end
    
    %% deal with diffusion imaging
    if do_dwi

        %% do DWI
        % we set the patterns in DICOM folder names too look for in the
        % source folder
        pattern.input = opt.src_dwi_dir_patterns{1};
        % we set the pattern to in the target file in the BIDS data set
        pattern.output = opt.tgt_dwi_dir_patterns{1};

        bvecval = opt.bvecval(1);
        
        [dwi_tgt_dir] = convert_dwi(sub_id, sub_src_dir, sub_tgt_dir, bvecval, pattern, opt);

        if opt.delete_json
            delete(fullfile(dwi_tgt_dir, '*.json'))
        end
        
        %% do b_ref
        pattern.input = opt.src_dwi_dir_patterns{2};
        % we set the pattern to in the target file in the BIDS data set
        pattern.output = opt.tgt_dwi_dir_patterns{2};

        bvecval = opt.bvecval(2);
        
        convert_dwi(sub_id, sub_src_dir, sub_tgt_dir, bvecval, pattern, opt);
        

        %% clean up
        delete(fullfile(dwi_tgt_dir, '*.mat'))
        delete(fullfile(dwi_tgt_dir, '*.txt'))

        
    end
    
end


%% print participants.tsv file
if do_anat
    create_participants_tsv(tgt_dir, ls_sub_id, opt.age, opt.gender);
end

message = 'REMEMBER TO CHECK IF YOU HAVE A VALID BIDS DATA SET BY USING THE BIDS VALIDATOR:';
bids_validator_URL = 'https://bids-standard.github.io/bids-validator/';
fprintf('\n\n%s\n\n%s\n\n', message, bids_validator_URL)
