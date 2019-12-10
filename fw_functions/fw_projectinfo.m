function FW = fw_projectinfo(bold_filename, fn_label)

if nargin < 1 || isempty(bold_filename)
    bold_filename = 'self';
end
if nargin < 2 || isempty(fn_label)
    fn_label = 'roi*.label';
end

% Copy information from FreeSurfer
FS = fs_setup;
FW.subjects = FS.subjects;
FW.fMRI = fullfile(FW.subjects, '..', 'Data_fMRI');
FW.hemis = FS.hemis;
FW.nHemi = FS.nHemi;

% bold subject names
FW.subjdir = dir(fullfile(FW.fMRI, ['faceword*' bold_filename]));
FW.subjList = {FW.subjdir.name};
FW.nSubj = numel(FW.subjList);

% label filenames
labeldir = dir(fullfile(FW.subjects, '*', 'label', fn_label)); 
FW.labelList = unique({labeldir.name});
FW.nLabel = numel(FW.labelList);


end