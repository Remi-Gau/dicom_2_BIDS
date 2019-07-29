function rename_tgt_file(tgt_dir, pattern, tgt_name, ext)

pattern = strrep(pattern, '-','_');
pattern = strrep(pattern, '.','_');
pattern = strrep(pattern, '*','.*');

tgt_file = spm_select('FPList', tgt_dir, ...
    ['^.*' pattern '.*' ext '$']);

movefile(tgt_file, [tgt_name '.' ext])

end