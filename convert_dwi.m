function [dwi_tgt_dir] = convert_dwi(sub_id, sub_src_dir, sub_tgt_dir, bvecval, pattern, opt)

% define source and target folder for dwi
dwi_src_dir = spm_select('FPList', sub_src_dir, 'dir', ...
    ['^.*' pattern.input '$']);
if size(dwi_src_dir,1)~=1
    disp(dwi_src_dir)
    error('more than one or no source dwi folder')
end

dwi_tgt_dir = fullfile(sub_tgt_dir, 'dwi');

% in case we decided to not run the conversion
if opt.do
    
    % remove any Nifti files and json present
    delete(fullfile(dwi_tgt_dir, '*.nii*'))
    delete(fullfile(dwi_tgt_dir, '*.json'))
    
    if bvecval
        delete(fullfile(dwi_tgt_dir, '*.bv*'))
    end
    
    % define target file names for dwi
    dwi_tgt_name = fullfile(dwi_tgt_dir, [sub_id  pattern.output]);
    
    % do the conversion and rename the output files and fix json content
    conversion_do(dwi_src_dir, dwi_tgt_dir, dwi_tgt_name, pattern, opt)
    
    if bvecval
        
        rename_tgt_file(dwi_tgt_dir, pattern.input, dwi_tgt_name, 'bvec');
        rename_tgt_file(dwi_tgt_dir, pattern.input, dwi_tgt_name, 'bval');
        
        % reformat bval (remove double spaces)
        bval = load([dwi_tgt_name '.bval']);
        fid = fopen ([dwi_tgt_name '.bval'], 'w');
        fprintf(fid, '%i ', bval);
        fclose (fid);
        
        % reformat bvec (remove double spaces)
        bvec = load([dwi_tgt_name '.bvec']);
        fid = fopen ([dwi_tgt_name '.bvec'], 'w');
        fprintf(fid, '%f ', bvec(1,:));
        fprintf(fid, '\n');
        fprintf(fid, '%f ', bvec(2,:));
        fprintf(fid, '\n');
        fprintf(fid, '%f ', bvec(3,:));
        fclose (fid);
        
    end
    
end


end