function create_stim_json(tgt_dir, opt, task_idx)

task = opt.task_name{task_idx};

opts.indent = opt.indent;

RepetitionTime =  0.785;

filename = fullfile(tgt_dir, ['task-' task '_stim.json']);

content.SamplingFrequency = 24.875;
content.StartTime = opt.nb_dummies * RepetitionTime * -1;
content.Columns = {'breath', 'stimulus', 'FIIK3', 'FIIK4', 'response'};
% FIIK: fuck if I know

spm_jsonwrite(filename, content, opts)