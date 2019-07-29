function opt = conversion_do(src_dir, tgt_dir, tgt_name, pattern, opt)

fprintf('\n converting DICOM folder: %s\n  into file: %s\n\n', src_dir, tgt_name)
% convert files (0 is for 4D unzipped files)
dicm2nii(deblank(src_dir), tgt_dir, opt.zip_output);
% give some time to zip the files before we rename them
pause(opt.pauseTime)

% rename json and .nii output files
rename_tgt_file(tgt_dir, pattern.input, tgt_name, 'json');
rename_tgt_file(tgt_dir, pattern.input, tgt_name, 'nii');

% try to get age and gender from json file
opt = get_participant_info(opt, tgt_name);

% fix json content
fix_json_content([tgt_name '.json'], pattern, opt);

% copy json content to base directory
cp_json_2_root([tgt_name '.json'], opt)

if opt.delete_json
    delete([tgt_name '.json'])
end

end