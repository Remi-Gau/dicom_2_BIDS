% small script to check the number of volumes in each bold file for each task
clear;
close all;
clc;

tgt_dir = 'D:\Dropbox\BIDS\olf_blind\raw';
spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';

addpath(spm_path);
spm('defaults', 'fmri');

BIDS = spm_BIDS(tgt_dir);

tasks = spm_BIDS(BIDS, 'tasks');
subjects = spm_BIDS(BIDS, 'subjects');
types = spm_BIDS(BIDS, 'types');

for iTask = 1:numel(tasks)
    all_tasks(iTask) = struct('nb_run', [], 'nb_vol', []);
end

for iSubject = 1:numel(subjects)

    disp(subjects{iSubject});

    for iTask = 1:numel(tasks)

        runs = spm_BIDS(BIDS, 'runs', ...
                        'sub', subjects{iSubject}, ...
                        'task', tasks{1, iTask}, ...
                        'type', 'bold');

        files  = spm_BIDS(BIDS, 'data', ...
                          'sub', subjects{iSubject}, ...
                          'task', tasks{1, iTask}, ...
                          'type', 'bold');

        hdr = spm_vol(files);

        all_tasks(iTask).nb_run = [all_tasks(iTask).nb_run str2double(runs)];
        all_tasks(iTask).nb_vol = [all_tasks(iTask).nb_vol cellfun(@numel, hdr)']; %#ok<*SAGROW>
    end
end

%%
close all;
for iTask = 1:numel(tasks)
    figure('name', tasks{iTask}, 'position', [25 50 1500 600]);
    bar(all_tasks(iTask).nb_vol);
    axis tight;
    set(gca, ...
        'xtick', find(all_tasks(iTask).nb_run == 1), ...
        'xticklabel', subjects, ...
        'fontsize', 8);
    title(sprintf('Number of volumes in task: %s', tasks{iTask}));
end
