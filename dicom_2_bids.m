% script to import DICOM and format them into a BIDS structure
% Will also create the required json files and tsv files

% See getOptions and README for more information

clear;
clc;

[opt] = setUp();

%% let's do this

% create general json and data dictionary files
create_dataset_description_json(opt.tgt_dir, opt);

ls_sub_id = {};

for iGroup = 1:numel(opt.subject_dir_pattern)

    opt.iGroup = iGroup;

    % get list of subjsects
    if isempty(opt.subject_dir_pattern{iGroup})
        subj_ls = opt.subj_ls;
    else
        subj_ls = dir(fullfile(opt.src_dir, opt.subject_dir_pattern{iGroup}));
        subj_ls = {subj_ls.name};
    end
    nb_sub = numel(subj_ls);

    if isfield(opt, 'subject_to_run')
        subject_to_run = opt.subject_to_run{iGroup};
    else
        subject_to_run = 1:nb_sub;
    end

    for iSub = subject_to_run % for each subject

        opt.iSub = iSub;

        % creating name of the subject ID (folder and filename)
        if isempty(opt.subject_tgt_pattern{iGroup})
            sub_id = 'sub-';
        else
            sub_id = ['sub-' opt.subject_tgt_pattern{iGroup}];
        end
        sub_id = [sub_id sprintf('%02.0f', iSub)]; %#ok<*AGROW>

        opt.scans_tsv{iSub, iGroup}.name = sub_id;
        opt.scans_tsv{iSub, iGroup}.filename = {};
        opt.scans_tsv{iSub, iGroup}.acq_time = {};

        % keep track of the subjects ID to create participants.tsv
        ls_sub_id{end + 1} = sub_id; %#ok<*SAGROW>

        fprintf('\n\n\nProcessing %s\n', sub_id);

        % creating directories in BIDS structure
        sub_src_dir = fullfile(opt.src_dir, subj_ls{iSub});
        sub_tgt_dir = fullfile(opt.tgt_dir, sub_id);

        %% Anatomy folders
        if opt.do_anat

            opt.type = 'anat';

            spm_mkdir(sub_tgt_dir, 'anat');

            fprintf('\n\ndoing ANAT\n');

            % remove any nifti files and json present in the target folder to start
            % from a blank slate
            delete(fullfile(sub_tgt_dir, 'anat', '*.nii*'));
            delete(fullfile(sub_tgt_dir, 'anat', '*.json'));

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
            delete(fullfile(anat_tgt_dir, '*.mat'));

        end

        %% BOLD series
        if opt.do_func

            opt.type = 'func';

            spm_mkdir(sub_tgt_dir, 'func');

            fprintf('\n\ndoing FUNC\n');

            %% do for each TASK
            for task_idx = 1:numel(opt.task_name)
                fprintf('\n\n doing TASK: %s\n', opt.task_name{task_idx});
                [func_tgt_dir] = convert_func(sub_id, sub_src_dir, sub_tgt_dir, opt, task_idx);

                fprintf('\n');
                convert_event(sub_id, subj_ls{iSub}, sub_src_dir, sub_tgt_dir, opt, task_idx);

                fprintf('\n');
                convert_stim(sub_id, subj_ls{iSub}, sub_src_dir, sub_tgt_dir, opt, task_idx);

                fprintf('\n');
                convert_physio(sub_id, subj_ls{iSub}, sub_src_dir, sub_tgt_dir, opt, task_idx);
            end

            % clean up
            delete(fullfile(func_tgt_dir, '*.mat'));

        end

        %% deal with diffusion imaging
        if opt.do_dwi

            opt.type = 'dwi';

            spm_mkdir(sub_tgt_dir, 'dwi');

            fprintf('\n\ndoing DWI\n');

            % remove any nifti files and json present in the target folder to start
            % from a blank slate
            delete(fullfile(sub_tgt_dir, 'dwi', '*.nii*'));
            delete(fullfile(sub_tgt_dir, 'dwi', '*.json'));
            delete(fullfile(sub_tgt_dir, 'dwi', '*.bv*'));

            %% do for all DWI
            for iIMG = 1:numel(opt.src_dwi_dir_patterns)

                % we set the patterns in DICOM folder names too look for in the
                % source folder
                pattern.input = opt.src_dwi_dir_patterns{iIMG};
                % we set the pattern to in the target file in the BIDS data set
                pattern.output = opt.tgt_dwi_dir_patterns{iIMG};

                [dwi_tgt_dir] = convert_dwi(sub_id, sub_src_dir, sub_tgt_dir, pattern, opt);

            end

            % clean up
            delete(fullfile(dwi_tgt_dir, '*.mat'));
            delete(fullfile(dwi_tgt_dir, '*.txt'));

        end

    end

end

%% print participants.tsv file
if opt.do_anat && opt.do
    create_participants_tsv(opt.tgt_dir, ls_sub_id, opt.age, opt.gender);
end

message = 'REMEMBER TO CHECK IF YOU HAVE A VALID BIDS DATA SET BY USING THE BIDS VALIDATOR:';
bids_validator_URL = 'https://bids-standard.github.io/bids-validator/';
fprintf('\n\n%s\n\n%s\n\n', message, bids_validator_URL);
