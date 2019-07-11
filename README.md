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
-   refactor the different sections anat, func, dwi
-   subject renaming should be more flexible
-   allow for removal of more than 9 dummy scans

## CONTENT

### `deface_anat.m`

Uses SPM12 to deface all the T1w of a BIDS.

### `dicom_2_bids.m`

The script imports DICOMs and format them into a BIDS structure while saving json and creating a `participants.tsv` file also creates a `dataset_decription.json` with empty fields

Lots of the parameters can be changed in the parameters section at the beginning of the script.

In general make sure you have removed from your subjects source folder any folder that you do not want to convert (interrupted sequences for example).

At the moment this script is not super flexible and assumes only one session and can only deal with anatomical T1, functional (bold and rest) and DWI.

It also makes some assumption on the number of DWI, ANAT, resting state runs (only takes 1).

The way the subject naming happens is hardcoded (line 90-100).

The script can remove up to 9 dummy scans (they are directly moved from the DICOM source folder and put in a 'dummy' folder) so that dicm2nii does not "see" them.

The way `event.tsv` files are generated is very unflexible (line 210-230) also the stimulus onset is not yet recalculated depending on the number of dummies removed.

There will still some cleaning up to do in the json files: for example most likely you will only want to have json files in the root folder and that apply to all inferior levels rather than one json file per nifti file.

json files created will be modified to remove any field with 'Patient' in it and the phase encoding direction will be re-encoded in a BIDS compliant way (`i`, `j`, `k`, `i-`, `j-`, `k-`).

The `participants.tsv` file is created based on the header info of the anatomical (sex and age) so it might not be accurate.
