function create_stim_json(tgt_dir, opt, task_idx)

task = opt.task_name{task_idx};

filename = fullfile(tgt_dir, ['task-' task '_stim.json']);

fprintf('\n creating %s', filename)

opts.indent = opt.indent;

RepetitionTime =  0.785;

content.SamplingFrequency = 25;
content.StartTime = opt.nb_dummies * RepetitionTime * -1;
content.Columns = {'Respiratory'};

spm_jsonwrite(filename, content, opts)