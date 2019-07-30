function cp_json_2_root(src_file, opt)
%  makes a copy of a json file from a subject folder to the base folder of the
% BIDS data set by simply removing the sub-XXX prefix. Might still need some tweaking
% and cleaning but it can be useful especially if the delete_json option has been
% ticked

[~, filename, ext] = spm_fileparts(src_file);
[parts] = strsplit(filename, '_');
parts(1) = []; % remove subject info
tgt_file = join(parts, '_');
tgt_file = fullfile(opt.tgt_dir, ...
    [tgt_file{1} ext]);

copyfile(src_file, tgt_file)

end
