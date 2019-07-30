function [dwi_tgt_dir] = convert_dwi(sub_id, sub_src_dir, sub_tgt_dir, pattern, opt)

% define source and target folder for dwi
dwi_src_dir = spm_select('FPList', sub_src_dir, 'dir', ...
    ['^.*' pattern.input '$']);
if size(dwi_src_dir,1)~=1
    disp(dwi_src_dir)
    warning('more than one or no source dwi folder')
    create_log_file(sub_id, sub_src_dir, ['_dwi-' pattern.output], dwi_src_dir, 'folder')
end

dwi_tgt_dir = fullfile(sub_tgt_dir, 'dwi');

% in case we decided to not run the conversion
if opt.do

    % define target file names for dwi
    dwi_tgt_name = fullfile(dwi_tgt_dir, [sub_id  pattern.output]);
    
    % do the conversion and rename the output files and fix json content
    conversion_do(dwi_src_dir, dwi_tgt_dir, dwi_tgt_name, pattern, opt);
    
    % try to see if a bvec file was created
    bvec_file = spm_select('FPList', dwi_tgt_dir, ...
    ['^.*' pattern.input '.*bvec$']);
    
    if ~isempty(bvec_file)
        
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