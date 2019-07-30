function convert_physio(sub_id, subj_ls, sub_src_dir, sub_tgt_dir, opt, task_idx)

if ~isempty(opt.get_physio)
    get_physio = opt.get_physio(task_idx);
    physio_pattern = opt.physio_patterns{task_idx};
    nb_folder = opt.nb_folder(task_idx);
    pattern.input = opt.src_func_dir_patterns{task_idx};
    pattern.output = opt.task_name{task_idx};
    
    func_tgt_dir = fullfile(sub_tgt_dir, 'func');
    
    if get_physio
        delete(fullfile(func_tgt_dir, ['*' pattern.output '*physio.tsv.gz*']))
        % list onset files for that subject
        physio_files = spm_select('FPList', ...
            fullfile(opt.onset_files_dir, subj_ls(end-2:end)), ...
            physio_pattern);
        if size(physio_files,1)~=nb_folder
            disp(physio_files)
            fprintf('\n')
            warning('More than the required number of source stim files for that task')
            create_log_file(sub_id, sub_src_dir, ['_task-' pattern.output], physio_files, folder')
        end
        
        % do the conversion
        for iBold = 1:nb_folder
            
            func_tgt_name = fullfile(func_tgt_dir, ...
                [sub_id '_task-' pattern.output '_run-' sprintf('%02.0f', iBold) '_bold']);
            
            input_file = deblank(physio_files(iBold,:));
            output_file = [func_tgt_name(1:end-4) 'physio.tsv'];
            create_physio_file(input_file, output_file)
            create_physio_json(opt.tgt_dir, opt, task_idx)
            
        end
    end
    
end

end