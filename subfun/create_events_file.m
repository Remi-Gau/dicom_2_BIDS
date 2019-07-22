function create_events_file(input_file, output_file)

fprintf('\n getting EVENTS from: %s\n  into file: %s', input_file, output_file)

% get event onsets
fid = fopen (input_file, 'r');
onsets = textscan(fid,'%s%s%s%s%s', 'Delimiter', ',');
fclose (fid);

% rewrite them as tsv
event_tsv = output_file;
fid = fopen (event_tsv, 'w');

fprintf(fid, '%s\t%s\t%s\n', 'onset', 'duration', 'odorant');

for i_line =  2:size(onsets{1},1)
    fprintf(fid, '%f\t%f\t%s\n', ...
        str2double(onsets{4}{i_line}), ...
        str2double(onsets{5}{i_line}) - str2double(onsets{4}{i_line}), ...
        onsets{3}{i_line});
end
fclose (fid);
end