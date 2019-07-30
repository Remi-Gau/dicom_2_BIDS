function [opt, anat_tgt_dir] = convert_anat(sub_id, sub_src_dir, sub_tgt_dir, pattern, opt)
% converts DICOM anat file into nifti within a BIDS dataset
% only accepts one file as input

% define source and target folder for anat
ls_dir = spm_select('FPList', sub_src_dir, 'dir', pattern.input);
if size(ls_dir,1)==1
    anat_src_dir = ls_dir;
else
    disp(ls_dir)
    warning('more than one source anat folder for the pattern %s', pattern.input)
    create_log_file(sub_id, sub_src_dir, ['_anat-' pattern.output], ls_dir, 'folder')
end
anat_tgt_dir = fullfile(sub_tgt_dir, 'anat');

% define target file names for anat
anat_tgt_name = fullfile(anat_tgt_dir, [sub_id pattern.output]);

% in case we decided to not run the conversion
if opt.do

    % do the conversion and rename the output files and fix json content
    opt = conversion_do(anat_src_dir, anat_tgt_dir, anat_tgt_name, pattern, opt);

end

end
