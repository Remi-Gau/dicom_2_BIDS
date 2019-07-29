function create_events_json(tgt_dir, opt, task_idx)

task = opt.task_name{task_idx};

opts.indent = opt.indent;

filename = fullfile(tgt_dir, ['task-' task '_events.json']);

fprintf('\n creating %s', filename)

% create corresponding data dictionary
content = opt.events_json_content;

spm_jsonwrite(filename, content, opts)