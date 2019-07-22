function [opt, anat_tgt_dir] = convert_anat(sub_id, iSub, sub_src_dir, sub_tgt_dir, pattern, opt)
% converts DICOM anat file into nifti within a BIDS dataset
% only accepts one file as input

% define source and target folder for anat
ls_dir = spm_select('FPList', sub_src_dir, 'dir', pattern.input);
if size(ls_dir,1)==1
    anat_src_dir = ls_dir;
else
    disp(ls_dir)
    error('more than one source anat folder for the pattern %s', pattern.input)
end
anat_tgt_dir = fullfile(sub_tgt_dir, 'anat');

% define target file names for anat
anat_tgt_name = fullfile(anat_tgt_dir, [sub_id pattern.output]);

% in case we decided to not run the conversion
if opt.do
    % remove any nifti files and json present in the target folder to start
    % from a blank slate
    delete(fullfile(anat_tgt_dir, '*.nii*'))
    delete(fullfile(anat_tgt_dir, '*.json'))
    
    % convert files (0 is for 4D unzipped files)
    dicm2nii(anat_src_dir, anat_tgt_dir, opt.zip_output);
    % give some time to zip the files before we rename them
    pause(opt.pauseTime/4)
    
    % rename json and .nii output files
    rename_tgt_file(anat_tgt_dir, pattern.input, anat_tgt_name, 'nii');
    rename_tgt_file(anat_tgt_dir, pattern.input, anat_tgt_name, 'json');
    
    % try to get age and gender from json file
    opt = get_participant_info(opt, iSub, anat_tgt_name);
    
    % fix json content
    fix_json_content([anat_tgt_name '.json']);
end

end