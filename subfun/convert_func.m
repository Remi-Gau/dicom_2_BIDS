function [func_tgt_dir] = convert_func(sub_id, subj_ls, sub_src_dir, sub_tgt_dir, opt, task_idx)

get_onset = opt.get_onset(task_idx);
get_stim = opt.get_stim(task_idx);
nb_folder = opt.nb_folder(task_idx);
pattern.input = opt.src_func_dir_patterns{task_idx};
pattern.output = opt.task_name{task_idx};
stim_pattern = opt.stim_patterns{task_idx};
events_pattern = opt.events_patterns{task_idx};...
event_file2choose = opt.events_src_file{task_idx};

func_tgt_dir = fullfile(sub_tgt_dir, 'func');

% define source and target folder for func
% Remove any nifti / json / tsv files present related to this task
if opt.do
    
    bold_dirs = spm_select('FPList', sub_src_dir, 'dir', ['^.*' pattern.input '$']);
    if size(bold_dirs,1)~=nb_folder
        disp(bold_dirs)
        fprintf('\n')
        warning('More than the required number of source func folders for that task')
        create_log_file(sub_id, sub_src_dir, ['_task-' pattern.output], bold_dirs)
    end

    delete(fullfile(func_tgt_dir, ['*' pattern.output '*.nii*']))
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*.json*']))
end

if get_onset
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*events.tsv*']))
    % list onset files for that subject
    onset_files = spm_select('FPList', ...
        fullfile(opt.onset_files_dir, subj_ls(end-2:end)), ...
        events_pattern);
    if size(onset_files,1)~=sum(cellfun(@numel, opt.events_src_file))
        disp(onset_files)
        fprintf('\n')
        warning('More than the required number of source onset files')
        create_log_file(sub_id, sub_src_dir, ['_task-' pattern.output], onset_files)
    end
    onset_files = onset_files(event_file2choose,:);
end

if get_stim
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*stim.tsv.gz*']))
    % list onset files for that subject
    stim_files = spm_select('FPList', ...
        fullfile(opt.onset_files_dir, subj_ls(end-2:end)), ...
        stim_pattern);
    if size(stim_files,1)~=nb_folder
        disp(stim_files)
        fprintf('\n')
        warning('More than the required number of source stim files for that task')
        create_log_file(sub_id, sub_src_dir, ['_task-' pattern.output], stim_files)
    end
end

% do the conversion
for iBold = 1:nb_folder

    func_tgt_name = fullfile(func_tgt_dir, ...
        [sub_id '_task-' pattern.output '_run-' sprintf('%02.0f', iBold) '_bold']);
    
    if opt.do
        
        func_src_dir = bold_dirs(iBold,:);

        % set dummies aside
        discard_dummies(func_src_dir, opt.nb_dummies);
        
        conversion_do(func_src_dir, func_tgt_dir, func_tgt_name, pattern, opt);

    end

    %% events file
    if get_onset
        input_file = deblank(onset_files(iBold,:));
        output_file = [func_tgt_name(1:end-4) 'events.tsv'];
        create_events_file(input_file, output_file)
        create_events_json(opt.tgt_dir, opt, task_idx)
    end
    
    %% stim file
    if get_stim
        input_file = deblank(stim_files(iBold,:));
        output_file = [func_tgt_name(1:end-4) 'stim.tsv'];
        create_stim_file(input_file, output_file)
        create_stim_json(opt.tgt_dir, opt, task_idx)
    end
end

end