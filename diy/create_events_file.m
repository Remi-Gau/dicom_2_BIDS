function create_events_file(input_file, output_file, comp_file, opt)

[~, filename]= spm_fileparts(output_file);

sampling_frequency = 25;
RT = 0.785;

fprintf('\n getting EVENTS from: %s\n  into file: %s\n', input_file, output_file)

% read content of breathing file
fid = fopen (input_file, 'r');
events = textscan(fid,'%f%f%f%f%f', 'Delimiter', ',');
fclose (fid);

% read content of result file
fid = fopen (comp_file, 'r');
results = textscan(fid,'%f%f%s%f%f', 'Delimiter', ',', 'Headerlines', 1);
fclose (fid);

time = events{3};
time = (time - time(1))/1000;
stim = events{2};
resp = events{5};

%% get onsets, offsets, durations of stims
stim_onsets = find(diff(stim)>0);
stim_offsets = find(diff(stim)<0);
if numel(stim_offsets)<3
    create_log_file('', opt.tgt_dir, filename, ...
        num2str(time(stim_offsets)), 'onset')
    warning('We should have more than 2 stim offsets.')
elseif numel(stim_offsets)==3
    stim_offsets(end+1) = size(stim,1);
end

if numel(stim_onsets)<3
    create_log_file('', opt.tgt_dir, filename, ...
        num2str(time(stim_onsets)), 'onset')
    warning('We should have more than 2 stim onsets.')
elseif numel(stim_onsets)==3
    warning('Seems we are missing one onset: taking beginning of run as start point.)')
    stim_onsets = [1 ; stim_onsets];
end

if ~isempty(stim_onsets)
    fprintf(' Onsets differences between breathing file and results file in seconds\n')
    disp(time(stim_onsets) - results{4})
    
    if any([time(stim_onsets) - results{4}] > 1)
        create_log_file('', opt.tgt_dir, filename, ...
            num2str(time(stim_onsets) - results{4}), 'onset')
        warning('We have a big difference between the results and the breathing file.')
    end
    
    % account for the number of dummies removed;
    stim_onsets = time(stim_onsets) - opt.nb_dummies * RT;
    stim_offsets = time(stim_offsets) - opt.nb_dummies * RT;
    stim_durations = stim_offsets - stim_onsets;
    
    odorant = results{3};
else
    create_log_file('', opt.tgt_dir, filename, ...
        'no onset', 'onset')
    warning('We have a big difference between the results and the breathing file.')
    stim_onsets = [];
    stim_durations = [];
    odorant = '';
end


%% get onsets, offsets, durations of responses
% collect responses
if numel(unique(resp))>3
    error('We have more than 3 value types in response vector.')
end

% We collect the onsets of each type of response
resp_onsets = [];
resp_offsets = [];
resp_type = [];

resp = diff(resp);
resp_values = unique(resp);
% remove values for offset for offsets as they are jsut the opposite of the
% onsets
resp_values(resp_values<=0) = [];

if ~isempty(resp_values)
    
    if ~all(resp_values==[8; 17])
        warning('some unusual responses')
        disp(resp_values)
    end
    
    for iResp = 1:numel(resp_values)
        
        this_resp = resp_values(iResp);
        
        if this_resp > 10
            type = 'resp_12';
        elseif this_resp < 10 && this_resp > 0
            type = 'resp_03';
        else
            disp(this_resp)
            error('Unusual response type')
        end
        
        tmp_onset = find(resp == this_resp);
        tmp_offset = find(resp == (this_resp*-1));
        
        % remove button realease that might have happened before button
        % press
        if tmp_offset(1)<tmp_onset(1)
            tmp_offset(1) = [];
        end
        
        % in case the subject did not release before the end of the
        % recording we assume a button realease at the end of the recording
        if numel(tmp_onset)==numel(tmp_offset)+1
            tmp_offset(end+1,1) = size(resp,1);
        end
        
        if numel(tmp_onset)~=numel(tmp_offset)
            disp(tmp_onset)
            disp(tmp_offset)
            error('Different number of respons offset and onsets.')
        end
        
        resp_type = [resp_type ; repmat(type, size(tmp_onset))];
        resp_onsets = [resp_onsets ; tmp_onset];
        resp_offsets = [resp_offsets ; tmp_offset];

    end

end

% account for the number of dummies removed;
resp_onsets = time(resp_onsets) - opt.nb_dummies * RT;
resp_offsets = time(resp_offsets) - opt.nb_dummies * RT;

% remove responses before first real scanned volume
early_resp = find(resp_onsets<0);
resp_onsets(early_resp) = [];
resp_offsets(early_resp) = [];
resp_type(early_resp,:) = [];

resp_durations = resp_offsets - resp_onsets;


%% put everything together and sort

onsets = [stim_onsets;resp_onsets];
durations = [stim_durations;resp_durations];
if ~isempty(resp_type)
    trial_type = cat(1,cellstr(odorant),cellstr(resp_type));
else
    trial_type = cellstr(odorant);
end

% remove any empty trial type in case of missing stimuli
trial_type( cellfun(@isempty,trial_type) ) = [];

[onsets, idx] = sort(onsets);
trial_type = trial_type(idx);
durations = durations(idx);

%% rewrite everything as tsv
event_tsv = output_file;
fid = fopen (event_tsv, 'w');

fprintf(fid, '%s\t%s\t%s\n', 'onset', 'duration', 'trial_type');

for i_line =  1:size(onsets,1)
    fprintf(fid, '%f\t%f\t%s\n', ...
        onsets(i_line), ...
        durations(i_line), ...
        trial_type{i_line});
end

fclose (fid);
end