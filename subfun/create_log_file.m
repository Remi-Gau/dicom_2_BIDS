function create_log_file(sub_id, sub_src_dir, suffix, content, msg)

output_file = fullfile(sub_src_dir, '..', ['log_' sub_id suffix '.txt']);

fid = fopen(output_file, 'w');

if strcmp(msg, 'folder')
    fprintf(fid, ' %s\n', 'More than the required number of source folders');
elseif strcmp(msg, 'onset')
    fprintf(fid, ' %s\n', ' We have an onset/offset problem or a difference with the results file. See below:');
end

for i_line =  1:size(content,1)
    fprintf(fid, ' %s\n', content(i_line,:));
end

fclose (fid);

end