% script to import DICOM and format them into a
% while saving json and creating a participants.tsv file

clear
clc


%% parameters definitions
% select what to convert and transfer
do_anat = 1;
do_func = 1;
do_B0 = 0;
do_dwi = 0;

nb_dummies = 4;

zip_output = 0;

task_name = 'olfiddis';

% fullpath of the spm 12 folder
spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';

%fullpaths 
src_dir = 'D:\olf_blind\source'; % source folder
tgt_dir = 'D:\olf_blind\raw'; % target folder
onset_files_dir = 'D:\olf_blind\source\Fichiers onset';


subject_dir_pattern = 'Olf_BLind*';
src_anat_dir_pattern = 'acq-mprage_T1w';
src_func_dir_pattern = 'task_p2-s3-3mm_bold_run';
src_rs_dir_pattern = 'task_p2-s3-3mm_bold_RS';


%% set peht and directories
addpath(spm_path)
addpath(fullfile(pwd,'dicm2nii'))

mkdir(tgt_dir)

% We create json files and do not save the patient code name
setpref('dicm2nii_gui_para', 'save_patientName', false);
setpref('dicm2nii_gui_para', 'save_json', true);

% Give some time to zip the files before we rename them
if zip_output
    PauseTime = 30; %#ok<*UNRCH>
else
    PauseTime = 1;
end

%% let's do this
% get list of subjsects
subj_ls = dir(fullfile(src_dir, subject_dir_pattern));
nb_sub = numel(subj_ls);

List_problematic_files = {};

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
    sub_src_dir = fullfile(src_dir, subj_ls(1).name);
    sub_tgt_dir = fullfile(tgt_dir, sub_id);
    spm_mkdir(sub_tgt_dir, {'anat', 'func'});
    
    
    %% Anatomy folders
    if do_anat
        
        
        % define source and target folder for anat
        ls_dir = spm_select('FPList',sub_src_dir,'dir', src_anat_dir_pattern);
        if size(ls_dir,1)==1
            anat_src_dir = ls_dir;
        else
            error('more than one source anat folder')
        end
        func_tgt_dir = fullfile(sub_tgt_dir, 'anat');
        
        
        % define target file names for anat
        anat_tgt_name = fullfile(func_tgt_dir, [sub_id '_T1w']);
        
        
        % Remove any nifti files and json present in the target folder to start
        % from a blank slate
        delete(fullfile(func_tgt_dir, '*.nii'))
        delete(fullfile(func_tgt_dir, '*.nii.gz'))
        delete(fullfile(func_tgt_dir, '*.json'))
        
        
        % Convert files (0 is for 4D unzipped files)
        varargout = dicm2nii(anat_src_dir, func_tgt_dir, 0);
        
        
        % Give some time to zip the files before we rename them
        pause(PauseTime/4)
        
        
        % rename json and .nii output files
        tgt_file = spm_select('FPList', func_tgt_dir, '^.*T1w.*nii$');
        movefile(tgt_file, [anat_tgt_name '.nii'])
        tgt_file = spm_select('FPList', func_tgt_dir, '^.*T1w.*json$');
        movefile(tgt_file, [anat_tgt_name '.json'])
        
        content = spm_jsonread([anat_tgt_name '.json']);

        gender(iSub) = content.PatientSex;
        age(iSub) = str2double(content.PatientAge(1:3));
        
        delete(fullfile(func_tgt_dir, '*.mat'))
        
        clear anat_tgt_name anat_tgt_json_name anat_src_dir anat_tgt_dir content
        
    end
    
    %% BOLD series
    if do_func
        
        
        % define source and target folder for anat
        bold_dirs = spm_select('FPList', sub_src_dir, 'dir', src_func_dir_pattern);
        func_tgt_dir = fullfile(sub_tgt_dir, 'func');
        
        
        % Remove any Nifti files and json present
        delete(fullfile(func_tgt_dir, '*.nii.gz'))
        delete(fullfile(func_tgt_dir, '*.json'))
        
        
        % list onset files for that subject
        onset_files = spm_select('FPList', ...
                fullfile(onset_files_dir, subj_ls(iSub).name(11:end)), ... 
                '^Results.*.txt$');

        for iBold = 1:size(bold_dirs,1)
            
            func_src_dir = bold_dirs(iBold,:);

            
            % define target file names for func
            func_tgt_name = fullfile(func_tgt_dir, ...
                [sub_id '_task-' task_name '_run-' num2str(iBold) '_bold']);
            
            
            % set dummies aside
            mkdir(fullfile(func_src_dir, 'dummy'))
            dummies = spm_select('FPList', func_src_dir, ...
                ['^.*' subj_ls(iSub).name '-000[0-' num2str(nb_dummies) '].dcm$']);
            if ~isempty(dummies)
                for i_dummy = 1:nb_dummies
                    movefile(dummies(i_dummy,:), fullfile(func_src_dir, 'dummy'))
                end
            end
            
            
            % Convert files
            dicm2nii(func_src_dir, func_tgt_dir, 0)
            
            
            % Give some time to zip the files before we rename them
            pause(PauseTime)
            
            
            % Changes names of output image file
            tgt_file = spm_select('FPList', func_tgt_dir, ...
                ['^.*' strrep(src_func_dir_pattern, '-','_') '.*.nii$']);
            movefile(tgt_file, [func_tgt_name '.nii'])
            tgt_file = spm_select('FPList', func_tgt_dir, ...
                ['^.*' strrep(src_func_dir_pattern, '-','_') '.*.json$']);
            movefile(tgt_file, [func_tgt_name '.json'])
            
            delete(fullfile(func_tgt_dir, '*.mat'))
            
            
            % get onsets 
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
        end
        clear tgt_file func_tgt_name func_src_dir func_tgt_dir bold_dirs
        
        
        %% take care of the resting state
        rs_dirs = spm_select('FPList', sub_src_dir, 'dir', src_rs_dir_pattern);
        
        if size(rs_dirs,1)>1
            error('more than one source anat folder')
        end
        
        % define target file names for func
        rs_tgt_name = fullfile(func_tgt_dir, ...
            [sub_id '_task-rest_run-1_bold']);
        
        % convert
        dicm2nii(rs_dirs, func_tgt_dir, 0)

        
        % Give some time to zip the files before we rename them
        pause(PauseTime)
        
        
        % Changes names of output image file
        tgt_file = spm_select('FPList', func_tgt_dir, ...
            ['^.*' strrep(src_rs_dir_pattern, '-','_') '.*.nii$']);
        movefile(tgt_file, [func_tgt_name '.nii'])
        tgt_file = spm_select('FPList', func_tgt_dir, ...
            ['^.*' strrep(src_rs_dir_pattern, '-','_') '.*.json$']);
        movefile(tgt_file, [func_tgt_name '.json'])
        
        delete(fullfile(func_tgt_dir, '*.mat'))
        
    end
end



%%
headers = {'participant_id' 'age' 'sex'};...

DestName = fullfile(tgt_dir, 'participants.tsv');
OFilefID = fopen (DestName, 'w');

fprintf(OFilefID, '%s\t%s\t%s\n', headers{1}, headers{2}, headers{3} ); 

for iSub = 1:nb_sub
    fprintf (OFilefID, '%s\t%i\t%s\n', ...
        ls_sub_id{iSub}, ...
        age(iSub), ...
        gender(iSub));
end

fclose (OFilefID);
