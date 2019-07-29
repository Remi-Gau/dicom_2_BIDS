function cp_json_2_root(src_file, opt)

[~, filename, ext] = spm_fileparts(src_file);
[parts] = strsplit(filename, '_');
parts(1) = []; % remove subject info
tgt_file = join(parts, '_');
tgt_file = fullfile(opt.tgt_dir, ...
    [tgt_file{1} ext]);

copyfile(src_file, tgt_file)

end