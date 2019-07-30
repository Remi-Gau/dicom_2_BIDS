function rename_tgt_file(tgt_dir, pattern, tgt_name, ext)
% rename a file to fit the BIDS nomemclature
% some characters in the input filename will be changed if the file is a bold
% modality

pattern = strrep(pattern, '-','_');
pattern = strrep(pattern, '.','_');
pattern = strrep(pattern, '*','.*');

tgt_file = spm_select('FPList', tgt_dir, ...
    ['^.*' pattern '.*' ext '$']);

movefile(tgt_file, [tgt_name '.' ext])

end
