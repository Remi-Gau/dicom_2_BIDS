function create_physio_file(input_file, output_file)

fprintf('\n getting STIM from: %s\n  into file: %s', input_file, output_file)

% read content of breathing file
fid = fopen (input_file, 'r');
stim = textscan(fid,'%f%f%f%f%f', 'Delimiter', ',');
fclose (fid);

% rewrite them as tsv
fid = fopen(output_file, 'w');

for i_line =  1:size(stim{1},1)
    fprintf(fid, '%f\n', stim{1}(i_line));
end
fclose (fid);
gzip(output_file) % bids spec expects _phsyio.tsv files to be zipped
delete(output_file)

end