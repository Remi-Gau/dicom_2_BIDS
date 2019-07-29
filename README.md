# DICOM to BIDS with SPM12

Set of scripts and functions to convert a set of DICOM folders into a BIDS using SPM12 and dicm2nii

Remember to check the ouput with the [BIDS validator](https://bids-standard.github.io/bids-validator/).

Need to know more about BIDS
-   [BIDS starter kit](https://github.com/bids-standard/bids-starter-kit)
-   [BIDS specification](https://bids-specification.readthedocs.io/en/stable)

## REQUIRES
-   SPM12
-   DICOM2NII (included in this repo)

## TESTED with
-   windows 10 + matlab 2018a + SPM12 7487

## TO DO
-   extract participant weight from header and put in tsv file?
-   allow for removal of more than 9 dummy scans

## CONTENT

### `deface_anat.m`

Uses SPM12 to deface all the T1w of a BIDS.

### `dicom_2_bids.m`

The script imports DICOMs and format them into a BIDS structure while saving json and creating a `participants.tsv` file also creates a `dataset_decription.json` with empty fields

Lots of the parameters can be changed in the parameters section in getOption file.

In general make sure you have removed from your subjects source folder any folder that you do not want to convert (interrupted sequences for example).

At the moment this script is not super flexible and assumes only one session and can only deal with anatomical anat, functional and DWI.

The script can remove up to 9 dummy scans (they are directly moved from the DICOM source folder and put in a 'dummy' folder) so that dicm2nii does not "see" them.

The way `event.tsv` files are generated is very unflexible (line 210-230) also the stimulus onset is not yet recalculated depending on the number of dummies removed.

json files created will be modified to remove any field with 'Patient' in it and the phase encoding direction will be re-encoded in a BIDS compliant way (`i`, `j`, `k`, `i-`, `j-`, `k-`).

The `participants.tsv` file is created based on the header info of the anatomical (sex and age) so it might not be accurate.



###


src_dir = 'D:\Dropbox\BIDS\olf_blind\source\DICOM'; % source folder
tgt_dir = 'D:\Dropbox\BIDS\olf_blind\source\raw'; % target folder
opt.onset_files_dir = 'D:\Dropbox\BIDS\olf_blind\source\Results';


%% Parameters definitions
% select what to convert and transfer
do_anat = 0;
do_func = 1;
do_dwi = 0;


opt.zip_output = 0; % 1 to zip the output into .nii.gz (not ideal for
% SPM users)
opt.delete_json = 1; % in case you have already created the json files in
% another way (or you have already put some in the root folder)
opt.do = 0; % actually convert DICOMS, can be usefull to set to false
% if only events files or something similar must be created


% DICOM folder patterns to look for
subject_dir_pattern = 'Olf_Blind_C02*';


% Details for ANAT
% target folders to convert
opt.src_anat_dir_patterns = {
    'acq-mprage_T1w', ...
    'acq-tse_t2-tse-cor-'};

% corresponding names for the output file in BIDS data set
opt.tgt_anat_dir_patterns = {
    '_T1w', ...
    '_acq-tse_T2w'};


% Details for FUNC
opt.src_func_dir_patterns = {
    'bold_run-[1-2]';...
    'bold_run-[3-4]';...
    'bold_RS'};
opt.task_name = {...
    'olfid'; ...
    'olfloc'; ...
    'rest'};
opt.get_onset = [
    1;...
    1;...
    0];
opt.get_stim = [
    1;...
    1;...
    0];
opt.nb_folder = [;...
    2;...
    2;...
    1];
opt.stim_patterns = {...
    '^Breathing.*[Ii]den[_]?[0]?[1-2].*.txt$'; ...
    '^Breathing.*[Ll]oc[_]?[0]?[1-2].*.txt$' ;...
    ''};
opt.events_patterns = {...
    '^Results.*.txt$';...
    '^Results.*.txt$';...
    ''};
opt.events_src_file = {
    1:2;...
    3:4;...
    []};

opt.nb_dummies = 8; %9 MAX!!!!


% Details for DWI
% target folders to convert
opt.src_dwi_dir_patterns = {...
    'pa_dwi', ...
    'ap_b0'};
% corresponding names for the output file in BIDS data set
opt.tgt_dwi_dir_patterns = {
    '_dwi', ...
    '_sbref'};
% take care of eventual bval bvec values
opt.bvecval = [...
    1; ...
    0];
