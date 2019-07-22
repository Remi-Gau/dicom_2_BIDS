function [func_tgt_dir] = convert_func(sub_id, subj_ls, iSub, sub_src_dir, sub_tgt_dir, opt, task_idx)

get_onset = opt.get_onset(task_idx);
get_stim = opt.get_stim(task_idx);
nb_folder = opt.nb_folder(task_idx);
pattern.input = opt.src_func_dir_patterns{task_idx};
pattern.output = opt.task_name{task_idx};

% define source and target folder for func
bold_dirs = spm_select('FPList', sub_src_dir, 'dir', [pattern.input '$']);
if size(bold_dirs,1)~=nb_folder
    disp(bold_dirs)
    error('More than the required number of source func folders for that task')
end

func_tgt_dir = fullfile(sub_tgt_dir, 'func');

% Remove any nifti / json / tsv files present related to this task
if opt.do
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*.nii*']))
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*.json*']))
end

if get_onset
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*events.tsv*']))
    % list onset files for that subject
    onset_files = spm_select('FPList', ...
        fullfile(onset_files_dir, subj_ls(iSub).name(11:end)), ...
        '^Results.*.txt$');
end
if get_stim
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*stim.tsv.gz*']))
end

for iBold = 1:size(bold_dirs,1)
    
    func_src_dir = bold_dirs(iBold,:);
    
    func_tgt_name = fullfile(func_tgt_dir, ...
        [sub_id '_task-' pattern.output '_run-' num2str(iBold) '_bold']);
    
    %     breathing_file = spm_select('FPList', ...
    %         fullfile(onset_files_dir, subj_ls(iSub).name(11:end)), ...
    %         ['^Breathing.*' breath_pattern '.*.txt$']);
    
    if opt.do
        % set dummies aside
        discard_dummies(func_src_dir, opt.nb_dummies, subj_ls, iSub)
        
        conversion_do(func_src_dir, func_tgt_dir, func_tgt_name, pattern, opt)
    end
    
    %% events file
    if get_onset
        input_file = onset_files(iBold,:);
        output_file = [func_tgt_name(1:end-4) 'events.tsv'];
        create_onset_file(input_file, output_file)
    end
    
    %% stim file
    if get_stim
        
    end
end

end