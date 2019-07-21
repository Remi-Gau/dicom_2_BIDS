function create_stim_json(tgt_dir, task)

opts.indent = '    ';

filename = fullfile(tgt_dir, ['task-' task '_stim.json']);

content.SamplingFrequency = 100;
content.StartTime = 0;
content.Columns = {'FIIK1', 'FIIK2', 'FIIK3', 'FIIK4', 'FIIK5'};

spm_jsonwrite(filename, content, opts)