function [func_tgt_dir] = convert_func(sub_id, sub_src_dir, sub_tgt_dir, opt, task_idx)


nb_folder = opt.nb_folder(task_idx);
pattern.input = opt.src_func_dir_patterns{task_idx};
pattern.output = opt.task_name{task_idx};


func_tgt_dir = fullfile(sub_tgt_dir, 'func');

% define source and target folder for func
% Remove any nifti / json  files present related to this task
if opt.do

    bold_dirs = spm_select('FPList', sub_src_dir, 'dir', ['^.*' pattern.input '$']);
    if size(bold_dirs,1)~=nb_folder
        disp(bold_dirs)
        fprintf('\n')
        warning('More than the required number of source func folders for that task')
        create_log_file(sub_id, sub_src_dir, ['_task-' pattern.output], bold_dirs, 'folder')
    end

    delete(fullfile(func_tgt_dir, ['*' pattern.output '*.nii*']))
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*.json*']))
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

        % bring them back to leave the original structure seemingly
        % untouched
        bring_back_dummies(func_src_dir,opt)

    end

end

end
