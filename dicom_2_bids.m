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

% it also makes some assumption on the number of DWI, ANAT runs (only takes 1).

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
% - documentation !!!!!
% - extract participant weight from header and put in tsv file?
% - make sure that all parts that should be tweaked (or hard coded are in separate functions)
% - allow for removal of more than 9 dummy scans
% - deal with sessions

clear
clc

[opt] = setUp();


%% let's do this

% create general json and data dictionary files
create_dataset_description_json(opt.tgt_dir, opt)

for iGroup = 1:numel(opt.subject_dir_pattern)
    
    % get list of subjsects
    if isempty(opt.subject_dir_pattern{iGroup})
        subj_ls = opt.subj_ls{1};
    else
        subj_ls = dir(fullfile(opt.src_dir, opt.subject_dir_pattern{iGroup}));
        subj_ls = {subj_ls.name};
    end
    nb_sub = numel(subj_ls);
    
    
    for iSub = 1 %nb_sub % for each subject
        
        opt.iSub = iSub;
        
        % creating name of the subject ID (folder and filename)
        if isempty(opt.subject_tgt_pattern{iGroup})
            sub_id = 'sub-';
        else
            sub_id = ['sub-' opt.subject_tgt_pattern{iGroup}];
        end
        sub_id = [sub_id sprintf('%02.0f', iSub)]; %#ok<*AGROW>
        
        % keep track of the subjects ID to create participants.tsv
        ls_sub_id{iSub} = sub_id; %#ok<*SAGROW>
        
        fprintf('\n\n\nProcessing %s\n', sub_id)
        
        % creating directories in BIDS structure
        sub_src_dir = fullfile(opt.src_dir, subj_ls{iSub});
        sub_tgt_dir = fullfile(opt.tgt_dir, sub_id);
        
        
        
        %% Anatomy folders
        if opt.do_anat
            
            opt.type = 'anat';
            
            spm_mkdir(sub_tgt_dir, 'anat');
            
            fprintf('\n\ndoing ANAT\n')
            
            % remove any nifti files and json present in the target folder to start
            % from a blank slate
            delete(fullfile(sub_tgt_dir, 'anat', '*.nii*'))
            delete(fullfile(sub_tgt_dir, 'anat', '*.json'))
            
            
            %% do for all ANAT
            for iIMG = 1:numel(opt.src_anat_dir_patterns)
                
                % we set the patterns in DICOM folder names too look for in the
                % source folder
                pattern.input = opt.src_anat_dir_patterns{iIMG};
                % we set the pattern to in the target file in the BIDS data set
                pattern.output = opt.tgt_anat_dir_patterns{iIMG};
                % we ask to return opt because that is where the age and gender of
                % the participants is stored
                [opt, anat_tgt_dir] = convert_anat(sub_id, sub_src_dir, sub_tgt_dir, pattern, opt);
                
            end
            
            %% clean up
            delete(fullfile(anat_tgt_dir, '*.mat'))
            
        end
        
        
        %% BOLD series
        if opt.do_func
            
            opt.type = 'func';
            
            spm_mkdir(sub_tgt_dir, 'func');
            
            fprintf('\n\ndoing FUNC\n')

            for task_idx = 1:numel(opt.task_name)
                fprintf('\n\n doing TASK: %s\n', opt.task_name{task_idx})
                [func_tgt_dir] = convert_func(sub_id, subj_ls{iSub}, sub_src_dir, sub_tgt_dir, opt, task_idx);
                fprintf('\n')
                convert_event(sub_id, subj_ls{iSub}, sub_src_dir, sub_tgt_dir, opt, task_idx);
                fprintf('\n')
                convert_stim(sub_id, subj_ls{iSub}, sub_src_dir, sub_tgt_dir, opt, task_idx);
            end
            
            % clean up
            delete(fullfile(func_tgt_dir, '*.mat'))
            
        end
        
        %% deal with diffusion imaging
        if opt.do_dwi
            
            opt.type = 'dwi';
            
            spm_mkdir(sub_tgt_dir, 'dwi');
            
            fprintf('\n\ndoing DWI\n')
            
            % remove any nifti files and json present in the target folder to start
            % from a blank slate
            delete(fullfile(sub_tgt_dir, 'dwi', '*.nii*'))
            delete(fullfile(sub_tgt_dir, 'dwi', '*.json'))
            delete(fullfile(sub_tgt_dir, 'dwi', '*.bv*'))
            
            %% do for all DWI
            for iIMG = 1:numel(opt.src_dwi_dir_patterns)
                
                % we set the patterns in DICOM folder names too look for in the
                % source folder
                pattern.input = opt.src_dwi_dir_patterns{iIMG};
                % we set the pattern to in the target file in the BIDS data set
                pattern.output = opt.tgt_dwi_dir_patterns{iIMG};

                [dwi_tgt_dir] = convert_dwi(sub_id, sub_src_dir, sub_tgt_dir, pattern, opt);
                
            end
            
            %% clean up
            delete(fullfile(dwi_tgt_dir, '*.mat'))
            delete(fullfile(dwi_tgt_dir, '*.txt'))
            
            
        end
        
    end
    
end


%% print participants.tsv file
if opt.do_anat && opt.do
    create_participants_tsv(opt.tgt_dir, ls_sub_id, opt.age, opt.gender);
end

message = 'REMEMBER TO CHECK IF YOU HAVE A VALID BIDS DATA SET BY USING THE BIDS VALIDATOR:';
bids_validator_URL = 'https://bids-standard.github.io/bids-validator/';
fprintf('\n\n%s\n\n%s\n\n', message, bids_validator_URL)
