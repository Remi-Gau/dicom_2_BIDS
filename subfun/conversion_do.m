function conversion_do(src_dir, tgt_dir, tgt_name, pattern, opt)

    % convert files (0 is for 4D unzipped files)
    dicm2nii(src_dir, tgt_dir, opt.zip_output);
    % give some time to zip the files before we rename them
    pause(opt.pauseTime)
    
    % rename json and .nii output files
    rename_tgt_file(tgt_dir, pattern.input, tgt_name, 'nii');
    rename_tgt_file(tgt_dir, pattern.input, tgt_name, 'json');
    
    % fix json content
    fix_json_content([tgt_name '.json'], opt);
    
    
end