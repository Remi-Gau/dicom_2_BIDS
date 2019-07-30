function convert_event(sub_id, subj_ls, sub_src_dir, sub_tgt_dir, opt, task_idx)

get_onset = opt.get_onset(task_idx);
nb_folder = opt.nb_folder(task_idx);
events_pattern = opt.events_patterns{task_idx};
pattern.input = opt.src_func_dir_patterns{task_idx};
pattern.output = opt.task_name{task_idx};

func_tgt_dir = fullfile(sub_tgt_dir, 'func');

if get_onset
    
    delete(fullfile(func_tgt_dir, ['*' pattern.output '*events.tsv*']))
    
    % list onset files for that subject
    onset_files = spm_select('FPList', ...
        fullfile(opt.onset_files_dir, subj_ls(end-2:end)), ...
        events_pattern);
    
    results_files = spm_select('FPList', ...
        fullfile(opt.onset_files_dir, subj_ls(end-2:end)), ...
        '^Results.*.txt$');
    
    if task_idx==1
        results_files(3:4,:) = [];
    elseif task_idx==2
        results_files(1:2,:) = [];
    end
    
    if size(onset_files,1)~=nb_folder
        disp(onset_files)
        fprintf('\n')
        warning('More than the required number of source onset files')
        create_log_file(sub_id, sub_src_dir, ['_task-' pattern.output], onset_files, 'folder')
    end
    
    
    % do the conversion
    for iBold = 1:nb_folder
        
        func_tgt_name = fullfile(func_tgt_dir, ...
            [sub_id '_task-' pattern.output '_run-' sprintf('%02.0f', iBold) '_bold']);
        
        input_file = deblank(onset_files(iBold,:));
        output_file = [func_tgt_name(1:end-4) 'events.tsv'];
        
        % previously compiled file (just to check our results against it)
        comp_file = deblank(results_files(iBold,:)); 
        
        
        create_events_file(input_file, output_file, comp_file, opt)
        create_events_json(opt.tgt_dir, opt, task_idx)

    end

end

end