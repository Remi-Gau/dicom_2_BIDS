function rename_tgt_file(tgt_dir, pattern, tgt_name, ext)

tgt_file = spm_select('FPList', tgt_dir, ...
    ['^.*' strrep(pattern, '-','_') '.*.' ext '$']);
movefile(tgt_file, [tgt_name '.' ext])

end