# DICOM to BIDS with SPM12

Set of scripts and functions to convert a set of DICOM folders into a BIDS using SPM12 and dicm2nii

Remember to check the output with the [BIDS validator](https://bids-standard.github.io/bids-validator/).

Need to know more about BIDS
-   [BIDS starter kit](https://github.com/bids-standard/bids-starter-kit)
-   [BIDS specification](https://bids-specification.readthedocs.io/en/stable)

## Dependencies

| Dependencies                                                                                               | Used version |
|------------------------------------------------------------------------------------------------------------|--------------|
| [Matlab](https://www.mathworks.com/products/matlab.html)                                                   | 2018a(???)   |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)                                                 | v7487        |
| DICOM2NII (included in this repo) | NA           |


## TESTED with
-   windows 10 + matlab 2018a + SPM12 7487



## CONTENT



### `dicom_2_bids.m`

The script imports DICOMs and format them into a BIDS structure while saving json and creating a `participants.tsv` file also creates a `dataset_decription.json` with empty fields

Lots of the parameters can be changed in the parameters section in `getOption.ms` file.

In general make sure you have removed from your subjects source folder any folder that you do not want to convert (interrupted sequences for example).

At the moment this script is not super flexible and assumes only one session.

The script can remove up to 9 dummy scans.

json files created will be modified to remove any field with 'Patient' in it and the phase encoding direction will be re-encoded in a BIDS compliant way (`i`, `j`, `k`, `i-`, `j-`, `k-`).

The `participants.tsv` file is created based on the header info of the anatomical (sex and age) so it might not be accurate.


### `subfun` folder

Where most of the sub functions are. Hopefully you will not need to work on those.


### `DIY` folder

Contains functions that can be called by the pipeline to create events / stim / physio files and their json sidecar. All those functions might require some tweaking to adapt to the inputs you have as it might depends on how you saved your stimulus onsets, responses, physiological recordings, eyetracking, respiration...


### Other functions

#### `deface_anat.m`

Uses SPM12 to deface all the T1w of a BIDS.


### Option example

```
% Set directories
opt.spm_path = 'D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12';

% fullpaths
opt.src_dir = 'D:\Dropbox\BIDS\olf_blind\source\DICOM'; % source folder
opt.tgt_dir = 'D:\Dropbox\BIDS\olf_blind\source\raw'; % target folder
opt.onset_files_dir = 'D:\Dropbox\BIDS\olf_blind\source\Results';


opt.do_anat = 1;
opt.do_func = 1;
opt.do_dwi = 1;

opt.zip_output = 0;
opt.delete_json = 1;
opt.do = 1;


% DICOM folder patterns to look for
opt.subject_dir_pattern = {...
    'Olf_Blind_C*'; ...
    'Olf_Blind_B*'};

opt.subject_tgt_pattern = {...
    'ctrl'; ...
    'blnd'};

opt.subj_ls = {};


%% Details for ANAT
opt.src_anat_dir_patterns = {
    'acq-mprage_T1w', ...
    'acq-tse_t2-tse-cor-'};

opt.tgt_anat_dir_patterns = {
    '_T1w', ...
    '_acq-tse_T2w'};


%% Details for FUNC
opt.src_func_dir_patterns = {
    'bold_run-[1-2]';...
    'bold_run-[3-4]';...
    'bold_RS'};
opt.task_name = {...
    'olfid'; ...
    'olfloc'; ...
    'rest'};

opt.nb_dummies = 8;

opt.nb_folder = [;...
    2;...
    2;...
    1];

opt.get_physio = [
    1;...
    1;...
    0];
opt.physio_patterns = {...
    '^Breathing.*[Ii]den[_]?[0]?[1-2].*.txt$'; ...
    '^Breathing.*[Ll]oc[_]?[0]?[1-2].*.txt$' ;...
    ''};

opt.get_onset = [
    1;...
    1;...
    0];
opt.events_patterns = {...
    '^Breathing.*[Ii]den[_]?[0]?[1-2].*.txt$'; ...
    '^Breathing.*[Ll]oc[_]?[0]?[1-2].*.txt$' ;...
    ''};

opt.get_stim = [];
opt.stim_patterns = {};


%% Details for DWI
opt.src_dwi_dir_patterns = {...
    'pa_dwi', ...
    'ap_b0'};
opt.tgt_dwi_dir_patterns = {
    '_dwi', ...
    '_sbref'};


%% data description content
opt.dd_json.License = '';
opt.dd_json.Authors = {'','',''};
opt.dd_json.Acknowledgements = '';
opt.dd_json.HowToAcknowledge = '';
opt.dd_json.Funding = {'','',''};
opt.dd_json.ReferencesAndLinks = {'','',''};
opt.dd_json.DatasetDOI = '';
opt.dd_json.Name = 'olfiddis';
opt.dd_json.BIDSVersion = '1.1.0';


%% events json content
opt.events_json_content.onset = struct(...
    'LongName', 'event onset', ...
    'Description', ' ', ...
    'Levels', struct(), ...
    'Units', 'seconds',...
    'TermURL', ' ');
opt.events_json_content.duration = struct(...
    'LongName', 'event duration', ...
    'Description', ' ', ...
    'Levels', struct(), ...
    'Units', 'seconds',...
    'TermURL', ' ');
opt.events_json_content.trial_type = struct(...
    'LongName', 'odorant', ...
    'Description', ' ', ...
    'Levels', struct(...
        'ch1', 'channel 1', ...        
        'ch3', 'channel 3', ...
        'ch5', 'channel 5', ...
        'ch7', 'channel 7', ...
        'resp_03', 'response 3', ...
        'resp_12', 'response 12'), ...
    'Units', ' ',...
    'TermURL', ' ');


%% option for json writing
opt.indent = '    ';

```
