function create_stim_json(tgt_dir, task, nb_dummies, opt)

RepetitionTime =  0.785;

filename = fullfile(tgt_dir, ['task-' task '_stim.json']);

content.SamplingFrequency = 24.875;
content.StartTime = nb_dummies * RepetitionTime * -1;
content.Columns = {'breath', 'stimulus', 'FIIK3', 'FIIK4', 'response'};
% FIIK: fuck if I know

spm_jsonwrite(filename, content, opt)